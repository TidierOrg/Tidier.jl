# Tidier.jl

<img src="assets/Tidier\_jl\_logo.png" width="25%"></img>

## What is Tidier.jl?

Tidier.jl is a 100% Julia implementation of the R tidyverse
mini-language in Julia. Powered by the DataFrames.jl package and Julia’s
extensive meta-programming capabilities, Tidier.jl is an R user’s love
letter to data analysis in Julia.

`Tidier.jl` has three goals, which differentiate it from other data analysis
meta-packages in Julia:

1.  **Stick as closely to tidyverse syntax as possible:** Whereas other
    meta-packages introduce Julia-centric idioms for working with
    DataFrames, this package’s goal is to reimplement parts of tidyverse
    in Julia. This means that `Tidier.jl` uses *tidy expressions* as opposed
    to idiomatic Julia expressions. An example of a tidy expression is
    `a = mean(b)`. In Julia, `a` and `b` are variables and are thus "eagerly"
    evaluated. This means that if `b` is merely referring to a column in a
    data frame and *not* an object in the global namespace, then an error
    will be generated because `b` was not found. In idiomatic Julia, `b`
    would need to be expressed as a symbol, or `:b`. Even then,
    `a = mean(:b)` would generate an error because it's not possible to
    calculate the mean value of a symbol. To handle this using idiomatic
    Julia, `DataFrames.jl` introduces a mini-language that relies heavily
    on the creation of anonymous functions, with explicit directional
    pairs syntax using a `source => function => destination` syntax. While
    this is quite elegant, it can be verbose. `Tidier.jl` aims to
    reduce this complexity by exposing an R-like syntax, which is then
    converted into valid `DataFrames.jl` code. The reason that
    *tidy expressions* are considered valid by Julia in `Tidier.jl` is
    because they are implemented using macros. Macros "capture" the
    expressions they are given, and then they can modify those expressions
    before evaluating them. For consistency, all top-level `dplyr` functions
    are implemented as macros (whether or not a macro is truly needed), and
    all "helper" functions (used inside of those top-level functions) are
    implemented as functions or pseudo-functions (functions which only exist
    through modification of the abstract syntax tree).

2.  **Make broadcasting mostly invisible:** Broadcasting trips up many R
    users switching to Julia because R users are used to most functions
    being vectorized. `Tidier.jl` currently uses a lookup table to decide
    which functions *not* to vectorize; all other functions are
    automatically vectorized. Read the documentation page on "Autovectorization"
    to read about how this works, and how to override the defaults. An example
    of where this issue commonly causes errors is when centering a variable.
    To create a new column `a` that centers the column `b`, `Tidier.jl` lets you
    simply write `a = b - mean(b)` exactly as you would in R. This works because
    `Tidier.jl` knows to *not* vectorize `mean()` while also recognizing that
    `-` *should* be vectorized such that this expression is rewritten in
    `DataFrames.jl` as `:b => (b -> b .- mean(b)) => :a`. For any user-defined
    function that you want to "mark" as being non-vectorized, you can prefix it
    with a `~`. For example, a function `new_mean()`, if it had the same
    functionality as `mean()` *would* normally get vectorized by `Tidier.jl`
    unless you write it as `~new_mean()`.

3.  **Make scalars and tuples mostly interchangeable:** In Julia, the function
    `across(a, mean)` is dispatched differently than `across((a, b), mean)`.
    The first argument in the first instance above is treated as a scalar,
    whereas the second instance is treated as a tuple. This can be very confusing
    to R users because `1 == c(1)` is `TRUE` in R, whereas in Julia `1 == (1,)`
    evaluates to `false`. The design philosophy in `Tidier.jl` is that the user
    should feel free to provide a scalar or a tuple as they see fit anytime
    multiple values are considered valid for a given argument, such as in
    `across()`, and `Tidier.jl` will figure out how to dispatch it.

## Installation

For the stable version:

```julia
using Pkg
Pkg.add("Tidier")
```

For the newest version:

```julia
using Pkg
Pkg.add(url="https://github.com/kdpsingh/Tidier.jl")
```

or

```julia
] add https://github.com/kdpsingh/Tidier.jl
```

The `]` character starts the Julia [package manager](https://docs.julialang.org/en/v1/stdlib/Pkg/). Hit backspace key to return to the Julia prompt.

## What macros and functions does Tidier.jl support?

To support R-style programming, `Tidier.jl` is implemented using macros. This is because macros are able to "capture" the code before executing it, which allows the package to support R-like "tidy expressions" that would otherwise not be considered valid Julia code.

Tidier.jl currently supports the following top-level macros:

- `@select()`
- `@transmute()`
- `@rename()`
- `@mutate()`
- `@summarize()` and `@summarise()`
- `@filter()`
- `@group_by()`
- `@ungroup()`
- `@slice()`
- `@arrange()`
- `@pull()`
- `@left_join()`
- `@right_join()`
- `@inner_join()`
- `@full_join()`

Tidier.jl also supports the following helper functions:

- `starts_with()`
- `ends_with()`
- `matches()`
- `contains()`
- `across()`
- `desc()`

See the [Reference](https://kdpsingh.github.io/Tidier.jl/dev/reference/) page for a detailed guide to each of the macros and functions.

## Example

Let's select the first five movies in our dataset whose budget exceeds the mean budget. Unlike in R, where we pass an `na.rm = TRUE` argument to remove missing values, in Julia we wrap the variable with a `skipmissing()` to remove the missing values before the `mean()` is calculated.

```julia
using Tidier
using RDatasets

movies = dataset("ggplot2", "movies");

@chain movies begin
    @mutate(Budget = Budget / 1_000_000)
    @filter(Budget >= mean(skipmissing(Budget)))
    @select(Title, Budget)
    @slice(1:5)
end
```

```
5×2 DataFrame
 Row │ Title                       Budget   
     │ String                      Float64? 
─────┼──────────────────────────────────────
   1 │ 'Til There Was You              23.0
   2 │ 10 Things I Hate About You      16.0
   3 │ 102 Dalmatians                  85.0
   4 │ 13 Going On 30                  37.0
   5 │ 13th Warrior, The               85.0
```

## What’s missing?

- Pivoting
- Tidyverse-style `if_else()` that handles missing values, and `case_when()`

## What’s new in version 0.4.0

- Rewrote the parsing engine to remove all regular expression and string parsing
- Selection helpers now work within both `@select()` and `across()`.
- `@group_by()` now supports sorts the groups (similar to `dplyr`) and supports tidy expressions, for example `@group_by(df, d = b + c)`.
- `@slice()` now supports grouped data frames, for example, `@slice(gdf, 1:2)` will slice the first 2 rows from each group assuming that `gdf` is a grouped data frame.
- All functions now work correctly with both grouped and ungrouped data frames following `dplyr` behavior. In other words, all functions retain grouping for grouped data frames (e.g., `ungroup = false`), other than `@summarize()`, which "peels off" one layer of grouping in a similar fashion to `dplyr`.
- Added `@ungroup` to explicitly remove grouping
- Added `@pull` macro to extract vectors
- Added joins: `@left_join()`, `@right_join()`, `@inner_join()`, and `@full_join()`, which support natural joins (i.e., where no `by` argument is given) or explicit joins by providing keys.
- Added `starts_with()` as an alias for Julia's `startswith()`, `ends_with()` as an alias for Julia's `endswith()`, and `matches()` as an alias for Julia's `Regex()`.
- Enabled interpolation of global user variables using `!!` similar to R's `rlang`.
- Enabled a `~` tilde operator to mark functions (or operators) as unvectorized so that Tidier.jl does not "auto-vectorize" them.
- Disabled `@info` logging of generated `DataFrames.jl` code. This code can be shown by setting an option using the new `Tidier_set()` function.
- Fixed a bug where functions were evaluated inside the module, which meant that user-provided functions would not work.
- `@filter()` now skips rows that evaluate to missing values.
- Re-export a handful of functions from the `DataFrames.jl` package.
- Added doctests to all examples in the docstrings.
