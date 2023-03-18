# To get started, we will load the `movies` dataset from the `RDatasets.jl` package.

using Tidier
using RDatasets

movies = dataset("ggplot2", "movies");

# To work with this dataset, we will use the `@chain` macro. This macro initiates a pipe, and every function or macro provided to it between the `begin` and `end` blocks modifies the dataframe mentioned at the beginning of the pipe. You don't have to necessarily spread a chain over multiple lines of code, but when working with data frames it's often easiest to do so. Before going further, take a look at the [Chain.jl GitHub page](https://github.com/jkrumbiegel/Chain.jl) to see all the cool things that are possible with this, including mid-chain side effects using `@aside` and mid-chain assignment of variables.

# Let's take a look at the first 5 rows of the `movies` dataset using `@slice()`.

@chain movies begin
    @slice(1:5)
end

# Let's use the `describe()` function, which is re-exported from the `DataFrames.jl` package to describe the dataset.

describe(movies)