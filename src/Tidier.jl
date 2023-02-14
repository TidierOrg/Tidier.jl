module Tidier

using DataFrames
using MacroTools
using Chain
using Statistics
using Reexport

@reexport using Chain
@reexport using Statistics

export @select, @transmute, @rename, @mutate, @summarize, @summarise, @filter, @group_by, @slice, @arrange, across, desc


function across(args...)
  throw("This function should only be called inside of @mutate(), @summarize, or @summarise.")
end

function desc(args...)
  throw("This function should only be called inside of @arrange().")
end

macro autovec(df, fn_name, exprs...)

  if fn_name == "groupby"
    fn_call = "groupby($df, :" * join(exprs, ", :") * ")"

    # After :escape, there is either a symbol containing name of data frame
    # as in :movies, or if using @chain, then may say Symbol("##123"), so
    # colon is optional.

    fn_call = replace(fn_call, r"^(.+)\$\(Expr\(:escape, :?(.+?)\)(.+)$" => s"\1\2\3")
    fn_call = replace(fn_call, r"Symbol\((\".+?\")\)+," => s"var\1,")
    @info fn_call

    return :(groupby($(esc(df)), Symbol.($[exprs...])))
  end

  tp = tuple(exprs...)

  arr_calls = String[]

  for expr in tp

    # This creates :column => (x -> subset criteria) => :ignore,
    # and then the "=> :ignore" portion is removed later on.
    # Eventually may handle this more directly.
    if (fn_name == "subset")
      expr = :(ignore = $expr)
    end

    arr_rhs = String[]

    check_if_across = false

    # Only auto-vectorize code outside of summarize/summarise,
    # which have an fn_name of "combine"
    # Auto-vectorize means that any of the functions *not*
    # included in the array below are vectorized automatically.
    new_expr = MacroTools.postwalk(expr) do x
      @capture(x, fn_(ex__)) || return x
      push!(arr_rhs, join([ex...], ";"))
      if fn == :across
        vars_clean = string(ex[1])
        vars_clean = split(vars_clean, ", ")
        vars_clean = replace.(vars_clean, r"^\(" => s"")
        for i in eachindex(vars_clean)
          if !occursin(r"[()]", vars_clean[i])
            vars_clean[i] = ":" * vars_clean[i]
          elseif occursin(r"\)$", vars_clean[i]) && !occursin(r"\(", vars_clean[i])
            vars_clean[i] = ":" * vars_clean[i]
            vars_clean[i] = replace(vars_clean[i], r"\)$" => s"")
          end
        end

        vars_clean = "[" * join(vars_clean, " ") * "]"

        fns_clean = string(ex[2])
        fns_clean = split(fns_clean, ", ")
        fns_clean = replace.(fns_clean, r"^\(" => s"")
        for i in eachindex(fns_clean)
          if occursin(r"\)$", fns_clean[i]) && !occursin(r"\(", fns_clean[i])
            fns_clean[i] = replace(fns_clean[i], r"\)$" => s"")
          end
        end
        fns_clean = "[" * join(fns_clean, ", ") * "]"

        push!(arr_calls, vars_clean * " .=> " * fns_clean)
        check_if_across = true
      elseif fn_name == "combine" || (fn in [:mean :median :first :last :minimum :maximum :sum :length :skipmissing :quantile :passmissing :startswith :contains :endswith])
        return x
      elseif contains(string(fn), r"[^\W0-9]\w*$") # valid variable name
        return :($fn.($(ex...)))
      else # operator
        fn_new = Symbol("." * string(fn))
        return :($fn_new($(ex...)))
      end
    end

    if check_if_across
      continue
    end

    # If there is no right-sided expression, then look for patterns of a = b,
    # and push the b to the right side.
    if length(arr_rhs) == 0
      MacroTools.postwalk(expr) do x
        @capture(x, a_ = b_) || return x
        push!(arr_rhs, string(b))
      end
    end

    arr_lhs = String[]

    # Push any symbols (variables) on the left side of the `=` sign
    # to the arr_lhs array, which contains the left-hand side arguments
    # expr_lhs is currently ignored, so the returned values don't matter
    expr_lhs = MacroTools.postwalk(new_expr) do x
      @capture(x, s_Symbol = body_) || return x
      if !(s in [:+ :- :* :/ :\])
        push!(arr_lhs, string(s))
        return QuoteNode(s)
      else
        return (x)
      end
    end

    # println(arr_lhs)
    # println(arr_rhs)

    if length(arr_lhs) > 0
      arr_lhs = last(arr_lhs)

      arr_rhs = strip.(reduce(vcat, split.(arr_rhs, ";")))
      arr_rhs = arr_rhs[isnothing.(match.(r"[()]", arr_rhs))]
      arr_rhs_match = match.(r"(-?)\(?([^\W0-9]\w*?)(:?)([^\W0-9]\w*)?\)?", arr_rhs)
      arr_rhs = arr_rhs[.!isnothing.(arr_rhs_match)]
      arr_rhs = unique(arr_rhs)

      arr_rhs_symbols = string(Symbol.(arr_rhs))
      # arr_rhs = length(arr_rhs) > 1 ? reduce(vcat, arr_rhs) : arr_rhs

      fn_body = string(new_expr)
      fn_body = join(strip.(split(fn_body, "=")[2:end]), "=")

      if (fn_name == "rename")
        push!(arr_calls, SubString(arr_rhs_symbols, 2, lastindex(arr_rhs_symbols) - 1) * " => :" * arr_lhs)
      elseif (fn_name == "subset")
        push!(arr_calls, arr_rhs_symbols * " => ((" * join(arr_rhs, ",") * ") -> " * fn_body * ")")
      else
        push!(arr_calls, arr_rhs_symbols * " => ((" * join(arr_rhs, ",") * ") -> " * fn_body * ") => :" * arr_lhs)
      end
    else

      # selection_match = match.(r"(-?)\(?\(?([^\W0-9]\w*)(:?)([^\W0-9]\w*)?\)?\)?", string(expr))

      # Selection actually can be a number and doesn't have to be a valid variable name      
      selection_match = match.(r"(-?)\(?\(?(\w+)(:?)(\w+)?\)?\)?", string(expr))

      # arr_rhs = arr_rhs[.!isnothing.(arr_rhs_match)]

      # println(string(expr))

      arr_call = ""
      if selection_match[3] == ":"
        arr_call = "Between( :" * selection_match[2] * ",:" * selection_match[4] * ")"
      else
        arr_call = ":" * selection_match[2]
      end

      if selection_match[1] == "-"
        arr_call = "Not(" * arr_call * ")"
      end
      # println(arr_call)
      push!(arr_calls, arr_call)
    end
    # println(arr_lhs)
    # println(arr_rhs)
    # println(expr_symbols)
  end

  fn_call = "$fn_name($df, " * join(arr_calls, ",") * ")"

  # After :escape, there is either a symbol containing name of data frame
  # as in :movies, or if using @chain, then may say Symbol("##123"), so
  # colon is optional.

  fn_call = replace(fn_call, r"^(.+)\$\(Expr\(:escape, :?(.+?)\)(.+)$" => s"\1\2\3")
  fn_call = replace(fn_call, r"Symbol\((\".+?\")\)+," => s"var\1,")

  @info fn_call

  # Meta.parse(fn_call)

  return_val = quote

    # Ultimately we need to remove this eval() because this may limit the use of functions
    # to those re-exported by Tidier.jl

    arr_eval_calls = eval.(Meta.parse.($arr_calls))

    if $fn_name == "select"
      select($(esc(df)), arr_eval_calls...)
    elseif $fn_name == "rename"
      rename($(esc(df)), arr_eval_calls...)
    elseif $fn_name == "transform"
      transform($(esc(df)), arr_eval_calls...)
    elseif $fn_name == "combine"
      combine($(esc(df)), arr_eval_calls...)
    elseif $fn_name == "subset"
      subset($(esc(df)), arr_eval_calls...)
    else
      error("Function not supported in Tidier.jl.")
      # no need to support groupby bc it is handled up top
    end
  end

  return_val
end

"""
    @select(df, exprs...)

Select variables in a DataFrame.

# Arguments
- `df`: A DataFrame.
- `exprs...`: One or more unquoted variable names separated by commas. Variable names 
         can also be used as their positions in the data, like `x:y`, to select 
         a range of variables.

# Examples
```julia-repl
Julia> using RDatasets
Julia> movies = dataset("ggplot2", "movies")
Julia> @chain movies begin
  @select(Title, Year, Length, Budget, Rating)
end
Julia> @chain movies begin
  @select(Title:Rating)
end
```
"""
macro select(df, exprs...)
  quote
    @autovec($(esc(df)), "select", $(exprs...))
  end
end

"""
    @transmute(df, exprs...)

Create a new DataFrame with only computed columns.

# Arguments
- `df`: A DataFrame.
- `exprs...`: add new columns or replace values of existed columns using
         `new_variable = values` syntax.

# Examples
```julia-repl
Julia> using RDatasets
Julia> movies = dataset("ggplot2", "movies")
Julia> @chain movies begin
  @mutate(Budget = Budget/1_000_000)
end
"""
macro transmute(df, exprs...)
  quote
    @autovec($(esc(df)), "select", $(exprs...))
  end
end

"""
    @rename(df, exprs...)

Change the names of individual column names in a DataFrame. Users can also use `@select()`
to rename and select columns.

# Arguments
- `df`: A DataFrame.
- `exprs...`: Use `new_name = old_name` syntax to rename selected columns.

# Examples
```julia-repl
julia> using RDatasets
julia> movies = dataset("ggplot2", "movies")
julia> @chain movies begin
  @mutate(Budget = Budget/1_000_000)
end
"""
macro rename(df, exprs...)
  quote
    @autovec($(esc(df)), "rename", $(exprs...))
  end
end

"""
    @mutate(df, exprs...)
  
Create new columns as functions of existing columns. The results have the same number of
rows as `df`.

# Arguments
- `df`: A DataFrame.
- `exprs...`: add new columns or replace values of existed columns using
         `new_variable = values` syntax.

"""
macro mutate(df, exprs...)
  quote
    @autovec($(esc(df)), "transform", $(exprs...))
  end
end

"""
    @summarize(df, exprs...)
    @summarize(gd, exprs...)
    @summarise(df, exprs...)
    @summarise(gd, exprs...)

Create a new DataFrame with one row that summarizing all observations from the input DataFrame, 
or the input GroupedDataFrame. 

# Arguments
- `df`: A DataFrame.
- `gd`: A GroupedDataFrame.
- `exprs...`: a `new_variable = function(old_variable)` pair. `function()` should be an agregate 
         function that returns a vector of lenght 1. 

"""
macro summarize(df, exprs...)
  quote
    @autovec($(esc(df)), "combine", $(exprs...))
  end
end

macro summarise(df, exprs...)
  quote
    @autovec($(esc(df)), "combine", $(exprs...))
  end
end

"""
    @filter(df::AbstractDataFrame, exprs...)

Subset a DataFrame and return a copy of DataFrame where specified conditions are satisfied.

# Arguments
- `df`: A DataFrame.
- `exprs...`: transformation(s) that produce vectors containing `true` or `false`.

"""
macro filter(df, exprs...)
  quote
    @autovec($(esc(df)), "subset", $(exprs...))
  end
end

"""
    @group_by(df, cols...)

Return a `GroupedDataFrame` where operations are performed by groups specified by unique 
sets of `cols`.

# Arguments
- `df`: A DataFrame.
- `cols...`: DataFrame columns to group by. Can be a single column name or a vector of column names. 
"""
macro group_by(df, exprs...)
  quote
    @autovec($(esc(df)), "groupby", $(exprs...))
  end
end

"""
    @slice(df, exprs...)

Select, remove or duplicate rows by indexing their integer positions.

# Arguments
- `df`: A DataFrame.
- `exprs...`: integer row values. Use positive values to keep the rows, or negative values to drop.
         Values provided must be either all positive or all negative, and they must be within the
         range of DataFrames' row number.
"""
macro slice(df, exprs...)
  quote
    df_name = $(string(df))
    df_name = replace(df_name, r"^(##\d+)$" => s"var\"\1\"")

    local indices = [$(exprs...)]
    try
      if (all(indices .< 0))
        return_string = df_name * "[Not(" * string(-indices) * "), :]"
        return_value = $(esc(df))[Not(-copy(indices)), :]
      else
        return_string = df_name * "[" * string(indices) * ", :]"
        return_value = $(esc(df))[copy(indices), :]
      end
    catch e
      local indices2 = reduce(vcat, collect.(indices))
      if (all(indices2 .< 0))
        return_string = df_name * "[Not(" * string(-indices2) * "), :]"
        return_value = $(esc(df))[Not(-copy(indices2)), :]
      else
        return_string = df_name * "[" * string(indices2) * ", :]"
        return_value = $(esc(df))[copy(indices2), :]
      end

      @info return_string
      return return_value
    end
  end
end

"""
    @arrange(df, exprs...)

Orders the rows of a DataFrame by the values of specified columns.

# Arguments
- `df`: A DataFrame.
- `exprs...`: Variables, or functions of variables from the input DataFrame. Use `desc()` to sort
         in descending order.
"""
macro arrange(df, exprs...)
  tp = tuple(exprs...)
  arr_calls = String[]

  for expr in tp
    expr_string = string(expr)
    expr_string = replace(expr_string, r"^desc\((.+)\)$" => s"order(:\1, rev=true)")

    if !occursin(r"[()]", expr_string)
      expr_string = ":" * expr_string
    end

    push!(arr_calls, expr_string)
  end

  fn_call = "sort($df, " * join(arr_calls, ",") * ")"
  fn_call = replace(fn_call, r"(##\d+)" => s"var\"\1\"")

  @info fn_call

  return_val = quote
    arr_eval_calls = eval.(Meta.parse.($arr_calls))
    sort($(esc(df)), [arr_eval_calls...])
  end
  return_val
end

end