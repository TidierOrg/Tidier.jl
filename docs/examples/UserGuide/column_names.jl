# When referring to column names, Tidier.jl is a bit unusual for a Julia package in that it does not use symbols. This is because Tidier.jl uses *tidy expressions*, which in R lingo equates to a style of programming referred to as "non-standard evaluation." If you are creating a new column `a` containing a value that is the mean of column `b`, you would simply write `a = mean(b)`.

# However, there may be times when you wish to create or refer to a column containing a space in it. Let's start by creating some column names containing a space in their name.

using Tidier

df = DataFrame(var"my name" = ["Ada", "Twist"],
               var"my age" = [40, 50])

# To create a column name containing a space, we used the `var"column name"` notation. Because `DataFrame()` is a regular Julia function, this is the standard way to refer to a variable containing a space, which is why we need to use this here.

# This notation *also* works inside of Tidier.jl.

# If we want to figure out the age for the people in our dataset a decade from today, we could use this same `var"column name"` notation inside of `@mutate`.

@chain df begin
  @mutate(var"age in 10 years" = var"my age" + 10)
end

# However, typing out the `var"column name"` can become cumbersome. Tidier.jl also supports another shorthand notation to refer to column names containing spaces or other special characters: backticks.

# This same code could be written more concisely like this:

@chain df begin
  @mutate(`age in 10 years` = `my age` + 10)
end

# Backticks are an R convention. While they are not specific to tidyverse, they are a convenient way to refer to column names that otherwise would not parse correctly as a single entity. Backticks are supported in *all* Tidier.jl functions where column names may be referenced.