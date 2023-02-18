using Tidier
using DataFrames
using RDatasets

movies = dataset("ggplot2", "movies");

# ## Combining `@group_by()` with `@mutate()`
@chain movies begin
    @group_by(Year)
    @mutate(Mean_Yearly_Rating = mean(skipmissing(Rating)))
    @select(Year, Rating, Mean_Yearly_Rating)
    @slice(1:5)
end

# ## Combining @group_by() with @summarize()
@chain movies begin
    @group_by(Year)
    @summarize(Mean_Yearly_Rating = mean(skipmissing(Rating)),
        Median_Yearly_Rating = median(skipmissing(Rating)))
    @slice(1:5)
end
