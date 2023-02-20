using Tidier
using DataFrames
using RDatasets

movies = dataset("ggplot2", "movies");
# ## Sort both in ascending order

@chain movies begin
  @arrange(Year, Rating)
  @select(1:5)
  @slice(1:5)
end

# ## Sort in a mix of ascending and descending order
# ### `desc`
@chain movies begin
  @arrange(Year, desc(Rating))
  @select(1:5)
  @slice(1:5)
end