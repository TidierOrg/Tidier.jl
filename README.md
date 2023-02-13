
# Tidier.jl
[![Latest Docs](https://img.shields.io/badge/docs-latest-blue.svg)](https://kdpsingh.github.io/Tidier.jl/) [![Build
Status](https://github.com/kdpsingh/Tidier.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/kdpsingh/Tidier.jl/actions/workflows/CI.yml?query=branch%3Amain)

<img src="/docs/src/Tidier_jl_logo.png" width="300"></img>

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
    automatically vectorized. The following functions are treated as
    non-vectorized: `mean()`, `median()`, `first()`, `last()`,
    `minimum()`, `maximum()`, `sum()`, and `length()`. Support for
    `nrow()` and `proprow()` will be coming soon, and users may
    eventually be given the option to override these defaults.

## Installation

In the Julia REPL type:

```julia
using Pkg
Pkg.add(url="https://github.com/kdpsingh/Tidier.jl")
```

or

```julia
] add https://github.com/kdpsingh/Tidier.jl
```

The `]` character starts the Julia [package manager](https://docs.julialang.org/en/v1/stdlib/Pkg/). Hit backspace key to return to Julia prompt.

## What functions does Tidier.jl support?

To support R-style programming, Tidier.jl is implemented using macros.

Tidier.jl currently supports the following macros and functions:

- `@select()`
- `@transmute()` (which is just an alias for `@select()` because they
  share the backend implementation in DataFrames.jl)
- `@rename()`
- `@mutate()`
- `@summarize()` and `@summarise()`
- `@filter()`
- `@group_by()`
- `@slice()`
- `@arrange()`
- `across()`

See the [Documentation](https://github.com/kdpsingh/Tidier.jl/dev/) to learn how to use them.

## What’s missing?

- Selection helpers like `startswith()` are not supported yet
- Joins are not yet supported
- Pivoting is not yet implemented

## What’s new in version 0.3.0

- Updated auto-vectorization so that operators are vectorized
  differently from other types of functions. This leads to nicer
  printing of the generaed DataFrames.jl code. For example, 1 .+ 1
  instead of (+).(1,1)
- The generated DataFrames.jl code now prints to the screen
- Updated the ordering of columns when using `across()` so that each
  column is summarized in consecutive columns (e.g., `Rating_mean`,
  `Rating_median`, `Budget_mean`, `Budget_median`) instead of being
  organized by function (e.g. of prior ordering: `Rating_mean`,
  `Budget_mean`, `Rating_median`, `Budget_median`)
- Added exported functions for `across()` and `desc()` as a placeholder
  for documentation, though these functions will throw an error if
  called because they should only be called inside of Tidier macros
- Corrected GitHub actions and added tests (contributed by @rdboyes)
