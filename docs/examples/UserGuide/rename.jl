using Tidier
using DataFrames
using RDatasets

movies = dataset("ggplot2", "movies");

# ## Rename using @select()
# You can use the @select() function to rename and select columns.
@chain movies begin
    @select(title = Title, Minutes = Length)
    @slice(1:5)
end

# ## Rename using @rename()
@chain movies begin
    @rename(title = Title, Minutes = Length)
    @select(1:5)
    @slice(1:5)
end