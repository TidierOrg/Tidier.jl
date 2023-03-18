# The primary purpose of `@mutate()` is to either create a new column or to update an existing column *without* changing the number of rows in the dataset. If you only plan to select the mutated columns, then you can use `@transmute()` instead of `@mutate(). However, in `Tidier.jl`, `@select()` can also be used to create and select new columns (unlike R's `tidyverse`), which means that `@transmute()` is a redundant function in that it has the same functionality as `@select()`. `@transmute` is included in `Tidier.jl` for convenience but is not strictly required.

using Tidier
using RDatasets

movies = dataset("ggplot2", "movies");

# ## Using `@mutate()` to add a new column

# Let's create a new column that contains the budget for each movie expressed in millions of dollars, and the select a handful of columns and rows for the sake of brevity. Notice that the underscores in in `1_000_000` are strictly optional and included only for the sake of readability. Underscores within numbers are ignored by Julia, such that `1_000_000` is read by Julia exactly the same as `1000000`.

@chain movies begin
  @filter(!ismissing(Budget))
  @mutate(Budget_Millions = Budget/1_000_000)
  @select(Title, Budget, Budget_Millions)
  @slice(1:5)
end

# ## Using `@mutate()` to update an existing column

# Here we will repeat the same exercise, except that we will overwrite the existing `Budget` column.

@chain movies begin
    @filter(!ismissing(Budget))
    @mutate(Budget = Budget/1_000_000)
    @select(Title, Budget)
    @slice(1:5)
end

# ## Using `@mutate()` with `in`

# Here's an example of using `@mutate` with `in`.

@chain movies begin
  @filter(!ismissing(Budget))
  @mutate(Nineties = Year in 1990:1999)
  @select(Title, Year, Nineties)
  @slice(1:5)
end

# ## Using `@mutate` with `n()` and `row_number()`

# Here's an example of using `@mutate` with both `n()` and `row_number()`. Within the context of `mutate()`, `n()` and `row_number()` are created into temporarily columns, which means that they can be used inside of expressions.

@chain movies begin
  @mutate(Row_Num = row_number(),
          Total_Rows = n())
  @filter(!ismissing(Budget))
  @select(Title, Year, Row_Num, Total_Rows)
  @slice(1:5)
end

# ## Using `@transmute` to update *and* select columns.

# If we knew we wanted to select only the `Title` and `Budget` columns, we could have also used`@transmute()`, which (again) is just an alias for `@select()`.

@chain movies begin
    @filter(!ismissing(Budget))
    @transmute(Title = Title, Budget = Budget/1_000_000)
    @slice(1:5)
end