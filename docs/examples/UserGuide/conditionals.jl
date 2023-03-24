# Conditional functions are a useful tool to update or create new columns conditional on the values of a column of data. When continuous variables are converted to categories, this is sometimes referred to as "recoding" a column.

# Tidier.jl provides two functions to recode data: `if_else()` and `case_when()`.

# ## `if_else()`

# Why do we need another `if_else()` function if base Julia already comes with an `ifelse()` function. Similar to R, the base Julia implementation of `if_else()` does not include a way to designate what value to return if the enclosed vector contains a missing value. Additionally, the base Julia implementation of `ifelse()` produces an error if presented with a `missing` value in the condition. The Tidier.jl `if_else()` can handle missing values and includes an optional 4th argument that is used to designate what to return in the event of a `missing`` value for the condition. Let's take a look at some examples.

using Tidier

df = DataFrame(; a=[1, 2, missing, 4, 5])

# Here, we have created a `DataFrame` containing a single column `a` with 5 values, for which the 3rd value is missing.

# Now, let's create a new column `b` that contains a "yes" if `a` is greater than or equal to 3, and a "no" otherwise. Notice that when we do this, the `missing` values remains as `missing`.

@chain df begin
    @mutate(b = if_else(a >= 3, "yes", "no"))
end

# What if we wanted to fill in the missing value with "unknown"? All we need to do is provide an optional 4th argument containing the value to return in the event of a missing condition. When we run this version, `missing` values in `a` are converted to "unknown" in `b`.

@chain df begin
    @mutate(b = if_else(a >= 3, "yes", "no", "unknown"))
end

# Although both of these examples showed how to return a single value (like "yes" and "no"), you can also return a vector of values, which is useful for updating only a subset of the values of a column. For example, if we wanted to create a column `b` that contains a 3 when `a` is greater than or equal to 3 but otherwise remains unchanged, we could provide a 3 for the `yes` condition and a vector (column) `a` in the `no` condition. If we do not provide the optional 4th argument, `missing` values remain `missing`.

@chain df begin
    @mutate(b = if_else(a >= 3, 3, a))
end

# ## `case_when()`

# Although `if_else()` is convenient when evaluating a single condition, it can be cumbersome when evaluating multiple conditions because subsequent conditions need to be nested within the `no` condition for the preceding argument. For situations where multiple conditions need to be evaluated, `case_when()` is more convenient.

# Let's first consider a similar example from above and recreate it using `case_when()`. The following code creates a column `b` that assigns a value if 3 if `a >= 3` and otherwise leaves the value unchanged.

@chain df begin
    @mutate(b = case_when(a >= 3 => 3, true => a))
end

# What is going on here? `case_when()` uses a `condition => return_value` syntax, which are encoded as pairs in Julia. You can provide a single pair, or multiple pairs separated by commas. Because the pairs operator (`=>`) might be confused with a greater than or equal to sign (`>=`), we have padded two spaces on either side of the `=>` to make sure that the pair remains visually distinct. We do not use a `~` operator in `case_when()` (as is used in R) because the `~` operator is used to denote de-vectorized functions in Tidier.jl.

# There are 2 other things to note above. First, the `true` condition evaluates to `true` for all remaining values of `a`. The only reason that the `b` contains a `missing` value here is that the `true` condition was met, leading to the value of `a` (in this case, `missing`) to be assigned to `b`. Second, we were able to return a single value (3) in the first condition, and a vector (column) of data (`a`) in the second condition.

# What if we wanted to fill in the missing values with something else? In this case, we would need to create an explicit condition that checks for missing values and assigns a return value to that condition.

@chain df begin
    @mutate(b = case_when(a >= 3 => 3, ismissing(a) => 0, true => a))
end

# Do our conditions have to be mutually exclusive? No. The return value for the *first* matching condition is assigned to `b` because the conditions are evaluated sequentially from first to last.

@chain df begin
    @mutate(b = case_when(a > 4 => "hi", a > 2 => "medium", a > 0 => "low"))
end

# Again, if we want to fill in remaining values (which in this case are the `missing` ones), we can map the final condition `true` to the value of "unknown". Because the ordering of the conditions matters, the `true` condition should always be listed last if it is included.

@chain df begin
    @mutate(
        b = case_when(a > 4 => "hi", a > 2 => "medium", a > 0 => "low", true => "unknown")
    )
end

# ## Do these functions work outside of Tidier.jl?

# Yes, both `if_else()` and `case_when()` work outside of Tidier.jl. However, you'll need to remember that if working with vectors, both the functions and conditions will need to be vectorized, and in the case of `case_when()`, the `=>` will need to be written as `.=>`. The reason this is not needed when using these functions inside of Tidier.jl is because they are auto-vectorized.
