module Tidier

using DataFrames
import DataFramesMeta
using MacroTools: postwalk, @capture

export @autovec, @mutate, @select

# Write your package code here.
macro autovec(expr)
  new_expr = postwalk(expr) do x
    @capture(x, fn_(ex__)) || return x
      if !(fn in [:mean :median :first :last :minimum :maximum])
        # println(:($fn.($(ex...))))
        return :($fn.($(ex...)))
      else
        return x
      end
    end
  # println(new_expr)
  new_expr
end

macro mutate(df, expr)
  quote
    DataFramesMeta.@transform($df, @autovec($expr))
  end
end

macro select(df, expr)
  quote
    DataFramesMeta.@select($df, @autovec($expr))
  end
end

end
