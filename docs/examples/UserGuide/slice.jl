# Slicing rows is similar to filtering rows, except that slicing is performed based on row numbers rather tha filter criteria. In `Tidier.jl`, slicing works similarly to R's `tidyverse` in that both positive (which rows to keep) and negative (which rows to remove) slicing is supported. For `@slice()`, any valid `UnitRange` of integers is considered valid; this is not the case for `@select()` or `across()`.

# Remember: Just like every other `Tidier.jl` top-level macro, `@slice()` respects group. This means that in a grouped data frame, `@slice(1:2)` will select the first 2 rows *from each group*.

using Tidier
using RDatasets

movies = dataset("ggplot2", "movies");

# ## Slicing using a range of numbers

# This is an easy way of retrieving 5 consecutive rows.

@chain movies begin
    @slice(1:5)
    @select(1:5)
end

# ## Slicing using a more complex UnitRange of numbers

# How would we obtain every other from 1 to 7 (counting up by 2)? Note that `range()` is similar to `seq()` in R.

@chain movies begin
  @slice(range(start = 1, step = 2, stop = 7))
  @select(1:5)
end

# This same code can also be written using Julia's shorthand syntax for unit ranges.

@chain movies begin
  @slice(1:2:7)
  @select(1:5)
end


# ## Separate multiple row selections with commas

# If you have multiple different row selections, you can separate them with commas.

@chain movies begin
    @slice(1:5, 10)
    @select(1:5)
end

# ## Inverted selection using negative numbers

# This line selects all rows except the first 5 rows. For the sake of brevity, we are only showing the first 5 of the remaining results.

@chain movies begin
    @slice(-(1:5))
    @select(1:5)
    @slice(1:5)
end