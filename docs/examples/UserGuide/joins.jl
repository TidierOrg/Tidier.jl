# One really nice thing about the R `tidyverse` implementation of joins is that they support natural joins. If you don't specify which columns to join on, these column names are inferred from the overlapping columns. While you can override this behavior by specifying which columns to join on, it's convenient that this is not strictly required. We have adopted a similar approach to joins in `Tidier.jl`.

# Here, we will *only* show examples of natural joins. For additional ways to join, take a look at the examples in the [Reference](https://kdpsingh.github.io/Tidier.jl/dev/reference/).

using Tidier

# Let's generate two data frames to join on. Here's the first one.

df1 = DataFrame(a = ["a", "b"], b = 1:2);

# And here's the second one.

df2 = DataFrame(a = ["a", "c"], c = 3:4);

# All the joins work similarly to R's `tidyverse` although the new `join_by` syntax for non-equijoins is not (yet) supported.

# ## Left join

@left_join(df1, df2)

# ## Right join

@right_join(df1, df2)

# ## Inner join

@inner_join(df1, df2)

# ## Full join

@full_join(df1, df2)