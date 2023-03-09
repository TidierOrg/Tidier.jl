"""
$docstring_pivot_wider
"""
macro pivot_wider(df, exprs...)
    # take the expressions and return arg => value dictionary    
    tidy_exprs = parse_interpolation.(exprs)
    tidy_exprs = parse_pivot_args.(tidy_exprs)
    expr_dict = Dict(x.args[2] => x.args[3] for x in tidy_exprs)

    df_expr = quote
        unstack(DataFrame($(esc(df))), 
            $(expr_dict[QuoteNode(:names_from)]),
            $(expr_dict[QuoteNode(:values_from)]))
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
    tidy_exprs = parse_interpolation.(exprs)
    tidy_exprs = parse_pivot_args.(tidy_exprs)
    expr_dict = Dict(x.args[2] => x.args[3] for x in tidy_exprs)

    if !haskey(expr_dict, QuoteNode(:(names_to))) && !haskey(expr_dict, QuoteNode(:(values_to)))
        df_expr = quote
            stack(DataFrame($(esc(df))), $(expr_dict[QuoteNode(:cols)]))
        end
    elseif (haskey(expr_dict, QuoteNode(:(names_to))) && haskey(expr_dict, QuoteNode(:(values_to))))
        df_expr = quote
            stack(DataFrame($(esc(df))), 
                $(expr_dict[QuoteNode(:cols)]),
                variable_name = $(expr_dict[QuoteNode(:names_to)]),
                value_name = $(expr_dict[QuoteNode(:values_to)]))
        end
    elseif haskey(expr_dict, QuoteNode(:(names_to)))
        df_expr = quote
            stack(DataFrame($(esc(df))), 
                $(expr_dict[QuoteNode(:cols)]),
                variable_name = $(expr_dict[QuoteNode(:names_to)]))
        end
    elseif haskey(expr_dict, QuoteNode(:(values_to)))
        df_expr = quote
            stack(DataFrame($(esc(df))), 
                $(expr_dict[QuoteNode(:cols)]),
                value_name = $(expr_dict[QuoteNode(:values_to)]))
        end
    end

    if code[]
        @info MacroTools.prettify(df_expr)
    end
    
    return df_expr
end
