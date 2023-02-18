using Tidier
using DataFrames
using RDatasets

movies = dataset("ggplot2", "movies");
# ## Sort both in ascending order

@chain movies begin
  @arrange(Year, Rating)
  @select(1:5)
  @slice(1:5)
end

# ## Sort in a mix of ascending and descending order
# ### `desc`
@chain movies begin
  @arrange(Year, desc(Rating))
  @select(1:5)
  @slice(1:5)
end

# ### `across`

# `across()` can be used with either `@mutate` or `@summarize` to operate on multiple
# columns and/or multiple functions.

# #### One variable, one function
@chain movies begin
  @mutate(Budget = Budget / 1_000_000)
  @summarize(across(Budget, mean∘skipmissing))
end

# #### One variable, one anonymous function
@chain movies begin
  @mutate(Budget = Budget / 1_000_000)
  @summarize(across(Budget, (x -> mean(skipmissing(x)))))
end

# #### Multiple variables, multiple functions

@chain movies begin
    @mutate(Budget = Budget / 1_000_000)
    @summarize(across((Rating, Budget), (mean∘skipmissing, median∘skipmissing)))
end