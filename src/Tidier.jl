module Tidier

using DataFrames
using MacroTools
using Reexport

@reexport using Statistics

export @select, @transmute, @rename, @mutate, @summarize, @summarise, @filter, @group_by

# Write your package code here.
macro autovec(df, fn_name, exprs...)

  if fn_name == "groupby"
    return :(groupby($(esc(df)), Symbol.($[exprs...])))
  end

  tp = tuple(exprs...)

  arr_calls = String[]

  for expr in tp
 
    if (fn_name == "subset")
      expr = :(ignore = $expr)
    end

    arr_rhs = String[]  
 
    new_expr = MacroTools.postwalk(expr) do x
      @capture(x, fn_(ex__)) || return x
        push!(arr_rhs, join([ex...], ";"))
        if !(fn in [:mean :median :first :last :minimum :maximum :sum :length :skipmissing])
        # println(:($fn.($(ex...))))
          return :($fn.($(ex...)))
        else
          return x
        end
    end

    if length(arr_rhs) == 0
      MacroTools.postwalk(expr) do x
        @capture(x, a_ = b_) || return x
          push!(arr_rhs, string(b))
      end
    end

    arr_lhs = String[]
    
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
        push!(arr_calls, arr_rhs_symbols * " .=> :" * arr_lhs) # vectorize bc array to scalar
      elseif (fn_name == "subset")
        push!(arr_calls, arr_rhs_symbols * " => ((" * join(arr_rhs, ",") * ") -> " * fn_body * ")")
      else
        push!(arr_calls, arr_rhs_symbols * " => ((" * join(arr_rhs, ",") * ") -> " * fn_body * ") => :" * arr_lhs)
      end
    else
      selection_match = match.(r"(-?)\(?\(?([^\W0-9]\w*)(:?)([^\W0-9]\w*)?\)?\)?", string(expr))
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

  # fn_call = "$fn_name($df, " *  join(arr_calls, ",") * ")"
  # Meta.parse(fn_call)
  return_val = quote
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

end