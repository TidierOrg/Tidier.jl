using Tidier
using DataFrames
using RDatasets

df = DataFrame(a = repeat('a':'e', inner = 2), b = [1,1,1,2,2,2,3,3,3,4], c = 11:20)


# The `!!` ("bang bang") operator can be used to interpolate values of variables from the global environment into your code.

# Since the `!!` operator can only access variables in the global environment, we will set these variables in a somewhat roundabout way for the purposes of documentation. However, in interactive use, you can simply write `myvar = :b` instead of wrapping it inside of an `@eval()` macro.

@eval(Main, myvar = :b)
@eval(Main, myvar_string = "b")
@eval(Main, myvars_tuple = (:a, :b))
@eval(Main, myvars_vector = [:a, :b])
@eval(Main, myvars_string = ("a", "b"))

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

@eval(Main, myvars_tuple = (:b, :c))

@chain df begin
  @summarize(across(!!myvars_tuple, (mean, minimum, maximum)))
end

# ## Group by multiple interpolated variables

@eval(Main, myvars_tuple = (:a, :b))

@chain df begin
  @group_by(!!myvars_tuple)
  @summarize(c = mean(c))
end
