# `across()` is a helper function that is typically used inside `@mutate()` or `@summarize` to operate on multiple columns and/or multiple functions. Notice that `across()` accepts two arguments, a set of variables and a set of functions. If providing multiple variables or functions, these should be provided as a tuple -- in other words, wrapped in parentheses and separated by commas. If you want to skip missing values, you can "fuse" the summary function (such as `mean()`) with the `skipmissing()` function by using the fuction fusion operator, which you can type out in Julia by typing `\circ` and then pressing `[Tab]` such that it reads `mean∘skipmissing`.

using Tidier
using RDatasets

movies = dataset("ggplot2", "movies");

# ## One variable, one function

@chain movies begin
  @mutate(Budget = Budget / 1_000_000)
  @summarize(across(Budget, mean∘skipmissing))
end

# ## One variable, one anonymous function

@chain movies begin
  @mutate(Budget = Budget / 1_000_000)
  @summarize(across(Budget, (x -> mean(skipmissing(x)))))
end

# Note: compound functions are not correctly supported inside of anonymous functions. As of right now, the above function works, but `(x -> mean∘skipmissing(x))` does not work. This is a known bug and will be fixed in a future update.

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