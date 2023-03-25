# Arranging is the way to sort a data frame. `@arrange()` can take multiple arguments. Arguments refer to columns that are sorted in ascending order by default. If you want to sort in descending order, make sure to wrap the column name in `desc()` as shown below.

# `DataFrames.jl` does not currently support the `sort()` function on grouped data frames. In order to make this work in `Tidier.jl`, if you apply `@arrange()` to a GroupedDataFrame, `@arrange()` will temporarily ungroup the data, perform the `sort()`, and then re-group by the original grouping variables.

using Tidier
using RDatasets

movies = dataset("ggplot2", "movies");

# ## Sort both variables in ascending order

@chain movies begin
  @arrange(Year, Rating)
  @select(1:5)
  @slice(1:5)
end

# ## Sort in a mix of ascending and descending order

# To sort in descending order, make sure to wrap the variable inside of `desc()`.

@chain movies begin
  @arrange(Year, desc(Rating))
  @select(1:5)
  @slice(1:5)
end
