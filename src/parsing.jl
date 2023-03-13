# Not exported
function parse_tidy(tidy_expr::Union{Expr,Symbol,Number}; autovec::Bool=true, subset::Bool=false, from_across::Bool=false) # Can be symbol or expression
  if @capture(tidy_expr, across(vars_, funcs_))
    return parse_across(vars, funcs)
  elseif @capture(tidy_expr, -(startindex_:endindex_) | !(startindex_:endindex_))
    if startindex isa Symbol
      startindex = QuoteNode(startindex)
    end
    if endindex isa Symbol
      endindex = QuoteNode(endindex)
    end
    return :(Not(Between($startindex, $endindex)))
  elseif @capture(tidy_expr, startindex_:endindex_)
    if startindex isa Symbol
      startindex = QuoteNode(startindex)
    end
    if endindex isa Symbol
      endindex = QuoteNode(endindex)
    end
    return :(Between($startindex, $endindex))
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
  elseif @capture(tidy_expr, -var_Symbol)
    var = QuoteNode(var)
    return :(Not($var))
  elseif @capture(tidy_expr, !var_Symbol)
    var = QuoteNode(var)
    return :(Not($var))
  elseif @capture(tidy_expr, var_Symbol)
    return QuoteNode(var)
  elseif @capture(tidy_expr, var_Number)
    if var > 0
      return :(Not($var))
    elseif var < 0
      var = -var
      return :(Not($var))
    else
      throw("Numeric selections cannot be zero.")
    end
  elseif @capture(tidy_expr, !var_Number)
    return :(Not($var))
  elseif !subset & @capture(tidy_expr, -fn_(args__)) # negated selection helpers
    return :(Cols(!($(esc(fn))($(args...))))) # change the `-` to a `!` and return
  elseif !subset & @capture(tidy_expr, fn_(args__)) # selection helpers
    if from_across || fn == :Cols # fn == :Cols is to deal with interpolated columns
      return tidy_expr
    else
      return :(Cols($(esc(tidy_expr))))
    end
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
function parse_pivot_args(tidy_expr::Union{Expr,Symbol,Number})
  if @capture(tidy_expr, lhs_ = rhs_)
    lhs = QuoteNode(lhs)
    rhs = QuoteNode(rhs)
    return :($lhs => $rhs)
  else
    tidy_expr = parse_tidy(tidy_expr)
    return :(:cols => $(tidy_expr))
  end
end

# Not exported
function parse_function(lhs::Symbol, rhs::Expr; autovec::Bool=true, subset::Bool=false)

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
    return :($src => ($func_left -> $rhs)) # to ensure that missings are replace by false
  else
    return :($src => ($func_left -> $rhs) => $lhs)
  end
end

# Not exported
function parse_across(vars::Union{Expr,Symbol}, funcs::Union{Expr,Symbol})

  src = Union{Expr,QuoteNode}[] # type can be either a QuoteNode or a expression containing a selection helper function

  if vars isa Symbol
    push!(src, QuoteNode(vars))
  elseif @capture(vars, fn_(args__)) # selection helpers
    if fn == :!
      push!(src, parse_tidy(vars))
    else
      push!(src, esc(vars))
    end
  else
    @capture(vars, (args__,))
    for arg in args
      if arg isa Symbol
        push!(src, QuoteNode(arg))
      elseif @capture(arg, fn_(args__)) # selection helpers
        if fn == :!
          push!(src, parse_tidy(arg)) 
        else
          push!(src, esc(arg))
        end
      else
        push!(src, parse_tidy(arg))
      end
    end
  end

  func_array = Union{Expr,Symbol}[] # expression containing functions

  if funcs isa Symbol
    push!(func_array, esc(funcs)) # fixes bug where single function is used inside across
  elseif @capture(funcs, (args__,))
    for arg in args
      if arg isa Symbol
        push!(func_array, esc(arg))
      else
        push!(func_array, esc(parse_tidy(arg; from_across=true))) # fixes bug with compound and anonymous functions getting wrapped in Cols()
      end
    end
  else # for compound functions like mean or anonymous functions
    push!(func_array, esc(funcs))
  end

  num_funcs = length(func_array)

  return :(Cols($(src...)) .=> reshape([$(func_array...)], 1, $num_funcs))
end

# Not exported
function parse_desc(tidy_expr::Union{Expr,Symbol})
  tidy_expr = parse_interpolation(tidy_expr)
  if @capture(tidy_expr, Cols(args__)) # from parse_interpolation
    return :(Cols($(args...),))
  elseif @capture(tidy_expr, desc(var_))
    var = QuoteNode(var)
    return :(order($var, rev=true))
  else
    return QuoteNode(tidy_expr)
  end
end

# Not exported
function parse_join_by(tidy_expr::Union{Expr,Symbol,String})
  tidy_expr = parse_interpolation(tidy_expr)
  
  src = Union{Expr,QuoteNode}[] # type can be either a QuoteNode or a expression containing a selection helper function

  if @capture(tidy_expr, expr_Symbol)
    push!(src, QuoteNode(expr))
  elseif @capture(tidy_expr, expr_String)
    push!(src, QuoteNode(Symbol(expr)))
  elseif @capture(tidy_expr, lhs_Symbol = rhs_Symbol)
    lhs = QuoteNode(lhs)
    rhs = QuoteNode(rhs)
    push!(src, :($lhs => $rhs))
  elseif @capture(tidy_expr, lhs_String = rhs_String)
    lhs = QuoteNode(Symbol(lhs))
    rhs = QuoteNode(Symbol(rhs))
    push!(src, :($lhs => $rhs))
  else
    @capture(tidy_expr, (args__,))
    for arg in args
      if @capture(arg, expr_Symbol)
        push!(src, QuoteNode(expr))
      elseif @capture(arg, expr_String)
        push!(src, QuoteNode(Symbol(expr)))
      elseif @capture(arg, lhs_Symbol = rhs_Symbol)
        lhs = QuoteNode(lhs)
        rhs = QuoteNode(rhs)
        push!(src, :($lhs => $rhs))
      elseif @capture(arg, lhs_String = rhs_String)
        lhs = QuoteNode(Symbol(lhs))
        rhs = QuoteNode(Symbol(rhs))
        push!(src, :($lhs => $rhs))
      else
        push!(src, QuoteNode(arg))
      end
    end
  end
 
  return :([$(src...)]) 
end

# Not exported
function parse_group_by(tidy_expr::Union{Expr,Symbol})
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
function parse_autovec(tidy_expr::Union{Expr,Symbol})

  # Use postwalk so that we capture smallest expressions first.
  # In the future, may want to consider switching to prewalk() so that we can 
  # capture the largest expression first and functions haven't already been vectorized first.
  # Because prewalk() can result in infinite loops, would require lots of careful testing.
  autovec_expr = MacroTools.postwalk(tidy_expr) do x

    # don't vectorize if starts with ~ (compound function)
    # The reason we have a . is that bc this is postwalk, the function will first have been 
    # vectorized, and we need to unvectorize it.
    # Adding the non-vectorized condition in case a non-vectorized function like mean is accidentally
    # prefixed with a ~.
    if @capture(x, (~fn1_ ∘ fn2_.(args__)) | (~fn1_ ∘ fn2_(args__)))
      return :($fn1 ∘ $fn2($(args...)))

      # Don't vectorize if starts with ~ (regular function)
      # The reason we have a . is that bc this is postwalk, the function will first have been 
      # vectorized, and we need to unvectorize it.
      # Adding the non-vectorized condition in case a non-vectorized function like mean is accidentally
      # prefixed with a ~.
    elseif @capture(x, (~fn_.(args__)) | (~fn_(args__)))
      return :($fn($(args...)))

      # Don't vectorize if starts with ~ (operator) e.g., a ~+ b
    elseif @capture(x, args1_ ~ fn_(args2_))
      # We need to remove the . from the start bc was already vectorized and we need to 
      # unvectorize it
      fn_new = Symbol(string(fn)[2:end])
      return :($fn_new($args1, $args2))
    
    # If user already does Ref(Set(arg2)), then vectorize and leave as-is
    elseif @capture(x, in(arg1_, Ref(Set(arg2_))))
        return :(in.($arg1, Ref(Set($arg2))))
    
    # If user already does Ref(arg2), then wrap arg2 inside of a Set().
    # Set requires additional allocation but is much faster.
    # See: https://bkamins.github.io/julialang/2023/02/10/in.html
    elseif @capture(x, in(arg1_, Ref(arg2_)))
      return :(in.($arg1, Ref(Set($arg2))))
    
    # If user already does Set(arg2), then wrap this inside of Ref().
    # This is required to prevent vectorization of arg2.
    elseif @capture(x, in(arg1_, Set(arg2_))) 
      return :(in.($arg1, Ref(Set($arg2))))
    
    # If user did provides bare vector or tuple for arg2, then wrap
    # arg2 inside of a Ref(Set(arg2))
    # This is required to prevent vectorization of arg2.
    elseif @capture(x, in(arg1_, arg2_))
      return :(in.($arg1, Ref(Set($arg2))))

    # Handle ∈
    elseif @capture(x, ∈(arg1_, Ref(Set(arg2_))))
      return :((∈).($arg1, Ref(Set($arg2))))
    elseif @capture(x, ∈(arg1_, Ref(arg2_)))
      return :((∈).($arg1, Ref(Set($arg2))))
    elseif @capture(x, ∈(arg1_, Set(arg2_)))
      return :((∈).($arg1, Ref(Set($arg2))))
    elseif @capture(x, ∈(arg1_, arg2_))
      return :((∈).($arg1, Ref(Set($arg2))))

  # Handle ∉
    elseif @capture(x, ∉(arg1_, Ref(Set(arg2_))))
      return :((∉).($arg1, Ref(Set($arg2))))
    elseif @capture(x, ∉(arg1_, Ref(arg2_)))
      return :((∉).($arg1, Ref(Set($arg2))))
    elseif @capture(x, ∉(arg1_, Set(arg2_)))
      return :((∉).($arg1, Ref(Set($arg2))))
    elseif @capture(x, ∉(arg1_, arg2_))
      return :((∉).($arg1, Ref(Set($arg2))))

    elseif @capture(x, fn_(args__))

      # `in` should be vectorized so do not add to this exclusion list
      if fn in [:Ref :Set :Cols :(:) :∘ :across :desc :mean :std :var :median :first :last :minimum :maximum :sum :length :skipmissing :quantile :passmissing :startswith :contains :endswith]
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
    return x
  end
  return autovec_expr
end

# Not exported
function parse_escape_function(rhs_expr::Union{Expr,Symbol})
  rhs_expr = MacroTools.postwalk(rhs_expr) do x
    if @capture(x, fn_(args__))

      # `in`, `∈`, and `∉` should be vectorized in auto-vec but not escaped
      if fn in [:in :∈ :∉ :Ref :Set :Cols :(:) :∘ :across :desc :mean :std :var :median :first :last :minimum :maximum :sum :length :skipmissing :quantile :passmissing :startswith :contains :endswith]
        return x
      elseif contains(string(fn), r"[^\W0-9]\w*$") # valid variable name
        return :($(esc(fn))($(args...)))
      else
        return x
      end
    elseif @capture(x, fn_.(args__))
      if fn in [:in :∈ :∉ :Ref :Set :Cols :(:) :∘ :across :desc :mean :std :var :median :first :last :minimum :maximum :sum :length :skipmissing :quantile :passmissing :startswith :contains :endswith]
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
# String is for parse_join_by
function parse_interpolation(var_expr::Union{Expr,Symbol,Number,String})
  var_expr = MacroTools.postwalk(var_expr) do x
    if @capture(x, !!variable_Symbol)
      variable = Main.eval(variable)
      if variable isa AbstractString
        return variable # Strings are now treated as Strings and not columns
      elseif variable isa Symbol
        return variable
      else # Tuple or Vector of columns
        if variable[1] isa Symbol
          variable = QuoteNode.(variable)
          return :(Cols($(variable...),))
        else
          return variable
        end
      end
    end
    return x
  end
  return var_expr
end