using Tidier
using DataFrames
using RDatasets

movies = dataset("ggplot2", "movies");

# # Update an existing column
# ## @mutate
# We will scale the Budget down to millions of dollars. Since there are many
# missing values for Budget, we will first remove the missing values.

df_mutate = @chain movies begin
    @filter(!ismissing(Budget))
    @mutate(Budget = Budget/1_000_000)
    @select(Title, Budget)
end
first(df_mutate, 5)

# ## @transmute()

# If we knew we wanted to select only the `Title` and `Budget` columns,
# we could have also used the `@transmute()` macro, which is just an alias
# for `@select()` since the two macros both use the `select()` function
# from `DataFrames.jl`.

df_t = @chain movies begin
    @filter(!ismissing(Budget))
    @transmute(Title = Title, Budget = Budget/1_000_000)
end
first(df_t, 5)

# # Add new column
df_new = @chain movies begin
    @filter(!ismissing(Budget))
    @mutate(Budget_Millions = Budget/1_000_000)
    @select(Title, Budget, Budget_Millions)
end
first(df_new, 5)