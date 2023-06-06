# Filtering is a mechanism to indicate which rows you want to keep in a dataset based on criteria. This is also referred to as subsetting. Filtering rows is normally a bit tricky in `DataFrames.jl` because comparison operators like `>=` actually need to be vectorized as `.>=`, which can catch new Julia users by surprise. `@filter()` mimics R's `tidyverse` behavior by auto-vectorizing the code and then only selecting those rows that evaluate to `true`. Similar to `dplyr`, rows that evaluate to `missing` are skipped.

using Tidier
using RDatasets

movies = dataset("ggplot2", "movies");

# ## Let’s take a look at the movies whose budget was more than average. We will select only the first 5 rows for the sake of brevity.

@chain movies begin
  @mutate(Budget = Budget / 1_000_000)
  @filter(Budget >= mean(skipmissing(Budget)))
  @select(Title, Budget)
  @slice(1:5)
end

# ## Let's search for movies that have at least 200 votes and a rating of greater than or equal to 8. There are 3 ways you can specify an "and" condition inside of `Tidier.jl`.

# ### The first option is to use the short-circuiting `&&` operator as shown below. This is the preferred approach because the second expression is only evaluated (per element) if the first one is true.

@chain movies begin
  @filter(Votes >= 200 && Rating >= 8)
  @select(Title, Votes, Rating)
  @slice(1:5)
end

# ### The second option is to use the bitwise `&` operator. Note that there is a key difference in syntax between `&` and `&&`. Because the `&` operator takes a higher operator precedence than `>=`, you have to wrap the comparison expressions inside of parentheses to ensure that the overall expression is evaluated correctly.

@chain movies begin
  @filter((Votes >= 200) & (Rating >= 8))
  @select(Title, Votes, Rating)
  @slice(1:5)
end

# ### The third option for "and" conditions only is to separate the expressions with commas. This is similar to the behavior of `filter()` in `tidyverse`.

@chain movies begin
  @filter(Votes >= 200, Rating >= 8)
  @select(Title, Votes, Rating)
  @slice(1:5)
end

# ## Now let's see how to use `@filter()` with `in`. Here's an example with a tuple.

@chain movies begin
  @filter(Title in ("101 Dalmatians",
                    "102 Dalmatians"))
  @select(1:5)
end

# ## We can also use `@filter()` with `in` using a vector, denoted by a `[]`.

@chain movies begin
  @filter(Title in ["101 Dalmatians",
                    "102 Dalmatians"])
  @select(1:5)
end

# ## Finally, we can combine `@filter` with `row_number()` to retrieve the first 5 rows, which can be used to mimic the functionality provided by `@slice`.

@chain movies begin
  @filter(row_number() <= 5)
  @select(1:5)
end