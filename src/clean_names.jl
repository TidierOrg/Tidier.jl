macro clean_names(df, case)
    df_expr = quote
        if $case != "snake_case" && $case != "camelCase"
            throw("`case` must be either \"snake_case\" or \"camelCase\".")
        end

        local style = Symbol($case)

        if $(esc(df)) isa GroupedDataFrame
            local col_names = groupcols($(esc(df)))

            @chain $(esc(df)) begin
                DataFrame # remove grouping
                polish_names(_; style=style)
                DataFrame # convert back to DataFrame
                groupby(col_names; sort=true) # regroup
            end
        else
            @chain $(esc(df)) begin
                polish_names(_; style=style)
                DataFrame # convert back to DataFrame
            end
        end
    end
    return df_expr
end

macro clean_names(df)
    df_expr = quote
        if $(esc(df)) isa GroupedDataFrame
            local col_names = groupcols($(esc(df)))

            @chain $(esc(df)) begin
                DataFrame # remove grouping
                polish_names
                DataFrame # convert back to DataFrame
                groupby(col_names; sort=true) # regroup
            end
        else
            @chain $(esc(df)) begin
                polish_names
                DataFrame # convert back to DataFrame
            end
        end
    end
    return df_expr
end
