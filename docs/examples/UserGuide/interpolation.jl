using Tidier
using DataFrames
using RDatasets

df = DataFrame(a = repeat('a':'e', inner = 2), b = [1,1,1,2,2,2,3,3,3,4], c = 11:20)


# The `!!` ("bang bang") operator can be used to interpolate values of variables from the global environment into your code.

global myvar = :b
global myvar_string = "b"
global myvars_tuple = (:a, :b)
global myvars_vector = [:a, :b]
global myvars_string = ("a", "b")

# ## Select one variable

@chain df begin
  @select(!!myvar)
end

@chain df begin
  @select(!!myvar_string)
end

# ## Select multiple variables

@chain df begin
  @select(!!myvars_tuple)
end

@chain df begin
  @select(!!myvars_vector)
end

@chain df begin
  @select(!!myvars_string)
end

# ## Mutate one variable

@chain df begin
  @mutate(!!myvar = !!myvar + 1)
end

# ## Summarize across one variable

@chain df begin
  @summarize(across(!!myvar, mean))
end

# ## Summarize across multiple variables

global myvars_tuple = (:b, :c)

@chain df begin
  @summarize(across(!!myvars_tuple, (mean, minimum, maximum)))
end

# ## Group by multiple interpolated variables

global myvars_tuple = (:a, :b)

@chain df begin
  @group_by(!!myvars_tuple)
  @summarize(c = mean(c))
end
