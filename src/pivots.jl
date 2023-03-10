"""
$docstring_pivot_wider
"""
macro pivot_wider(df, exprs...)
    # take the expressions and return arg => value dictionary    
    tidy_exprs = parse_interpolation.(exprs)
    tidy_exprs = parse_pivot_args.(tidy_exprs)
    expr_dict = Dict(x.args[2] => x.args[3] for x in tidy_exprs)

    # we need to define a dictionary 
    # to hold arguments in the format expected by unstack()
    arg_dict = Dict{Symbol, Any}()

    if haskey(expr_dict, QuoteNode(:values_fill))
        arg_dict[:fill] = String(eval(expr_dict[QuoteNode(:values_fill)]))
    end

    df_expr = quote
        unstack(DataFrame($(esc(df))), 
            $(expr_dict[QuoteNode(:names_from)]),
            $(expr_dict[QuoteNode(:values_from)]);
            $(arg_dict)...)
    end

    if code[]
        @info MacroTools.prettify(df_expr)
    end

    return(df_expr)
end

"""
$docstring_pivot_longer
"""
macro pivot_longer(df, exprs...)
    # take the expressions and return arg => value dictionary 
    tidy_exprs = parse_interpolation.(exprs)
    tidy_exprs = parse_pivot_args.(tidy_exprs)
    expr_dict = Dict(x.args[2] => x.args[3] for x in tidy_exprs)

    # we need to define a dictionary 
    # to hold arguments in the format expected by stack()
    arg_dict = Dict{Symbol, Any}()

    # if names_to was specified, pass that argument to variable_name
    if haskey(expr_dict, QuoteNode(:names_to))
        arg_dict[:variable_name] = eval(expr_dict[QuoteNode(:names_to)])
    end

    # if values_to was specified, pass that argument to value_name
    if haskey(expr_dict, QuoteNode(:values_to))
        arg_dict[:value_name] = eval(expr_dict[QuoteNode(:values_to)])
    end

    # splat any specified arguments in to stack()
    df_expr = quote
        stack(DataFrame($(esc(df))), $(expr_dict[QuoteNode(:cols)]); $(arg_dict)...)
    end

    if code[]
        @info MacroTools.prettify(df_expr)
    end
    
    return df_expr
end

