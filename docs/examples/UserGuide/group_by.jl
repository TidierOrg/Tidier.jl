# Grouping and ungrouping behavior is one of the nicest parts of using R's tidyverse. Once a data frame is grouped, *all* verbs applied to that data frame respect the grouping, including but not limited to `@mutate()`, `@summarize()`, `@slice()` and `@filter`, which allows for really powerful abstractions. For example, with `@group_by()` followed by `@filter()`, you can limit the rows of a dataset to the maximum or minimum values for each group.

# Exactly as in R's `tidyverse`, once a data frame is grouped, it remains grouped until either `@summarize()` is called (which "peels off" one layer of grouping) or `@ungroup()` is called, which removes all layers of grouping. Also as in R's `tidyverse`, `@group_by()` sorts the groups in ascending order. Unlike in R, there is never any question about whether a data frame is currently grouped because GroupedDataFrames print out in a *very* different form than DataFrames, making them easy to tell apart.

# When using `@chain`, note that you can write either `@ungroup` or `@ungroup()`. Both are considered valid.

using Tidier
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
    @summarize(
        Mean_Yearly_Rating = mean(skipmissing(Rating)),
        Median_Yearly_Rating = median(skipmissing(Rating))
    )
    @slice(1:5)
end

# ## Grouping by multiple columns

@chain movies begin
    @group_by(Year, Comedy)
    @summarize(
        Mean_Yearly_Rating = mean(skipmissing(Rating)),
        Median_Yearly_Rating = median(skipmissing(Rating))
    )
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
