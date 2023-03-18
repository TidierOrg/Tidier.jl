# The `!!` ("bang bang") operator can be used to interpolate values of variables from the global environment into your code. This operator is borrowed from the R `rlang` package. At some point, we may switch to using native Julia interpolation, but for a variety of reasons that introduce some complexity with native interpolation, we plan to continue to support `!!` interpolation.

# To interpolate multiple variables, the `rlang` R package uses the `!!!` "triple bang" operator. However, in `Tidier.jl`, the `!!` "bang bang" operator can be used to interpolate either single or multiple values as shown in the examples below.

# Since the `!!` operator can only access variables in the global environment, we will set these variables in a somewhat roundabout way for the purposes of documentation. However, in interactive use, you can simply write `myvar = :b` instead of wrapping this code inside of an `@eval()` macro as is done here.

# Note: `myvar = :b`, `myvar = (:a, :b)`, and `myvar = [:a, :b]` all refer to *columns* with those names. On the other hand, `myvar = "b"`, `myvar = ("a", "b")` and `myvar = ["a", "b"]` will interpolate those *values*. See beloe for examples.

using Tidier

df = DataFrame(a = string.(repeat('a':'e', inner = 2)),
               b = [1,1,1,2,2,2,3,3,3,4],
               c = 11:20)

# ## Select the column (because `myvar` contains a symbol)

@eval(Main, myvar = :b)

@chain df begin
  @select(!!myvar)
end

# ## Select multiple variables (tuple of symbols)

@eval(Main, myvars_tuple = (:a, :b))

@chain df begin
  @select(!!myvars_tuple)
end

# ## Select multiple variables (vector of symbols)

@eval(Main, myvars_vector = [:a, :b])

@chain df begin
  @select(!!myvars_vector)
end

# ## Filter rows containing the *value* of `myvar_string` (because `myvar_string` does)

@eval(Main, myvar_string = "b")

@chain df begin
  @filter(a == !!myvar_string)
end

# ## Filtering rows works similarly using `in`.

# Note that for `in` to work here, we have to wrap it in `[]` because otherwise, the string will be converted into a collection of characters, which are a different data type.

@eval(Main, myvar_string = "b")

@chain df begin
  @filter(a in [!!myvar_string])
end

# ## You can also use this for a tuple or vector of strings.

@eval(Main, myvars_string = ("a", "b"))

@chain df begin
  @filter(a in !!myvars_string)
end

# ## Mutate one variable

@eval(Main, myvar = :b)

@chain df begin
  @mutate(!!myvar = !!myvar + 1)
end

# ## Summarize across one variable

@eval(Main, myvar = :b)

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

# ## Global constants

# Because global constants like `pi` exist in the `Main` module, they can also be accessed using interpolation. For example, let's calculate the area of circles with a radius of 1 up to 5.

df = DataFrame(radius = 1:5)

# We can interpolate `pi` (from the `Main` module) to help with this.

@chain df begin
  @mutate(area = !!pi * radius^2)
end

# ## Alternative interpolation syntax

# While interpolation using `!!` is concise and handy, it's not required. You can also access user-defined globals and global constant variables using the following syntax:

@chain df begin
  @mutate(area = Main.pi * radius^2)
end

# The key lesson with interpolation is that any bare unquoted variable is assumed to refer to a column name in the DataFrame. If you are referring to any variable outside of the DataFrame, you need to either use `!!variable` or `Main.variable` syntax to refer to this variable.
