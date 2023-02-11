# In order to show how the functions defined by Tidier.jl work,
# we will use the datasets in  `RDatasets.jl`, using the
# the movies dataset.

using Tidier
using DataFrames
using RDatasets

movies = dataset("ggplot2", "movies")
first(movies, 5)

# ## `describe` 
# Describing the dataset.

describe(movies)