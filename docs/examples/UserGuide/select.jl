# The `@select()` macro in `Tidier.jl` supports many of the nuances of the R `tidyverse` implementation, including indexing columns individually by name or number, indexing by ranges of columns using the `:` operator between column names or numbers, and negative selection using negated column names or numbers. Selection helpers such as `starts_with()`, `ends_with()`, `matches()`, and `contains()` are also supported.

using Tidier
using RDatasets

movies = dataset("ggplot2", "movies");

# ## Select the first 5 columns individually by name

@chain movies begin
    @select(Title, Year, Length, Budget, Rating)
    @slice(1:5)
end

# ## Select the first 5 columns individually by number

@chain movies begin
    @select(1, 2, 3, 4, 5)
    @slice(1:5)
end

# ## Select the first 5 columns by name (using a range)

@chain movies begin
    @select(Title:Rating)
    @slice(1:5)
end

# ## Select the first 5 columns by number (using a range)

@chain movies begin
    @select(1:5)
    @slice(1:5)
end

# ## Select all but the first 5 columns by name

# Here we will limit the results to the first 5 remaining columns and the first 5 rows for the sake of brevity.

@chain movies begin
    @select(-(Title:Rating))
    @select(1:5)
    @slice(1:5)
end

# We can also use `!` for inverted selection instead of `-`.

@chain movies begin
  @select(!(Title:Rating))
  @select(1:5)
  @slice(1:5)
end

# ## Select all but the first 5 columns by number

# We will again limit the results to the first 5 remaining columns and the first 5 rows for the sake of brevity.

@chain movies begin
    @select(-(1:5))
    @select(1:5)
    @slice(1:5)
end

# ## Mix and match selection

# Just like in R's `tidyverse`, you can separate multiple selections with commas and mix and match different ways of selecting columns.

@chain movies begin
    @select(1, Budget:Rating)
    @slice(1:5)
end