
# Tidier.jl
[![Latest Docs](https://img.shields.io/badge/docs-latest-blue.svg)](https://kdpsingh.github.io/Tidier.jl/dev/) [![Stable Docs](https://img.shields.io/badge/docs-stable-blue.svg)](https://kdpsingh.github.io/Tidier.jl/stable/) [![Build
Status](https://github.com/kdpsingh/Tidier.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/kdpsingh/Tidier.jl/actions/workflows/CI.yml?query=branch%3Amain)

<img src="/docs/src/assets/Tidier_jl_logo.png" align="right" style="padding-left:10px;" width="150"/>

## What is Tidier.jl?

Tidier.jl is a 100% Julia implementation of the R tidyverse
mini-language in Julia. Powered by the DataFrames.jl package and Julia’s
extensive meta-programming capabilities, Tidier.jl is an R user’s love
letter to data analysis in Julia.

Tidier.jl has two goals, which differentiate it from other data analysis
meta-packages:

1.  **Stick as closely to tidyverse syntax as possible:** Whereas other
    meta-packages introduce Julia-centric idioms for working with
    DataFrames, this package’s goal is to reimplement parts of tidyverse
    in Julia.

2.  **Make broadcasting mostly invisible:** Broadcasting trips up many R
    users switching to Julia because R users are used to most functions
    being vectorized. Tidier.jl currently uses a lookup table to decide
    which functions not to vectorize; all other functions are
    automatically vectorized. Read the documentation page on "Autovectorization"
    to read about how this works, and how to override the defaults.

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

## What functions does Tidier.jl support?

To support R-style programming, Tidier.jl is implemented using macros.

Tidier.jl currently supports the following top-level macros:

- `@select()`
- `@transmute()` (which is an alias for `@select()` because they
  share the same backend implementation in DataFrames.jl)
- `@rename()`
- `@mutate()`
- `@summarize()` and `@summarise()`
- `@filter()`
- `@group_by()`
- `@ungroup()`
- `@slice()`
- `@arrange()`

Tidier.jl also supports the following helper functions:

- `starts_with()`
- `ends_with()`
- `matches()`
- `across()`
- `desc()`

See the [Documentation](https://kdpsingh.github.io/Tidier.jl/dev/) to learn how to use them.

## What’s missing?

- Joins are not yet supported
- Pivoting is not yet implemented

## What’s new in version 0.4.0-beta-1

- Rewrote the parsing engine to remove all regular expression and string parsing
- Selection helpers should now work within `@select()` and `across()`
- `@group_by()` now supports tidy expressions, for example `@group_by(df, d = b + c)`
- `@slice()` now supports grouped data frames, for example, `@slice(gdf, 1:2)` will slice the first 2 rows from each group assuming that `gdf` is a grouped data frame.
- Fixed a bug where functions were evaluated inside the module, which meant that user-provided functions would not work.
- Lots more... will update before release.