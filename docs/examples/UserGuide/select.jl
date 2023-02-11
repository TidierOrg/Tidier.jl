using Tidier
using DataFrames
using RDatasets

movies = dataset("ggplot2", "movies");
# ## Select the first 5 columns individually by name

by_name = @chain movies begin
    @select(Title, Year, Length, Budget, Rating)
end
first(by_name, 5)

# ##Select the first 5 columns individually by number

by_num = @chain movies begin
    @select(1, 2, 3, 4, 5)
end
first(by_num, 5)

# ## Select the first 5 columns by name (interval)

by_names = @chain movies begin
    @select(Title:Rating)
end
first(by_names, 5)

# ## Select the first 5 columns by number (interval)

by_numbers = @chain movies begin
    @select(1:5)
end
first(by_numbers, 5)

# ## Select all but the first 5 columns by name

by_not_names = @chain movies begin
    @select(-(Title:Rating))
end
first(by_not_names, 5)

# ## Select all but the first 5 columns by number

by_not_num = @chain movies begin
    @select(-(1:5))
end
first(by_not_num, 5)

# ## Mix and match selection
mix_match = @chain movies begin
    @select(1, Budget:Rating)
end
first(mix_match, 5)
