# The `@distinct()` macro in `Tidier.jl` is useful to select distinct rows. Like it's R counterpart, it can be used with or without arguments. When arguments are provided, it behaves slightly differently than the R version. Whereas the R function only returns the provided columns, the Tidier.jl version returns all columns, where the first match is returned for the non-selected columns.

using Tidier

df = DataFrame(; a=1:10, b=repeat('a':'e'; inner=2))

# ## Select distinct values overall

# Since there are no duplicate rows, this will return all rows.

@chain df begin
    @distinct()
end

# ## Select distinct values based on column `b`

# Notice that the first matching row for column `a` is returned for every distinct value of column `b`. This is slightly different behavior than R's tidyverse, which would have returned only column `b`.

@chain df begin
    @distinct(b)
end

# In Tidier.jl, `@distinct()` works with grouped data frames. If grouped, `@distinct()` will ignore the grouping when determining distinct values but will return the data frame in grouped form based on the original groupings.
