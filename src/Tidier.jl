module Tidier

export TD, DB, write_file

using Reexport

# Leave this in place for consistent behavior with TidierDB
@reexport import TidierData
const TD = TidierData

@reexport using TidierPlots
@reexport using TidierCats
@reexport using TidierDates

# Leave this in place for backward compatibility
@reexport import TidierDB
const DB = TidierDB

@reexport using TidierFiles
@reexport using TidierStrings
@reexport using TidierText
@reexport using TidierVest
@reexport using TidierIteration

import TidierData, TidierDB, TidierFiles

# export functions and macros in TidierData but not in TidierDB
for fun_or_macro in setdiff(names(TidierData), names(TidierDB))
    @eval @reexport using TidierData: $fun_or_macro
end

# export functions and macros in TidierData but not in TidierDB
for fun_or_macro in setdiff(names(TidierDB), names(TidierData))
    if fun_or_macro == :write_file || # will export Tidier.jl version
        fun_or_macro == :DuckDBException # not implemented so generates an error if included
        continue
    end
    @eval @reexport using TidierDB: $fun_or_macro
end

# For all functions/macros in both packages (`string.(intersect(names(TidierDB), names(TidierData)))`),
# each will need to be manually defined and exported here.
@reexport using TidierData: DataFrame, @chain

# Export macros where TidierData and TidierDB names intersect
# except for `@chain`, which we will only export from TidierData
macros_intersect =  filter(x -> startswith(x, "@") && x != "@chain", string.(intersect(names(TidierDB), names(TidierData))))
macros_two_table = filter(x -> contains(x, "_join"), macros_intersect)
macros_one_table = setdiff(macros_intersect, macros_two_table)

# Export all overlapping (intersecting) macros
for fun_or_macro in Symbol.(macros_intersect)
    @eval export $fun_or_macro
end

# Define dispatch for one-table macros (only first argument is escaped)
for func in [Symbol(mac[2:end]) for mac in macros_one_table] # remove the "@" from the macro name
    global fn = func 
    @eval begin
        @doc fn == :summarise ? "" : """
        $($(Expr(:., :TidierData, QuoteNode(Symbol("docstring_" * string(fn))))))

        $($(Expr(:., :TidierDB, QuoteNode(Symbol("docstring_" * string(fn))))))
        """
        macro $(fn)(df_or_db, args...)
            quote
                if $(esc(df_or_db)) isa TidierData.AbstractDataFrame || $(esc(df_or_db)) isa TidierData.GroupedDataFrame
                    $(Expr(:macrocall,
                        Expr(:.,
                            :TidierData,
                            QuoteNode(Symbol("@" * $(string(fn))))
                        ),
                        LineNumberNode(0, Symbol("")),
                        esc(df_or_db),
                        args...)
                    )
                elseif $(esc(df_or_db)) isa TidierDB.SQLQuery
                    $(Expr(:macrocall,
                        Expr(:.,
                            :TidierDB,
                            QuoteNode(Symbol("@" * $(string(fn))))
                        ),
                        LineNumberNode(0, Symbol("")),
                        esc(df_or_db),
                        args...)
                    )
                else
                    @error string(typeof($(esc(df_or_db)))) * " is not a supported data structure."
                end
            end
        end
    end
end

# Define dispatch for two-table macros (first and second argument are escaped)
for func in [Symbol(mac[2:end]) for mac in macros_two_table] # remove the "@" from the macro name
    global fn = func
    @eval begin
        @doc """
        $($(Expr(:., :TidierData, QuoteNode(Symbol("docstring_" * string(fn))))))

        $($(Expr(:., :TidierDB, QuoteNode(Symbol("docstring_" * string(fn))))))
        """
        macro $(fn)(df_or_db1, df_or_db2, args...)
            quote
                if $(esc(df_or_db1)) isa TidierData.AbstractDataFrame || $(esc(df_or_db1)) isa TidierData.GroupedDataFrame
                    $(Expr(:macrocall,
                        Expr(:.,
                            :TidierData,
                            QuoteNode(Symbol("@" * $(string(fn))))
                        ),
                        LineNumberNode(0, Symbol("")),
                        esc(df_or_db1),
                        esc(df_or_db2),
                        args...)
                    )
                elseif $(esc(df_or_db1)) isa TidierDB.SQLQuery
                    $(Expr(:macrocall,
                        Expr(:.,
                            :TidierDB,
                            QuoteNode(Symbol("@" * $(string(fn))))
                        ),
                        LineNumberNode(0, Symbol("")),
                        esc(df_or_db1),
                        esc(df_or_db2),
                        args...)
                    )
                else
                    @error string(typeof($(esc(df_or_db1)))) * " is not a supported data structure."
                end
            end
        end
    end
end

"""
$(TidierDB.docstring_write_file)
"""
function TidierFiles.write_file(df_or_db::SQLQuery, file_name, args...)
    # Extend the TidierFiles definition of `write_file` to dispatch to TidierDB for SQLQuery
    TidierDB.write_file(df_or_db, file_name, args...)
end

end