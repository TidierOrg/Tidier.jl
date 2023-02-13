# Tidier.jl

<img src="Tidier_jl_logo.png" width="300"></img>

## What is Tidier.jl?

`Tidier.jl` is a 100% Julia implementation of the R tidyverse
mini-language in Julia. Powered by the `DataFrames.jl` package and Julia’s
extensive meta-programming capabilities, `Tidier.jl` is an R user’s love
letter to data analysis in Julia.

`Tidier.jl` has two goals, which differentiate it from other data analysis
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

## What’s missing?

- Selection helpers like `startswith()` are not supported yet
- Joins are not yet supported
- Pivoting is not yet implemented