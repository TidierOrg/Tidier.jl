# Compound verbs refer to macros that primarily wrap other core macros in this package.
# This includes verbs like `@count()` and `@tally`. For compound verbs, any relevant parsing
# functions should be bundled after the macro instead of being placed in parsing.jl.

macro tally(df, exprs...)
  wt, sort = parse_tally_args(exprs...)

  wt_quoted = QuoteNode(wt)

  df_expr = quote
    @chain $(esc(df)) begin
      @chain _ begin
        if isnothing($wt_quoted)
          @summarize(_, n = n())
        else
          @summarize(_, n = sum(skipmissing($wt)))
        end
      end
      @chain _ begin
        if $sort == true
          @arrange(_, desc(n))
        else
          _
        end
      end  
    end
  end
  return df_expr
end

function parse_tally_args(tidy_exprs::Union{Expr,Symbol}...)
  wt = nothing
  sort = false
  
  for tally_expr in tidy_exprs
    if @capture(tally_expr, wt = arg_)
      wt = arg
    elseif @capture(tally_expr, sort = arg_)
      sort = arg
    else
      throw("The only supported arguments are `wt` and `sort`, and both must be named.")
    end
  end
  return wt, sort 
end


macro count(df, exprs...)
  col_names, wt, sort = parse_count_args(exprs...)

  col_names_quoted = QuoteNode(col_names)
  wt_quoted = QuoteNode(wt)

  df_expr = quote
    @chain $(esc(df)) begin
      @chain _ begin
        if length($col_names_quoted) > 0
          @group_by(_, $(col_names...))
        else
          _
        end
      end
      @chain _ begin
        if isnothing($wt_quoted)
          @summarize(_, n = n())
        else
          @summarize(_, n = sum(skipmissing($wt)))
        end
      end
      @chain _ begin
        if $sort == true
          @arrange(_, desc(n))
        else
          _
        end
      end
      @ungroup
    end
  end
  return df_expr
end

function parse_count_args(tidy_exprs::Union{Expr,Symbol}...)
  col_names = Union{Expr,Symbol}[]
  wt = nothing
  sort = false
  
  for count_expr in tidy_exprs
    if @capture(count_expr, wt = arg_)
      wt = arg
    elseif @capture(count_expr, sort = arg_)
      sort = arg
    elseif @capture(count_expr, lhs_ = rhs_)
      throw("The only supported arguments are `wt` and `sort`, and both must be named.")
    else
      push!(col_names, count_expr)
    end
  end
  return col_names, wt, sort 
end