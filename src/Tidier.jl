module Tidier

using DataFrames
using MacroTools
using Chain
using Reexport

@reexport using Chain
@reexport using Statistics

export @select, @transmute, @rename, @mutate, @summarize, @summarise, @filter, @group_by, @slice, @arrange

# Non-exported helper functions
# across(), desc()

macro autovec(df, fn_name, exprs...)

  if fn_name == "groupby"
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
          
          vars_clean = "[" * join(vars_clean, ", ") * "]"

          fns_clean = string(ex[2])
          fns_clean = split(fns_clean, ", ")
          fns_clean = replace.(fns_clean, r"^\(" => s"")
          for i in eachindex(fns_clean)
            if occursin(r"\)$", fns_clean[i]) && !occursin(r"\(", fns_clean[i])
              fns_clean[i] = replace(fns_clean[i], r"\)$" => s"")
            end
          end
          fns_clean = "[" * join(fns_clean, " ") * "]"

          push!(arr_calls, vars_clean * " .=> " * fns_clean)
          check_if_across = true
        elseif fn_name == "combine" || (fn in [:mean :median :first :last :minimum :maximum :sum :length :skipmissing :quantile :passmissing :startswith :contains :endswith])
          return x
        else
          return :($fn.($(ex...)))
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
        return(x)
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

  fn_call = "$fn_name($df, " *  join(arr_calls, ",") * ")"
  
  # @info fn_call

  # Meta.parse(fn_call)

  return_val = quote

    # Ultimately we need to remove this eval() because this limits the use of functions
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


macro select(df, exprs...)
  quote
    @autovec($(esc(df)), "select", $(exprs...))
  end
end

macro transmute(df, exprs...)
  quote
    @autovec($(esc(df)), "select", $(exprs...))
  end
end

macro rename(df, exprs...)
  quote
    @autovec($(esc(df)), "rename", $(exprs...))
  end
end

macro mutate(df, exprs...)
  quote
    @autovec($(esc(df)), "transform", $(exprs...))
  end
end

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

macro filter(df, exprs...)
  quote
    @autovec($(esc(df)), "subset", $(exprs...))
  end
end

macro group_by(df, exprs...)
  quote
    @autovec($(esc(df)), "groupby", $(exprs...))
  end
end

macro slice(df, exprs...)
  quote
    indices = [$(exprs...)]
    try
      # @info indices
      if (all(indices .< 0))
        # return_string = "$df[Not(" * string(-indices) * "), :]"
        return_value = $(esc(df))[Not(-indices), :]
      else
        # return_string = "$df[" * string(indices) * ", :]"
        return_value = $(esc(df))[indices, :]
      end
    catch e
      # @info indices
      local indices = reduce(vcat, collect.(indices))  
      if (all(indices .< 0))
        # return_string = "$df[Not(" * string(-indices) * "), :]"
        return_value = $(esc(df))[Not(-indices), :]
      else
        # return_string = "$df[" * string(indices) * ", :]"
        return_value = $(esc(df))[indices, :]
      end

      # @info return_string
      return return_value
    end
  end
end

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

  return_val = quote
    arr_eval_calls = eval.(Meta.parse.($arr_calls))
    sort($(esc(df)), [arr_eval_calls...])
  end
  return_val
end

end