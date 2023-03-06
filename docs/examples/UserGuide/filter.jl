# Filtering is a mechanism to indicate which rows you want to keep in a dataset based on criteria. This is also referred to as subsetting. Filtering rows is normally a bit tricky in `DataFrames.jl` because comparison operators like `>=` actually need to be vectorized as `.>=`, which can catch new Julia users by surprise. `@filter()` mimics R's `tidyverse` behavior by auto-vectorizing the code and then only selecting those rows that evaluate to `true`. Similar to `dplyr`, rows that evaluate to `missing` are skipped.

using Tidier
using RDatasets

movies = dataset("ggplot2", "movies");

# Let’s take a look at the movies whose budget was more than average. We will select only the first 5 rows for the sake of brevity.

@chain movies begin
    @mutate(Budget = Budget / 1_000_000)
    @filter(Budget >= mean(skipmissing(Budget)))
    @select(Title, Budget)
    @slice(1:5)
end

# Now let's see how to use `@filter()` with `in`. Here's an example with a tuple.

@chain movies begin
  @filter(Title in ("101 Dalmatians", "102 Dalmatians"))
  @select(1:5)
end

# We can also use `@filter()` with `in` using a vector, denoted by a `[]`.

@chain movies begin
  @filter(Title in ["101 Dalmatians", "102 Dalmatians"])
  @select(1:5)
end
