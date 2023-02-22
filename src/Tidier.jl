module Tidier

using DataFrames
using MacroTools
using Chain
using Statistics
using Reexport

@reexport using Chain
@reexport using Statistics

export @select, @transmute, @rename, @mutate, @summarize, @summarise, @filter, @group_by, @slice, @arrange, across, desc, starts_with, ends_with, matches

# Need to expand with docs
# These are just aliases
starts_with(args...) = startswith(args...)
ends_with(args...) = endswith(args...)
matches(pattern, flags...) = Regex(pattern, flags...)

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

julia> @chain df begin
  @mutate(across((b, startswith("c")), (minimum, maximum)))
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
function parse_tidy(tidy_expr::Union{Expr, Symbol, Number}; autovec::Bool = true, subset::Bool = false, from_across::Bool = false) # Can be symbol or expression
  if @capture(tidy_expr, across(vars_, funcs_))
    return parse_across(vars, funcs)
  elseif @capture(tidy_expr, -(start_index_:end_index_))
    if start_index isa Symbol
      start_index = QuoteNode(start_index)
    end
    if end_index isa Symbol
    end_index = QuoteNode(end_index)
    end
    return :(Not(Between($start_index, $end_index)))
  elseif @capture(tidy_expr, -start_index_)
    if start_index isa Symbol
      start_index = QuoteNode(start_index)
    end
    return :(Not($start_index))
  elseif @capture(tidy_expr, start_index_:end_index_)
    if start_index isa Symbol
      start_index = QuoteNode(start_index)
    end
    if end_index isa Symbol
    end_index = QuoteNode(end_index)
    end
    return :(Between($start_index, $end_index))
  elseif @capture(tidy_expr, (lhs_ = fn_(args__)) | (lhs_ = fn_.(args__)))
    if length(args) == 0
      lhs = QuoteNode(lhs)
      return :($fn => $lhs)
    else
      @capture(tidy_expr, lhs_ = rhs_)
      return parse_function(lhs, rhs; autovec, subset)
    end
  elseif @capture(tidy_expr, lhs_ = rhs_)
    lhs = QuoteNode(lhs)
    rhs = QuoteNode(rhs)
    return :($rhs => $lhs)
  elseif !subset & @capture(tidy_expr, fn_(args__)) # selection helpers
    if from_across || fn == :Cols # fn == :Cols is to deal with interpolated columns
      return tidy_expr
    else
      return :(Cols($(esc(tidy_expr))))
    end
  elseif @capture(tidy_expr, var_Symbol)
    return QuoteNode(var)
  # elseif @capture(tidy_expr, df_expr)
  #  return df_expr
  elseif subset
    return parse_function(:ignore, tidy_expr; autovec, subset)
  else
    return tidy_expr
    # return :($(esc(tidy_expr)))
    # Do not throw error because multiple functions within across() where some are anonymous require this condition
    # throw("Expression not recognized by parse_tidy()")
  end
end

# Not exported
function parse_function(lhs::Symbol, rhs::Expr; autovec::Bool = true, subset::Bool = false)
  
  lhs = QuoteNode(lhs)
  
  src = Symbol[]
  MacroTools.postwalk(rhs) do x
    if @capture(x, (fn_(args__)) | (fn_.(args__)))
      args = args[isa.(args, Symbol)]
      push!(src, args...)
    end
    return x
  end
  
  src = unique(src)
  func_left = :($(src...),)

  if autovec
    rhs = parse_autovec(rhs)
  end

  rhs = parse_escape_function(rhs) # ensure that functions in user space are available

  if subset
    return :($src => ($func_left -> coalesce.($rhs, false))) # to ensure that missings are replace by false
  else
    return :($src => ($func_left -> $rhs) => $lhs)
  end
end

# Not exported
function parse_across(vars::Union{Expr, Symbol}, funcs::Union{Expr, Symbol})
  
  src = Union{Expr, QuoteNode}[] # type can be either a QuoteNode or a expression containing a selection helper function

  if vars isa Symbol
    src = push!(src, QuoteNode(vars))
  elseif @capture(vars, fn_(args__)) # selection helpers
    push!(src, esc(vars))
  else
    @capture(vars, (args__,))
    for arg in args
      if arg isa Symbol
        push!(src, QuoteNode(arg))
      elseif @capture(arg, fn_(args__)) # selection helpers
        push!(src, esc(arg))
      else
        push!(src, parse_tidy(arg))
      end
    end
  end

  func_array = Union{Expr, Symbol}[] # expression containing functions

  if funcs isa Symbol
    push!(func_array, funcs)
  elseif @capture(funcs, (args__,))
    for arg in args
      if arg isa Symbol
        push!(func_array, esc(arg))
      else
        push!(func_array, esc(parse_tidy(arg; from_across = true))) # fixes bug with compound and anonymous functions getting wrapped in Cols()
      end
    end
  else # for compound functions like mean or anonymous functions
    push!(func_array, esc(funcs))
  end

  num_funcs = length(func_array)

  return :(Cols($(src...)) .=> reshape([$(func_array...)], 1, $num_funcs))
end

# Not exported
function parse_desc(tidy_expr::Union{Expr, Symbol})
  tidy_expr = parse_interpolation(tidy_expr)
  if @capture(tidy_expr, Cols(args__)) # from parse_interpolation
    return :(Cols($(args...),))
  elseif @capture(tidy_expr, desc(var_))
    var = QuoteNode(var)
    return :(order($var, rev = true))
  else
    return QuoteNode(tidy_expr)
  end
end

# Not exported
function parse_group_by(tidy_expr::Union{Expr, Symbol})
  tidy_expr = parse_interpolation(tidy_expr)
  if @capture(tidy_expr, Cols(args__)) # from parse_interpolation
    return :(Cols($(args...),))
  elseif @capture(tidy_expr, lhs_ = rhs_)
    return QuoteNode(lhs)
  else
    return QuoteNode(tidy_expr)
  end
end

# Not exported
function parse_autovec(tidy_expr::Union{Expr, Symbol})
  autovec_expr = MacroTools.postwalk(tidy_expr) do x
    @capture(x, fn_(args__)) || return x
    if fn in [:Cols :(:) :∘ :across :desc :mean :std :var :median :first :last :minimum :maximum :sum :length :skipmissing :quantile :passmissing :startswith :contains :endswith]
      return x
    elseif contains(string(fn), r"[^\W0-9]\w*$") # valid variable name
      return :($fn.($(args...)))
    elseif startswith(string(fn), ".") # already vectorized operator
      return x
    else # operator
      fn_new = Symbol("." * string(fn))
      return :($fn_new($(args...)))
    end
  end
  return autovec_expr
end

# Not exported
function parse_escape_function(rhs_expr::Union{Expr, Symbol})
  rhs_expr = MacroTools.postwalk(rhs_expr) do x
    if @capture(x, fn_(args__))
      if fn in [:Cols :(:) :∘ :across :desc :mean :std :var :median :first :last :minimum :maximum :sum :length :skipmissing :quantile :passmissing :startswith :contains :endswith]
        return x
      elseif contains(string(fn), r"[^\W0-9]\w*$") # valid variable name
        return :($(esc(fn))($(args...)))
      else
        return x
      end
    elseif @capture(x, fn_.(args__))
      if fn in [:(:) :∘ :across :desc :mean :std :var :median :first :last :minimum :maximum :sum :length :skipmissing :quantile :passmissing :startswith :contains :endswith]
        return x
      elseif contains(string(fn), r"[^\W0-9]\w*$") # valid variable name
        return :($(esc(fn)).($(args...)))
      else
        return x
      end
    end
    return x
  end
  return rhs_expr
end

# Not exported
function parse_interpolation(var_expr::Union{Expr, Symbol, Number})
  var_expr = MacroTools.postwalk(var_expr) do x
    if @capture(x, !!variable_Symbol)
      variable = Main.eval(variable)
      if variable isa AbstractString
        return Symbol(variable)
      elseif variable isa Symbol
        return variable
      else # Tuple or Vector of columns
        variable = QuoteNode.(variable)
        return :(Cols($(variable...),))
      end
    end
    return x
  end
  return var_expr
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

julia> @chain df begin
  @select(contains("b"), startswith("c"))
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
  tidy_exprs = parse_interpolation.(exprs)
  tidy_exprs = parse_tidy.(tidy_exprs)
  df_expr = quote   
    select($(esc(df)), $(tidy_exprs...))
  end
  @info MacroTools.prettify(df_expr)
  return df_expr
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
  tidy_exprs = parse_interpolation.(exprs)
  tidy_exprs = parse_tidy.(tidy_exprs)
  df_expr = quote   
    select($(esc(df)), $(tidy_exprs...))
  end
  @info MacroTools.prettify(df_expr)
  return df_expr
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
  tidy_exprs = parse_interpolation.(exprs)
  tidy_exprs = parse_tidy.(tidy_exprs)
  df_expr = quote   
    rename($(esc(df)), $(tidy_exprs...))
  end
  @info MacroTools.prettify(df_expr)
  return df_expr
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
  tidy_exprs = parse_interpolation.(exprs)
  tidy_exprs = parse_tidy.(tidy_exprs)
  df_expr = quote   
    transform($(esc(df)), $(tidy_exprs...))
  end
  @info MacroTools.prettify(df_expr)
  return df_expr
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
  tidy_exprs = parse_interpolation.(exprs)
  tidy_exprs = parse_tidy.(tidy_exprs; autovec = false)
  df_expr = quote   
    combine($(esc(df)), $(tidy_exprs...))
  end
  @info MacroTools.prettify(df_expr)
  return df_expr
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
  tidy_exprs = parse_interpolation.(exprs)
  tidy_exprs = parse_tidy.(tidy_exprs; autovec = false)
  df_expr = quote   
    combine($(esc(df)), $(tidy_exprs...))
  end
  @info MacroTools.prettify(df_expr)
  return df_expr
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
  tidy_exprs = parse_interpolation.(exprs)
  tidy_exprs = parse_tidy.(tidy_exprs; subset = true)
  df_expr = quote   
    subset($(esc(df)), $(tidy_exprs...))
  end
  @info MacroTools.prettify(df_expr)
  return df_expr
end

"""
    @group_by(df, exprs...)

Return a `GroupedDataFrame` where operations are performed by groups specified by unique 
sets of `cols`.

# Arguments
- `df`: A DataFrame.
- `exprs...`: DataFrame columns to group by or tidy expressions. Can be a single tidy expression or multiple expressions separated by commas.

# Examples
```julia-repl
  julia> using DataFrames

  julia> df = DataFrame(a = repeat('a':'e', inner = 2), b = 1:10, c = 11:20)
  
  julia> @chain df begin
    @group_by(a)
    @summarize(b = mean(b))
    end

  julia> @chain df begin
    @group_by(d = uppercase(a))
    @summarize(b = mean(b))
    end
```
"""
macro group_by(df, exprs...)
  # Group
  tidy_exprs = parse_interpolation.(exprs)
  tidy_exprs = parse_tidy.(tidy_exprs)
  grouping_exprs = parse_group_by.(exprs)  
  
  df_expr = quote   
    groupby(transform($(esc(df)), $(tidy_exprs...)), Cols($(grouping_exprs...)))
  end
  @info MacroTools.prettify(df_expr)
  return df_expr
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

julia> @chain df begin
  @group_by(a)
  @slice(1)
  end
```         
"""
macro slice(df, exprs...)
  original_indices = [eval.(exprs)...]
  clean_indices = Int64[]
  for index in original_indices
    if index isa Number
      push!(clean_indices, index)
    else
      append!(clean_indices, collect(index))
    end
  end
  clean_indices = unique(clean_indices)

  if all(clean_indices .> 0)
    df_expr = quote   
      select(subset(transform($(esc(df)), eachindex => :Tidier_row_number), 
      :Tidier_row_number => x -> (in.(x, Ref($clean_indices)))),
      Not(:Tidier_row_number))
    end
  elseif all(clean_indices .< 0)
    clean_indices = -clean_indices
    df_expr = quote 
    select(subset(transform($(esc(df)), eachindex => :Tidier_row_number), 
    :Tidier_row_number => x -> (.!in.(x, Ref($clean_indices)))),
    Not(:Tidier_row_number))
    end
  else
    throw("@slice() indices must either be all positive or all negative.")
  end

  @info MacroTools.prettify(df_expr)
  return df_expr  
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
  arrange_exprs = parse_desc.(exprs)
  df_expr = quote   
    sort($(esc(df)), [$(arrange_exprs...)]) # Must use [] instead of Cols() here
  end
  @info MacroTools.prettify(df_expr)
  return df_expr
end

end