module Tidier

using DataFrames
using MacroTools
using Chain
using Statistics
using Reexport

@reexport using Chain
@reexport using Statistics

export @select, @transmute, @rename, @mutate, @summarize, @summarise, @filter, @group_by, @slice, @arrange, across, desc

"""
    across(variable[s], function[s])

Apply functions to multiple variables. If specifiying multiple variables or functions, surround them with a parentheses so that they are recognized as a tuple.

This function should only be called inside of `@mutate()`, `@summarize`, or `@summarise`.

# Arguments
- `variable[s]`: An unquoted variable, or if multiple, an unquoted tuple of variables.
- `function[s]`: A function, or if multiple, a tuple of functions.

# Examples
```julia-repl
julia> using DataFrames

julia> df = DataFrame(a = repeat('a':'e'), b = 1:5, c = 11:15)

julia> @chain df begin
  @summarize(across(b, minimum))
  end

julia> @chain df begin
  @summarize(across((b,c), (minimum, maximum)))
  end

julia> @chain df begin
  @mutate(across((b,c), (minimum, maximum)))
  end
```
"""
function across(args...)
  throw("This function should only be called inside of @mutate(), @summarize, or @summarise.")
end

"""
    desc(col)

Orders the rows of a DataFrame column in descending order when used inside of `@arrange()`. This function should only be called inside of `@arrange()``.

# Arguments
- `col`: An unquoted column name.

# Examples
```julia-repl
julia> using DataFrames

julia> df = DataFrame(a = repeat('a':'e', inner = 2), b = 1:10, c = 11:20)
  
julia> @chain df begin
  @arrange(a, desc(b))
  end
```
"""
function desc(args...)
  throw("This function should only be called inside of @arrange().")
end

# Not exported
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
      elseif fn_name == "combine" || (fn in [:mean :std :var :median :first :last :minimum :maximum :sum :length :skipmissing :quantile :passmissing :startswith :contains :endswith])
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
julia> using DataFrames

julia> df = DataFrame(a = repeat('a':'e'), b = 1:5, c = 11:15)

julia> @chain df begin
  @select(a,b,c)
  end

julia> @chain df begin
  @select(a:b)
  end

julia> @chain df begin
  @select(1:2)
  end

julia> @chain df begin
  @select(-(a:b))
  end

@chain df begin
  @select(across(contains("b"), (sum, mean)))
  end

julia> @chain df begin
  @select(-(1:2))
  end

julia> @chain df begin
  @select(-c)
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
julia> using DataFrames

julia> df = DataFrame(a = repeat('a':'e'), b = 1:5, c = 11:15)

julia> @chain df begin
  @transmute(d = b + c)
  end
```
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
julia> using DataFrames

julia> df = DataFrame(a = repeat('a':'e'), b = 1:5, c = 11:15)

julia> @chain df begin
  @rename(d = b, e = c)
  end
```
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

# Examples
```julia-repl
julia> using DataFrames

julia> df = DataFrame(a = repeat('a':'e'), b = 1:5, c = 11:15)

julia> @chain df begin
  @mutate(d = b + c, b_minus_mean_b = b - mean(b))
  end

julia> @chain df begin
  @mutate(across((b, c), mean))
  end
```
"""
macro mutate(df, exprs...)
  quote
    @autovec($(esc(df)), "transform", $(exprs...))
  end
end

"""
    @summarize(df, exprs...)
    @summarise(df, exprs...)

Create a new DataFrame with one row that aggregating all observations from the input DataFrame or GroupedDataFrame. 

# Arguments
- `df`: A DataFrame.
- `exprs...`: a `new_variable = function(old_variable)` pair. `function()` should be an aggregate function that returns a single value. 

# Examples
```julia-repl
julia> using DataFrames

julia> df = DataFrame(a = repeat('a':'e'), b = 1:5, c = 11:15)
  
julia> @chain df begin
  @summarize(mean_b = mean(b), median_b = median(b))
  end
  
julia> @chain df begin
  @summarize(across((b,c), (minimum, maximum)))
  end
```
"""
macro summarize(df, exprs...)
  quote
    @autovec($(esc(df)), "combine", $(exprs...))
  end
end

"""
    @summarize(df, exprs...)
    @summarise(df, exprs...)

Create a new DataFrame with one row that aggregating all observations from the input DataFrame or GroupedDataFrame. 

# Arguments
- `df`: A DataFrame.
- `exprs...`: a `new_variable = function(old_variable)` pair. `function()` should be an aggregate function that returns a single value. 

# Examples
```julia-repl
julia> using DataFrames

julia> df = DataFrame(a = repeat('a':'e'), b = 1:5, c = 11:15)
  
julia> @chain df begin
  @summarise(mean_b = mean(b), median_b = median(b))
  end
  
julia> @chain df begin
  @summarise(across((b,c), (minimum, maximum)))
  end
```
"""
macro summarise(df, exprs...)
  quote
    @autovec($(esc(df)), "combine", $(exprs...))
  end
end

"""
    @filter(df, exprs...)

Subset a DataFrame and return a copy of DataFrame where specified conditions are satisfied.

# Arguments
- `df`: A DataFrame.
- `exprs...`: transformation(s) that produce vectors containing `true` or `false`.

# Examples
```julia-repl
  julia> using DataFrames

  julia> df = DataFrame(a = repeat('a':'e'), b = 1:5, c = 11:15)
  
  julia> @chain df begin
    @filter(b >= mean(b))
    end
```
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
- `cols...`: DataFrame columns to group by. Can be a single column name or multiple column names separated by commas.

# Examples
```julia-repl
  julia> using DataFrames

  julia> df = DataFrame(a = repeat('a':'e', inner = 2), b = 1:10, c = 11:20)
  
  julia> @chain df begin
    @group_by(a)
    @summarize(b = mean(b))
    end
```
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
- `exprs...`: integer row values. Use positive values to keep the rows, or negative values to drop. Values provided must be either all positive or all negative, and they must be within the range of DataFrames' row numbers.

# Examples
```julia-repl
julia> using DataFrames

julia> df = DataFrame(a = repeat('a':'e', inner = 2), b = 1:10, c = 11:20)
  
julia> @chain df begin
    @slice(1:5)
    end

julia> @chain df begin
  @slice(-(1:5))
  end
```         
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
- `exprs...`: Variables from the input DataFrame. Use `desc()` to sort in descending order. Multiple variables can be specified, separated by commas.

# Examples
```julia-repl
julia> using DataFrames

julia> df = DataFrame(a = repeat('a':'e', inner = 2), b = 1:10, c = 11:20)
  
julia> @chain df begin
    @arrange(a)
    end

julia> @chain df begin
  @arrange(a, desc(b))
  end
```
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

"""
    @left_join(df1, df2, exprs...)

Left joins two data frames based on a shared key column

# Arguments
- `df1`: A DataFrame.
- `df2`: A DataFrame.
- `exprs...`: Variable(s) from the input DataFrames to use as the join key.

# Examples
```julia-repl
julia> using DataFrames

julia> df1 = DataFrame(id = [1,2,3], val1 = ["A", "B", "C"])
julia> df2 = DataFrame(id = [1,2,3], val2 = ["D", "E", "F"])
julia> df3 = DataFrame(employee_id = [1,2,3], val3 = ["G", "H", "I"])
  
julia> @left_join(df1, df2, :id)

julia> @left_join(df1, df2)

julia> @left_join(df1, df2, @join_by("id"))

julia> @left_join(df1, df3, @join_by("id" == "employee_id"))
```
"""

macro left_join(df1, df2, by::String)
  quote  
    leftjoin($(esc(df1)), $(esc(df2)), on = Symbol($(esc(by))))
  end
end

macro left_join(df1, df2, by::Symbol)
  quote  
    leftjoin($(esc(df1)), $(esc(df2)), on = $(esc(by)))
  end
end

macro left_join(df1, df2, by::Expr)
  quote  
    leftjoin($(esc(df1)), $(esc(df2)), on = $(esc(by)))
  end
end

macro left_join(df1, df2)
  quote
    shared_columns = intersect(
        names($(esc(df1))),
        names($(esc(df2)))
    )

    println("Joining by ", shared_columns, "\n")

    leftjoin($(esc(df1)),
             $(esc(df2)),
             on = Symbol.(shared_columns)
    )
  end
end

macro join_by(by::String)
  quote
    Symbol.($(esc(by)))
  end
end

function str_to_pair(by::String)
  expr = Meta.parse(by)
  return(Symbol(expr.args[2]) => Symbol(expr.args[3]))
end

macro join_by(by::Expr)
  quote
    str_to_pair($(string(by)))
  end
end

