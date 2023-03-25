# Slicing rows is similar to filtering rows, except that slicing is performed based on row numbers rather tha filter criteria. In `Tidier.jl`, slicing works similarly to R's `tidyverse` in that both positive (which rows to keep) and negative (which rows to remove) slicing is supported. For `@slice()`, any valid `UnitRange` of integers is considered valid; this is not the case for `@select()` or `across()`.

# Remember: Just like every other `Tidier.jl` top-level macro, `@slice()` respects group. This means that in a grouped data frame, `@slice(1:2)` will select the first 2 rows *from each group*.

using Tidier

df = DataFrame(;
  row_num=1:10, a=string.(repeat('a':'e'; inner=2)), b=[1, 1, 1, 2, 2, 2, 3, 3, 3, 4]
)

# ## Slicing using a range of numbers

# This is an easy way of retrieving 5 consecutive rows.

@chain df begin
  @slice(1:5)
end

# ## Slicing using a more complex UnitRange of numbers

# How would we obtain every other from 1 to 7 (counting up by 2)? Note that `range()` is similar to `seq()` in R.

@chain df begin
  @slice(range(start=1, step=2, stop=7))
end

# This same code can also be written using Julia's shorthand syntax for unit ranges.

@chain df begin
  @slice(1:2:7)
end

# ## Separate multiple row selections with commas

# If you have multiple different row selections, you can separate them with commas.

@chain df begin
  @slice(1:5, 10)
end

# ## Use `n()` as short-hand to indicate the number of rows

# Select the last 2 rows.

@chain df begin
  @slice(n() - 1, n())
end

# You can even use `n()` inside of UnitRanges, just like in R. Notice that the order of operations is slightly different in Julia as compared to R, so you don't have to wrap the `n()-1` expression inside of parentheses.

@chain df begin
  @slice((n() - 1):n())
end

# ## Inverted selection using negative numbers

# This line selects all rows except the first 5 rows.

@chain df begin
  @slice(-(1:5))
end
