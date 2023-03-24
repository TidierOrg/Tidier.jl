# Tidier.jl

[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](https://github.com/kdpsingh/Tidier.jl/blob/main/LICENSE)
[![Docs: Dev](https://img.shields.io/badge/Docs-Dev-lightblue.svg)](https://kdpsingh.github.io/Tidier.jl/dev)
[![Docs: Stable](https://img.shields.io/badge/Docs-Stable-blue.svg)](https://kdpsingh.github.io/Tidier.jl/stable)
[![Code Style: Blue](https://img.shields.io/badge/Code%20Style-Blue-4495d1.svg)](https://github.com/invenia/BlueStyle)
[![Build Status](https://github.com/kdpsingh/Tidier.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/kdpsingh/Tidier.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Downloads](https://shields.io/endpoint?url=https://pkgs.genieframework.com/api/v1/badge/Tidier&label=Downloads)](https://pkgs.genieframework.com?packages=Tidier)

<img src="/docs/src/assets/Tidier_jl_logo.png" align="right" style="padding-left:10px;" width="150"/>

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
    `a = mean(b)`.

2.  **Make broadcasting mostly invisible:** Broadcasting trips up many R
    users switching to Julia because R users are used to most functions
    being vectorized. `Tidier.jl` currently uses a lookup table to decide
    which functions *not* to vectorize; all other functions are
    automatically vectorized. Read the documentation page on "Autovectorization"
    to read about how this works, and how to override the defaults.

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

or

```
] add Tidier
```

The `]` character starts the Julia [package manager](https://docs.julialang.org/en/v1/stdlib/Pkg/). Press the backspace key to return to the Julia prompt.

For the newest version:

```
] add Tidier#main
```

or

```julia
using Pkg
Pkg.add(url="https://github.com/kdpsingh/Tidier.jl")
```

## What functions does Tidier.jl support?

To support R-style programming, Tidier.jl is implemented using macros.

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
- `@distinct()`
- `@pull()`
- `@left_join()`
- `@right_join()`
- `@inner_join()`
- `@full_join()`
- `@bind_rows()`
- `@bind_cols()`
- `@pivot_wider()`
- `@pivot_longer()`
- `@clean_names()` (as in R's `janitor::clean_names()` function)

Tidier.jl also supports the following helper functions:

- `across()`
- `desc()`
- `if_else()`
- `case_when()`
- `n()`
- `row_number()`
- `starts_with()`
- `ends_with()`
- `matches()`
- `contains()`

See the documentation [Home](https://kdpsingh.github.io/Tidier.jl/dev/) page for a guide on how to get started, or the [Reference](https://kdpsingh.github.io/Tidier.jl/dev/reference/) page for a detailed guide to each of the macros and functions.

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

## What’s new

See [NEWS.md](https://github.com/kdpsingh/Tidier.jl/blob/main/NEWS.md) for the latest updates.

## What's missing

Is there a tidyverse feature missing that you would like to see in Tidier.jl? Please file a GitHub issue. Because Tidier.jl primarily wraps DataFrames.jl, our decision to integrate a new feature will be guided by how well-supported it is within DataFrames.jl and how likely other users are to benefit from it.