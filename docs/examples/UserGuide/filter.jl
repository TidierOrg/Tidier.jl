using Tidier
using RDatasets

movies = dataset("ggplot2", "movies");

# Let’s take a look at the movies whose budget was more than average.

@chain movies begin
    @mutate(Budget = Budget / 1_000_000)
    @filter(Budget >= mean(skipmissing(Budget)))
    @select(Title, Budget)
    @slice(1:5)
end