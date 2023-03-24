# Whereas joins are useful for combining data frames based on matching keys, another way to combine data frames is to bind them together, which can be done either by rows or by columns. `Tidier.jl` implements these actions using `@bind_rows()` and `@bind_cols()`, respectively.

# Let's generate three data frames to combine.

using Tidier

df1 = DataFrame(; a=1:3, b=1:3);

df2 = DataFrame(; a=4:6, b=4:6);

df3 = DataFrame(; a=7:9, c=7:9);

# ## `@bind_rows()`

@bind_rows(df1, df2)

# `@bind_rows()` keeps columns that are present in at least one of the provided data frames. Any missing columns will be filled with `missing` values.

@bind_rows(df1, df3)

# There is an optional `id` argument to add an identifier for combined data frames. Note that both `@bind_rows` and `@bind_cols` accept multiple (i.e., more than 2) data frames, as in the example below.

@bind_rows(df1, df2, df3, id = "id")

# ## `@bind_cols()`

# `@bind_cols` works similarly to R's `tidyverse` although the `.name_repair` argument is not supported.

@bind_cols(df1, df2)
