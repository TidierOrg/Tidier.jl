using Tidier
using RDatasets

movies = dataset("ggplot2", "movies");
# ## Select the first 5 columns individually by name

@chain movies begin
    @select(Title, Year, Length, Budget, Rating)
    @slice(1:5)
end

# ##Select the first 5 columns individually by number

@chain movies begin
    @select(1,2,3,4,5)
    @slice(1:5)
end

# ## Select the first 5 columns by name (interval)

@chain movies begin
    @select(Title:Rating)
    @slice(1:5)
end

# ## Select the first 5 columns by number (interval)

@chain movies begin
    @select(1:5)
    @slice(1:5)
end

# ## Select all but the first 5 columns by name

@chain movies begin
    @select(-(Title:Rating))
    @select(1:5)
    @slice(1:5)
end

# ## Select all but the first 5 columns by number

@chain movies begin
    @select(-(1:5))
    @select(1:5)
    @slice(1:5)
end

# ## Mix and match selection
@chain movies begin
    @select(1, Budget:Rating)
    @slice(1:5)
end