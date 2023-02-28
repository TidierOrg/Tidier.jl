using Tidier
using DataFrames
using RDatasets

movies = dataset("ggplot2", "movies");

# ## Combining `@group_by()` with `@mutate()`

@chain movies begin
    @group_by(Year)
    @mutate(Mean_Yearly_Rating = mean(skipmissing(Rating)))
    @select(Year, Rating, Mean_Yearly_Rating)
    @ungroup
    @slice(1:5)
end

# ## Combining @group_by() with @summarize()

@chain movies begin
    @group_by(Year)
    @summarize(Mean_Yearly_Rating = mean(skipmissing(Rating)),
        Median_Yearly_Rating = median(skipmissing(Rating)))
    @slice(1:5)
end

# ## Grouping by multiple columns

@chain movies begin
  @group_by(Year, Comedy)
  @summarize(Mean_Yearly_Rating = mean(skipmissing(Rating)),
      Median_Yearly_Rating = median(skipmissing(Rating)))
  @ungroup # Need to ungroup to peel off grouping by Year
  @arrange(desc(Year), Comedy)
  @slice(1:5)
end

# ## Combining @group_by() with @filter()

@chain movies begin
    @group_by(Year)
    @filter(Rating == minimum(Rating))
    @ungroup
    @select(Year, Rating)
    @arrange(desc(Year))
    @slice(1:10)
end