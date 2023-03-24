# Pivoting a dataset is needed when information sitting inside of cell values needs to be converted into column names (to make the dataset wider) or vice verse (to make the dataset longer). Either action can be referred to as "reshaping" a dataset, and various frameworks refer to the actions as unstacking/stacking or spreading/gathering. In R's tidyverse, these actions are referred to as pivoting, where the two accompanying actions are `@pivot_wider()` and `@pivot_longer()`.

# ## `@pivot_wider()`

# Pivoting a dataset to make it wider is needed when information sitting inside of cell values needs to be converted into column names. The wider format is sometimes required for the purposes of calculating correlations or running statistical tests.

# Let's start with a "long" DataFrame and make it wide. Why would we want to make it wide? Well, if we wanted to calculate a correlation between `A` and `B` for rows with corresponding `id` numbers, we may need to first make sure that `A` and `B` are represented in adjacent columns.

using Tidier

df_long = DataFrame(; id=[1, 1, 2, 2], variable=["A", "B", "A", "B"], value=[1, 2, 3, 4])

# To make this dataset wider, we can do the following:

@pivot_wider(df_long, names_from = variable, values_from = value)

# In `@pivot_wider()`, both the `names_from` and `values_from` arguments are required. `@pivot_wider()` also supports string values for the `names_from` and `values_from` arguments.

@pivot_wider(df_long, names_from = "variable", values_from = "value")

# ## `@pivot_longer()`

# For calculating summary statistics (e.g., mean) by groups, or for plotting purposes, DataFrames often need to be converted to their longer form. For this, we can use `@pivot_longer`. First, let's start with a "wide" DataFrame.

df_wide = DataFrame(; id=[1, 2], A=[1, 3], B=[2, 4])

# Now, let's transform this wide dataset into the longer form. Unlike `@pivot_wider()`, where providing the `names_from` and `values_from` arguments is required, the only item that's required in `@pivot_wider()` is a set of columns to pivot. The `names_to` and `values_to` arguments are optional, and if not provided, they will default to "variable" and "value", respectively.

# We can recreate the original long dataset by doing the following. Multiple columns must be provided using selection syntax or a selection helper. Tuples containing multiple columns are not yet supported.

@pivot_longer(df_wide, A:B)

# Here is another way of providing the same result using a different type of selection syntax.

@pivot_longer(df_wide, -id)

# In this example, we set the `names_to` and `values_to` arguments. Either argument can be left out and will revert to the default value. The `names_to` and `values_to` arguments can be provided as strings or as bare unquoted variable names.

# Here is an example with `names_to` and `values_to` containing strings:

@pivot_longer(df_wide, A:B, names_to = "letter", values_to = "number")

# And here is an example with `names_to` and `values_to` containing bare unquoted variables:

@pivot_longer(df_wide, A:B, names_to = letter, values_to = number)
