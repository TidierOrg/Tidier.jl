using Tidier
using DataFrames
using RDatasets

movies = dataset("ggplot2", "movies");

# Let’s take a look at the movies whose budget was more than average.
# While it’s easy in R to do this all wthin a single `@filter()` statement,
# this requires a bit more work in Julia because the `>=` operator generates
# an error when it receives missing values. I am considering possible workarounds.

df_filter = @chain movies begin
    @mutate(Budget = Budget / 1_000_000)
    @filter(!ismissing(Budget))
    @filter(Budget >= mean(skipmissing(Budget)))
    @select(Title, Budget)
end
first(df_filter, 5)