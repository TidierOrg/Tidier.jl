module Tidier

using Reexport

@reexport using TidierData
@reexport using TidierPlots
@reexport using TidierCats
@reexport using TidierDates

@reexport import TidierDB
const DB = TidierDB

@reexport using TidierFiles
@reexport using TidierStrings
@reexport using TidierText
@reexport using TidierVest

using TidierData: DataFrame, @chain, @pull
using TidierDB: connect, db_table, @collect, DuckDB, duckdb, @show_query, t, copy_to

const TD = TidierData

include("dispatch.jl")

export DataFrame, @chain, @pull, connect, db_table, @collect, DuckDB,
       @mutate, @left_join, @filter, @group_by, @select, @arrange , duckdb, @show_query, t, copy_to

end