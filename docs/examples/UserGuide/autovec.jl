using Tidier
using DataFrames
using RDatasets

df = DataFrame(a = repeat('a':'e', inner = 2), b = [1,1,1,2,2,2,3,3,3,4], c = 11:20)


# By default, Tidier.jl uses a lookup table to decide which functions *not* to vectorize. For example, `mean()` is listed as a function that should never be vectorized. Also, any function used inside of `@summarize()` is also never automatically vectorized. Any function that is not included in this list *and* is used in a context other than `@summarize()` is automatically vectorized.

# This "auto-vectorization" makes working with Tidier.jl more R-like and convenient. However, if you ever define your own function and try to use it, Tidier.jl may unintentionally vectorize it for you. To prevent auto-vectorization, you can prefix your function with a `~`. For example, let's define a function `new_mean()` that calculates a mean.

new_mean(exprs...) = mean(exprs...)

# If we try to use `new_mean()` inside of `@mutate()`, it will give us the wrong result. This is because `new_mean()` is vectorized, which results in the mean being calculated element-wise, which is almost never what we actually want.

@chain df begin
    @mutate(d = c - new_mean(c))
end

# To prevent `new_mean()` from being vectorized, we need to prefix it with a `~` like this:

@chain df begin
    @mutate(d = c - ~new_mean(c))
end

# This gives us the correct answer. Notice that adding a `~` is not needed with `mean()` because `mean()` is already included on our look-up table of functions not requiring vectorization.

@chain df begin
    @mutate(d = c - mean(c))
end

# If you're not sure if a function is vectorized and want to prevent it from being vectorized, you can always prefix it with a ~ to prevent vectorization. Even though `mean()` is not vectorized anyway, prefixing it with a ~ will not cause any harm.

@chain df begin
    @mutate(d = c - ~mean(c))
end

# If for some crazy reason, you *did* want to vectorize `mean()`, you are always allowed to vectorize it, and Tidier.jl won't un-vectorize it.

@chain df begin
    @mutate(d = c - mean.(c))
end

# Note: `~` also works with operators, so if you want to *not* vectorize an operator, you can prefix it with `~`, for example, `a ~* b` will perform a matrix multiplication rather than element-wise multiplication. Remember that this is only needed outside of `@summarize()` because `@summarize()` never performs auto-vectorization.