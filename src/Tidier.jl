module Tidier

using DataFrames
using MacroTools
using Chain
using Statistics
using Cleaner
using Reexport

# Exporting `Cols` because `summarize(!!vars, funs))` with multiple interpolated
# columns requires `Cols()` to be nested within `Cols()`, so `Cols` needs to be exported.
@reexport using DataFrames: DataFrame, Cols, describe, nrow, proprow
@reexport using Chain
@reexport using Statistics
@reexport using ShiftedArrays: lag, lead

export Tidier_set, across, desc, n, row_number, starts_with, ends_with, matches, if_else, case_when, ntile, 
      @select, @transmute, @rename, @mutate, @summarize, @summarise, @filter, @group_by, @ungroup, @slice, 
      @arrange, @distinct, @pull, @left_join, @right_join, @inner_join, @full_join, @pivot_wider, @pivot_longer, 
      @bind_rows, @bind_cols, @clean_names, @count, @tally, @drop_na, @glimpse, @relocate

# Package global variables
const code = Ref{Bool}(false) # output DataFrames.jl code?
const log = Ref{Bool}(false) # output tidylog output? (not yet implemented)

# Includes
include("docstrings.jl")
include("parsing.jl")
include("joins.jl")
include("binding.jl")
include("pivots.jl")
include("compound_verbs.jl")
include("clean_names.jl")
include("conditionals.jl")
include("pseudofunctions.jl")
include("helperfunctions.jl")
include("ntile.jl")

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
      local col_names = groupcols($(esc(df)))
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
          if length(col_names) == 1
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
  df_expr = quote
    local interpolated_indices = parse_slice_n.($exprs, nrow(DataFrame($(esc(df)))))
    local original_indices = [eval.(interpolated_indices)...]
    local clean_indices = Int64[]
    for index in original_indices
      if index isa Number
        push!(clean_indices, index)
      else
        append!(clean_indices, collect(index))
      end
    end
    
    if all(clean_indices .> 0)
      if $(esc(df)) isa GroupedDataFrame
        combine($(esc(df)); ungroup = false) do sdf
          sdf[clean_indices, :]
        end
      else
        combine($(esc(df))) do sdf
          sdf[clean_indices, :]
        end
      end
    elseif all(clean_indices .< 0)
      clean_indices = -clean_indices
      if $(esc(df)) isa GroupedDataFrame
        combine($(esc(df)); ungroup = true) do sdf
          sdf[Not(clean_indices), :]
        end
      else
        combine($(esc(df))) do sdf
          sdf[Not(clean_indices), :]
        end
      end
    else
      throw("@slice() indices must either be all positive or all negative.")
    end
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
      local col_names = groupcols($(esc(df)))
      
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
$docstring_distinct
"""
macro distinct(df, exprs...)
  interpolated_exprs = parse_interpolation.(exprs)

  tidy_exprs = [i[1] for i in interpolated_exprs]
  any_found_n = any([i[2] for i in interpolated_exprs])
  any_found_row_number = any([i[3] for i in interpolated_exprs])

  tidy_exprs = parse_tidy.(tidy_exprs)
  df_expr = quote
    if $(esc(df)) isa GroupedDataFrame
      local col_names = groupcols($(esc(df)))
      @chain $(esc(df)) begin
        DataFrame # remove grouping because `unique()` does not work on GroupDataFrames
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
        unique($(tidy_exprs...))
        select(Cols(Not(r"^(Tidier_n|Tidier_row_number)$")))
        groupby(col_names; sort = true) # regroup
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
        unique($(tidy_exprs...))
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

macro glimpse(df)
  df_expr = quote
    local des_df = describe($(esc(df)), :eltype, :mean, :min, :median, :max, :nmissing; cols=:)
    show(des_df, allrows=true)
  end
  if code[]
    @info MacroTools.prettify(df_expr)
  end
  return df_expr
end

"""
$docstring_drop_na
"""
macro drop_na(df, exprs...)
  interpolated_exprs = parse_interpolation.(exprs)

  tidy_exprs = [i[1] for i in interpolated_exprs]

  tidy_exprs = parse_tidy.(tidy_exprs)
  num_exprs = length(exprs)
  df_expr = quote
    if $(esc(df)) isa GroupedDataFrame
      local col_names = groupcols($(esc(df)))
      @chain $(esc(df)) begin
        DataFrame # remove grouping because `dropmissing()` does not work on GroupDataFrames
        @chain _ begin
          if $num_exprs == 0
            dropmissing(_)
          else
            dropmissing(_, Cols($(tidy_exprs...)))
          end
        end
        groupby(col_names; sort = true) # regroup
      end
    else
      @chain $(esc(df)) begin
        @chain _ begin
          if $num_exprs == 0
            dropmissing(_)
          else
            dropmissing(_, Cols($(tidy_exprs...)))
          end
        end
      end
    end


macro relocate(df, exprs...)
  interpolated_exprs = parse_interpolation.(exprs)
  relocate_exprs = [i[1] for i in interpolated_exprs]
  col_names, before, after = parse_relocate_args(relocate_exprs...)

  col_names = parse_tidy.(col_names)
  if !(before isa Nothing)
    before_expr = parse_tidy(before)
    df_expr = quote
      relocate($(esc(df)), $(col_names...), before=$before_expr)
    end
  elseif !(after isa Nothing)
    after_expr = parse_tidy(after)
    df_expr = quote
      relocate($(esc(df)), $(col_names...), after=$after_expr)
    end
  elseif after isa Nothing && before isa Nothing
    df_expr = quote
      relocate($(esc(df)), $(col_names...))
    end
  end
  return df_expr
end

function relocate(df, cols...; before=nothing, after=nothing)
  println(cols)
  println(before)
  cols_names = reduce(vcat, names.(Ref(df), cols))
  cols_idx = columnindex.(Ref(df), cols_names)
  if !(before isa Nothing)
    before_names = reduce(vcat, names.(Ref(df), (before,)))
    before_idx = columnindex.(Ref(df), before_names)  
    if df isa GroupedDataFrame
      return select(df, setdiff(1:minimum(before_idx)-1, cols_idx), cols_idx, before_idx, :; ungroup = false)
    else
      return select(df, setdiff(1:minimum(before_idx)-1, cols_idx), cols_idx, before_idx, :)
    end
  elseif !(after isa Nothing)
    after_names = reduce(vcat, names.(Ref(df), (after,)))
    after_idx = columnindex.(Ref(df), after_names)
    if df isa GroupedDataFrame
      return select(df, setdiff(1:maximum(after_idx), cols_idx), after_idx, cols_idx, :; ungroup = false)
    else
      return select(df, setdiff(1:maximum(after_idx), cols_idx), after_idx, cols_idx, :)
    end
  elseif after isa Nothing && before isa Nothing
    if df isa GroupedDataFrame 
      return select(df, cols_idx, :; ungroup = false)
    else
      return select(df, cols_idx, :)
    end
  end
end

end

using DataFrames
using MacroTools

df1 = DataFrame(a=1:3, b=1:3, c=4:6, d=4:6, e=7:9, f1=["7", "8","9"], f2=7:9);

@glimpse(df1)

@relocate(df1, d)
@relocate(df1, d, f)
@relocate(df1, f1, before =a)
@relocate(df1, f, before =(b,c))
@relocate(df1, contains("f"), after = a:c)
@relocate(df1, f1, before =contains("b"))

a = names.(Ref(df1), (:d, :f))
columnindex.(Ref(df1), [a...])



