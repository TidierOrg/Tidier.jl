# Summarizing a dataset involves aggregating multiple rows down to (usually) a single row of data. This can be performed across the entire dataset, or if the dataset is grouped, then for each row in the dataset. This is implemented similarly to R's tidyverse using `@summarize()`. Out of admiration for Hadley Wickham, and to be consistent with the R `tidyverse`, both `@summarize()` and `@summarise()` are supported.

# Note that summarization is different from other verbs in the `Tidier.jl` in 2 respects:

# 1. No auto-vectorization is performed when using `@summarize()`
# 2. One layer of grouping is removed after each `@summarize()` function.

# If you require further changes to grouping beyond the defaults, you can either `@ungroup()` or call `@group_by()` to regroup by a different set of variables.

using Tidier
using RDatasets

movies = dataset("ggplot2", "movies");

# ## Using `@summarize()` with `n()` to count the number of movies in the dataset.

# Within the context of `@summarize()` only, `n()` is converted to DataFrames.jl's `nrow()` function.

@chain movies begin
    @summarize(n = n())
end

# ## Using `@summarize()` to calculate average budget of movies in the dataset.

# The median budget in this dataset is $3 million, and the mean budget is $13 million! Making movies must be way more lucrative than making Julia packages.

@chain movies begin
  @mutate(Budget = Budget / 1_000_000)
  @summarize(median_budget = median(skipmissing(Budget)),
             mean_budget = mean(skipmissing(Budget)))
end

# ## Combining `@group_by()` with `@summarise()`

# How many movies came out in each of the last 5 years?

@chain movies begin
  @group_by(Year)
  @summarise(n = n())
  @arrange(desc(Year))
  @slice(1:5)
end

# Notice that there was no need to explicitly `@ungroup()` the dataset after summarizing here. The `@summarise()` function removed one layer of grouping. Since this dataset was only grouped by one variable (`Year`), it was no longer grouped after the `@summarise` was performed.