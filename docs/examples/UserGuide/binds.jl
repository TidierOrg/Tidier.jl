# Binding multiple data frames can be done by row and by column. `Tidier.jl` implemented thses actions through `@bind_rows()` and `bind_cols()` respectively.

# Let's generate three data frames to combine.

using Tidier

df1 = DataFrame(A=1:3, B=1:3);

df2 = DataFrame(A=4:6, B=4:6);

df3 = DataFrame(A=7:9, C=7:9);

# All the bind macros work similarly to R's `tidyverse` although `.name_repair` argument for `dplyr::bind_cols()` is not (yet) supported.

# ## `@bind_rows()`

@bind_rows(df1, df2)

# `@bind_rows()` will keep columns that present in at least one of the provided data frame. Any missing columns will be filled with `missing`.

@bind_rows(df1, df3)

# Use `id` argument to add a identifier for combined data frames.

@bind_rows(df1, df2, df3, id = "id")

# ## `@bind_cols()`

@bind_cols(df1, df2)