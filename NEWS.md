# Tidier.jl updates

## 2023-02-11
- Updated auto-vectorization so that operators are vectorized differently from other types of functions. This leads to nicer printing of the generaed DataFrames.jl code. For example, 1 .+ 1 instead of (+).(1,1)
- The generated DataFrames.jl code now prints to the screen
- Updated the ordering of columns when using across so that each column is summarized in consecutive columns (e.g., Rating_mean, Rating_median, Budget_mean, Budget_median) instead of being organized by function (e.g. of prior ordering: Rating_mean, Budget_mean, Rating_median, Budget_median) 
- Exported `across()` and `desc()` functions which throw an error because they should only be called inside of Tidier macros
- Corrected GitHub actions and added tests (contributed by @rdboyes)
- Bumped version to 0.3.0

## 2023-02-09

- Fixed bug with `@rename()` so that it supports multiple arguments
- Added support for numerical selection (both positive and negative) to `@select()`
- Added support for `@slice()`, including positive and negative indexing
- Added support for `@arrange()`, including the use of `desc()` to specify descending order
- Added support for `across()`, which has been confirmed to work with both `@mutate()`, `@summarize()`, and `@summarise()`.
- Updated auto-vectorization so that `@summarize` and `@summarise` do not vectorize any functions
- Re-export `Statistics` and `Chain.jl`
- Bumped version to 0.2.0

## 2023-02-07

- Initial release, version 0.1.0