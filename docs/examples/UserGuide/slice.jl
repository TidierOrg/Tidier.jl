using Tidier
using DataFrames
using RDatasets

movies = dataset("ggplot2", "movies");

# ## Slicing using a range of numbers

@chain movies begin
    @slice(1:5)
end

# ## Separate multiple selections with commas
@chain movies begin
    @slice(1:5, 10)
end

# ## Inverted selection using negative numbers
# This line selects all rows except the first 5 rows.

@chain movies begin
    @slice(-(1:5))
end; # possible bug due to macro
first(ans, 5)