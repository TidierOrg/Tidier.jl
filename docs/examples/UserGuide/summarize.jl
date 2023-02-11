using Tidier
using DataFrames
using RDatasets

movies = dataset("ggplot2", "movies");
# Both @summarize and @summarise can be used.
df_summ = @chain movies begin
    @filter(!ismissing(Budget))
    @summarize(nrow = length(Title))
end