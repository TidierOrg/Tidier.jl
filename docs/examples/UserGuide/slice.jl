using Tidier
using RDatasets

movies = dataset("ggplot2", "movies");

# ## Slicing using a range of numbers

@chain movies begin
    @slice(1:5)
    @select(1:5)
end

# ## Separate multiple selections with commas
@chain movies begin
    @slice(1:5, 10)
    @select(1:5)
end

# ## Inverted selection using negative numbers
# This line selects all rows except the first 5 rows.

@chain movies begin
    @slice(-(1:5))
    @select(1:5)
    @slice(1:5)
end