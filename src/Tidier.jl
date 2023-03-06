module Tidier

using DataFrames
using MacroTools
using Chain
using Statistics
using Reexport

# Exporting `Cols` because `summarize(across(!!vars, funs))` with multiple interpolated
# columns requires `Cols()` to be nested within `Cols()`, so `Cols` needs to be exported.
@reexport using DataFrames: DataFrame, Cols, describe, nrow, proprow
@reexport using Chain
@reexport using Statistics

export Tidier_set, across, desc, starts_with, ends_with, matches, @select, @transmute, @rename, @mutate, @summarize, @summarise, @filter, @group_by, @ungroup, @slice, @arrange, @pull, @left_join, @right_join, @inner_join, @full_join

# Package global variables
const code = Ref{Bool}(false) # output DataFrames.jl code?
const log = Ref{Bool}(false) # output tidylog output? (not yet implemented)

# Includes
include("docstrings.jl")
include("parsing.jl")
include("joins.jl")

# Function to set global variables
"""
$docstring_Tidier_set
"""
function Tidier_set(option::AbstractString, value::Bool)
  if option == "code"
    code[] = value
  elseif option == "log"
    throw("Logging is not enabled yet")
  else
    throw("That is not a valid option.")
  end
end

# Need to expand with docs
# These are just aliases
starts_with(args...) = startswith(args...)
ends_with(args...) = endswith(args...)
matches(pattern, flags...) = Regex(pattern, flags...)

"""
$docstring_across
"""
function across(args...)
  throw("This function should only be called inside of @mutate(), @summarize, or @summarise.")
end

"""
$docstring_desc
"""
function desc(args...)
  throw("This function should only be called inside of @arrange().")
end

"""
$docstring_select
"""
macro select(df, exprs...)
  tidy_exprs = parse_interpolation.(exprs)
  tidy_exprs = parse_tidy.(tidy_exprs)
  df_expr = quote
    if $(esc(df)) isa GroupedDataFrame
      select($(esc(df)), $(tidy_exprs...); ungroup = false)
    else
      select($(esc(df)), $(tidy_exprs...))
    end
  end
  if code[]
    @info MacroTools.prettify(df_expr)
  end
  return df_expr
end

"""
$docstring_transmute
"""
macro transmute(df, exprs...)
  tidy_exprs = parse_interpolation.(exprs)
  tidy_exprs = parse_tidy.(tidy_exprs)
  df_expr = quote
    if $(esc(df)) isa GroupedDataFrame
      select($(esc(df)), $(tidy_exprs...); ungroup = false)
    else
      select($(esc(df)), $(tidy_exprs...))
    end
  end
  if code[]
    @info MacroTools.prettify(df_expr)
  end
  return df_expr
end

"""
$docstring_rename
"""
macro rename(df, exprs...)
  tidy_exprs = parse_interpolation.(exprs)
  tidy_exprs = parse_tidy.(tidy_exprs)
  df_expr = quote
    if $(esc(df)) isa GroupedDataFrame
      rename($(esc(df)), $(tidy_exprs...); ungroup = false)
    else
      rename($(esc(df)), $(tidy_exprs...))
    end
  end
  if code[]
    @info MacroTools.prettify(df_expr)
  end
  return df_expr
end

"""
$docstring_mutate
"""
macro mutate(df, exprs...)
  tidy_exprs = parse_interpolation.(exprs)
  tidy_exprs = parse_tidy.(tidy_exprs)
  df_expr = quote
    if $(esc(df)) isa GroupedDataFrame
      transform($(esc(df)), $(tidy_exprs...); ungroup = false)
    else
      transform($(esc(df)), $(tidy_exprs...))
    end
  end
  if code[]
    @info MacroTools.prettify(df_expr)
  end
  return df_expr
end

"""
$docstring_summarize
"""
macro summarize(df, exprs...)
  tidy_exprs = parse_interpolation.(exprs)
  tidy_exprs = parse_tidy.(tidy_exprs; autovec=false)
  df_expr = quote
    if $(esc(df)) isa GroupedDataFrame
      col_names = groupcols($(esc(df)))
      if length(col_names) == 1
        combine($(esc(df)), $(tidy_exprs...); ungroup = true)
      else
        @chain $(esc(df)) begin
          combine($(tidy_exprs...); ungroup = true)
          groupby(col_names[1:end-1]; sort = true)
        end
      end
    else
      combine($(esc(df)), $(tidy_exprs...))
    end
  end
  if code[]
    @info MacroTools.prettify(df_expr)
  end
  return df_expr
end

"""
$docstring_summarize
"""
macro summarise(df, exprs...)
  :(@summarize($(esc(df)), $(exprs...)))
end

"""
$docstring_filter
"""
macro filter(df, exprs...)
  tidy_exprs = parse_interpolation.(exprs)
  tidy_exprs = parse_tidy.(tidy_exprs; subset=true)
  df_expr = quote
    if $(esc(df)) isa GroupedDataFrame
      subset($(esc(df)), $(tidy_exprs...); ungroup = false)
    else
      subset($(esc(df)), $(tidy_exprs...))
    end
  end
  if code[]
    @info MacroTools.prettify(df_expr)
  end
  return df_expr
end

"""
$docstring_group_by
"""
macro group_by(df, exprs...)
  # Group
  tidy_exprs = parse_interpolation.(exprs)
  tidy_exprs = parse_tidy.(tidy_exprs)
  grouping_exprs = parse_group_by.(exprs)

  df_expr = quote
    @chain $(esc(df)) begin
      transform($(tidy_exprs...))
      groupby(Cols($(grouping_exprs...)); sort = true)
    end
  end
  if code[]
    @info MacroTools.prettify(df_expr)
  end
  return df_expr
end

"""
$docstring_ungroup
"""
macro ungroup(df)
  :(DataFrame($(esc(df))))
end

"""
$docstring_slice
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
      if $(esc(df)) isa GroupedDataFrame
        @chain $(esc(df)) begin
          transform(eachindex => :Tidier_row_number; ungroup = false)
          subset(:Tidier_row_number => x -> (in.(x, Ref($clean_indices))); ungroup = false)
          select(Not(:Tidier_row_number); ungroup = false)
        end
      else
        @chain $(esc(df)) begin
          transform(eachindex => :Tidier_row_number)
          subset(:Tidier_row_number => x -> (in.(x, Ref($clean_indices))))
          select(Not(:Tidier_row_number))
        end
      end
    end
  elseif all(clean_indices .< 0)
    clean_indices = -clean_indices
    df_expr = quote
      if $(esc(df)) isa GroupedDataFrame
        @chain $(esc(df)) begin
          transform(eachindex => :Tidier_row_number; ungroup = false)
          subset(:Tidier_row_number => x -> (.!in.(x, Ref($clean_indices))); ungroup = false)
          select(Not(:Tidier_row_number); ungroup = false)
        end
      else
        @chain $(esc(df)) begin
          transform(eachindex => :Tidier_row_number)
          subset(:Tidier_row_number => x -> (.!in.(x, Ref($clean_indices))))
          select(Not(:Tidier_row_number))
        end
      end
    end
  else
    throw("@slice() indices must either be all positive or all negative.")
  end

  if code[]
    @info MacroTools.prettify(df_expr)
  end
  return df_expr
end

"""
$docstring_arrange
"""
macro arrange(df, exprs...)
  arrange_exprs = parse_desc.(exprs)
  df_expr = quote
    if $(esc(df)) isa GroupedDataFrame
      col_names = groupcols($(esc(df)))
      
      @chain $(esc(df)) begin
        DataFrame # remove grouping
        sort([$(arrange_exprs...)]) # Must use [] instead of Cols() here
        groupby(col_names; sort = true) # regroup
      end
    else
      sort($(esc(df)), [$(arrange_exprs...)]) # Must use [] instead of Cols() here
    end
  end
  if code[]
    @info MacroTools.prettify(df_expr)
  end
  return df_expr
end

"""
$docstring_pull
"""
macro pull(df, column)
  column = parse_interpolation(column)
  column = parse_tidy(column)
  vec_expr = quote
    $(esc(df))[:, $column]
  end
  if code[]
    @info MacroTools.prettify(vec_expr)
  end
  return vec_expr
end

end