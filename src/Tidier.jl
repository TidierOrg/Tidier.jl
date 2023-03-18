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

export Tidier_set, across, desc, starts_with, ends_with, matches, if_else, case_when, @select, @transmute, @rename, @mutate, @summarize, @summarise, @filter, @group_by, @ungroup, @slice, @arrange, @pull, @left_join, @right_join, @inner_join, @full_join, @pivot_wider, @pivot_longer

# Package global variables
const code = Ref{Bool}(false) # output DataFrames.jl code?
const log = Ref{Bool}(false) # output tidylog output? (not yet implemented)

# Includes
include("docstrings.jl")
include("parsing.jl")
include("joins.jl")
include("pivots.jl")
include("conditionals.jl")

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
  interpolated_exprs = parse_interpolation.(exprs)

  tidy_exprs = [i[1] for i in interpolated_exprs]
  any_found_n = any([i[2] for i in interpolated_exprs])
  any_found_row_number = any([i[3] for i in interpolated_exprs])

  tidy_exprs = parse_tidy.(tidy_exprs)
  df_expr = quote
    if $(esc(df)) isa GroupedDataFrame
      @chain $(esc(df)) begin
        @chain _ begin
          if $any_found_n
            transform(_, nrow => :Tidier_n; ungroup = false)
          else
            _
          end
        end
        @chain _ begin
          if $any_found_row_number
            transform(_, eachindex => :Tidier_row_number; ungroup = false)
          else
            _
          end    
        end
        select($(tidy_exprs...); ungroup = false)
        select(Cols(Not(r"^(Tidier_n|Tidier_row_number)$")); ungroup = false)
      end
    else
      @chain $(esc(df)) begin
        @chain _ begin
          if $any_found_n
            transform(_, nrow => :Tidier_n)
          else
            _
          end
        end
        @chain _ begin
          if $any_found_row_number
            transform(_, eachindex => :Tidier_row_number)
          else
            _
          end
        end
        select($(tidy_exprs...))
        select(Cols(Not(r"^(Tidier_n|Tidier_row_number)$")))
      end
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
  interpolated_exprs = parse_interpolation.(exprs)

  tidy_exprs = [i[1] for i in interpolated_exprs]
  any_found_n = any([i[2] for i in interpolated_exprs])
  any_found_row_number = any([i[3] for i in interpolated_exprs])

  tidy_exprs = parse_tidy.(tidy_exprs)
  df_expr = quote
    if $(esc(df)) isa GroupedDataFrame
      @chain $(esc(df)) begin
        @chain _ begin
          if $any_found_n
            transform(_, nrow => :Tidier_n; ungroup = false)
          else
            _
          end
        end
        @chain _ begin
          if $any_found_row_number
            transform(_, eachindex => :Tidier_row_number; ungroup = false)
          else
            _
          end    
        end
        select($(tidy_exprs...); ungroup = false)
        select(Cols(Not(r"^(Tidier_n|Tidier_row_number)$")); ungroup = false)
      end
    else
      @chain $(esc(df)) begin
        @chain _ begin
          if $any_found_n
            transform(_, nrow => :Tidier_n)
          else
            _
          end
        end
        @chain _ begin
          if $any_found_row_number
            transform(_, eachindex => :Tidier_row_number)
          else
            _
          end
        end
        select($(tidy_exprs...))
        select(Cols(Not(r"^(Tidier_n|Tidier_row_number)$")))
      end
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
  interpolated_exprs = parse_interpolation.(exprs)

  tidy_exprs = [i[1] for i in interpolated_exprs]
  any_found_n = any([i[2] for i in interpolated_exprs])
  any_found_row_number = any([i[3] for i in interpolated_exprs])

  tidy_exprs = parse_tidy.(tidy_exprs)
  df_expr = quote
    if $(esc(df)) isa GroupedDataFrame
      @chain $(esc(df)) begin
        @chain _ begin
          if $any_found_n
            transform(_, nrow => :Tidier_n; ungroup = false)
          else
            _
          end
        end
        @chain _ begin
          if $any_found_row_number
            transform(_, eachindex => :Tidier_row_number; ungroup = false)
          else
            _
          end    
        end
        rename($(tidy_exprs...); ungroup = false)
        select(Cols(Not(r"^(Tidier_n|Tidier_row_number)$")); ungroup = false)
      end
    else
      @chain $(esc(df)) begin
        @chain _ begin
          if $any_found_n
            transform(_, nrow => :Tidier_n)
          else
            _
          end
        end
        @chain _ begin
          if $any_found_row_number
            transform(_, eachindex => :Tidier_row_number)
          else
            _
          end
        end
        rename($(tidy_exprs...))
        select(Cols(Not(r"^(Tidier_n|Tidier_row_number)$")))
      end
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
  interpolated_exprs = parse_interpolation.(exprs)

  tidy_exprs = [i[1] for i in interpolated_exprs]
  any_found_n = any([i[2] for i in interpolated_exprs])
  any_found_row_number = any([i[3] for i in interpolated_exprs])

  tidy_exprs = parse_tidy.(tidy_exprs)
  df_expr = quote
    if $(esc(df)) isa GroupedDataFrame
      @chain $(esc(df)) begin
        @chain _ begin
          if $any_found_n
            transform(_, nrow => :Tidier_n; ungroup = false)
          else
            _
          end
        end
        @chain _ begin
          if $any_found_row_number
            transform(_, eachindex => :Tidier_row_number; ungroup = false)
          else
            _
          end    
        end
        transform($(tidy_exprs...); ungroup = false)
        select(Cols(Not(r"^(Tidier_n|Tidier_row_number)$")); ungroup = false)
      end
    else
      @chain $(esc(df)) begin
        @chain _ begin
          if $any_found_n
            transform(_, nrow => :Tidier_n)
          else
            _
          end
        end
        @chain _ begin
          if $any_found_row_number
            transform(_, eachindex => :Tidier_row_number)
          else
            _
          end
        end
        transform($(tidy_exprs...))
        select(Cols(Not(r"^(Tidier_n|Tidier_row_number)$")))
      end
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
  interpolated_exprs = parse_interpolation.(exprs; summarize = true)

  tidy_exprs = [i[1] for i in interpolated_exprs]
  any_found_n = any([i[2] for i in interpolated_exprs])
  any_found_row_number = any([i[3] for i in interpolated_exprs])

  tidy_exprs = parse_tidy.(tidy_exprs; autovec=false)
  df_expr = quote
    if $(esc(df)) isa GroupedDataFrame
      @chain $(esc(df)) begin
        @chain _ begin
          if $any_found_n
            transform(_, nrow => :Tidier_n; ungroup = false)
          else
            _
          end  
        end
        @chain _ begin
          if $any_found_row_number
            transform(_, eachindex => :Tidier_row_number; ungroup = false)
          else
            _
          end  
        end
        @chain _ begin
          if length(groupcols($(esc(df)))) == 1
            @chain _ begin
              combine(_, $(tidy_exprs...); ungroup = true)
              select(_, Cols(Not(r"^(Tidier_n|Tidier_row_number)$")))
            end
          else
            @chain _ begin
              combine(_, $(tidy_exprs...); ungroup = true)
              select(_, Cols(Not(r"^(Tidier_n|Tidier_row_number)$")))
              groupby(_, col_names[1:end-1]; sort = true)
            end
          end
        end
      end
    else
      @chain $(esc(df)) begin
        @chain _ begin
          if $any_found_n
            transform(_, nrow => :Tidier_n; ungroup = false)
          else
            _
          end  
        end
        @chain _ begin
          if $any_found_row_number
            transform(_, eachindex => :Tidier_row_number; ungroup = false)
          else
            _
          end  
        end
        combine($(tidy_exprs...))
        select(Cols(Not(r"^(Tidier_n|Tidier_row_number)$")))
      end
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
  interpolated_exprs = parse_interpolation.(exprs)

  tidy_exprs = [i[1] for i in interpolated_exprs]
  any_found_n = any([i[2] for i in interpolated_exprs])
  any_found_row_number = any([i[3] for i in interpolated_exprs])

  tidy_exprs = parse_tidy.(tidy_exprs; subset=true)
  df_expr = quote
    if $(esc(df)) isa GroupedDataFrame
      @chain $(esc(df)) begin
        @chain _ begin
          if $any_found_n
            transform(_, nrow => :Tidier_n; ungroup = false)
          else
            _
          end
        end
        @chain _ begin
          if $any_found_row_number
            transform(_, eachindex => :Tidier_row_number; ungroup = false)
          else
            _
          end    
        end
        subset($(tidy_exprs...); skipmissing = true, ungroup = false)
        select(Cols(Not(r"^(Tidier_n|Tidier_row_number)$")); ungroup = false)
      end
    else
      @chain $(esc(df)) begin
        @chain _ begin
          if $any_found_n
            transform(_, nrow => :Tidier_n)
          else
            _
          end
        end
        @chain _ begin
          if $any_found_row_number
            transform(_, eachindex => :Tidier_row_number)
          else
            _
          end
        end
        subset($(tidy_exprs...); skipmissing = true)
        select(Cols(Not(r"^(Tidier_n|Tidier_row_number)$")))
      end
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
  interpolated_exprs = parse_interpolation.(exprs)

  tidy_exprs = [i[1] for i in interpolated_exprs]
  any_found_n = any([i[2] for i in interpolated_exprs])
  any_found_row_number = any([i[3] for i in interpolated_exprs])

  tidy_exprs = parse_tidy.(tidy_exprs)
  grouping_exprs = parse_group_by.(exprs)

  df_expr = quote
    @chain $(esc(df)) begin
      @chain _ begin
        if $any_found_n
          transform(_, nrow => :Tidier_n)
        else
          _
        end
      end
      @chain _ begin
        if $any_found_row_number
          transform(_, eachindex => :Tidier_row_number)
        else
          _
        end
      end
      transform($(tidy_exprs...))
      select(Cols(Not(r"^(Tidier_n|Tidier_row_number)$")))
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
  column, found_n, found_row_number = parse_interpolation(column)
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