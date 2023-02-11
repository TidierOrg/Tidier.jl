using Tidier
using DataFrames
using RDatasets

movies = dataset("ggplot2", "movies");

# ## Rename using @select()
# You can use the @select() function to rename and select columns.
new_name = @chain movies begin
    @select(title = Title, money = Budget)
end
first(new_name, 5)

# ## Rename using @rename()
new_rename = @chain movies begin
    @rename(title = Title, money = Budget)
end
first(new_rename, 5)
