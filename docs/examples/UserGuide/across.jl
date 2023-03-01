using Tidier
using RDatasets

movies = dataset("ggplot2", "movies");

# `across()` can be used with either `@mutate` or `@summarize` to operate on multiple
# columns and/or multiple functions.

# ## One variable, one function

@chain movies begin
  @mutate(Budget = Budget / 1_000_000)
  @summarize(across(Budget, mean∘skipmissing))
end

# ## One variable, one anonymous function

# Note: compound functions are not correctly supported inside of anonymous functions. As of right now, `(x -> mean∘skipmissing(x))` does not work. This is a known bug and will be fixed in a future update.

@chain movies begin
  @mutate(Budget = Budget / 1_000_000)
  @summarize(across(Budget, (x -> mean(skipmissing(x)))))
end

# ## Multiple variables, multiple functions

@chain movies begin
    @mutate(Budget = Budget / 1_000_000)
    @summarize(across((Rating, Budget), (mean∘skipmissing, median∘skipmissing)))
end

# ## Multiple selection helpers, multiple functions

@chain movies begin
  @mutate(Budget = Budget / 1_000_000)
  @summarize(across((starts_with("Bud"), ends_with("ting")), (mean∘skipmissing, median∘skipmissing)))
end