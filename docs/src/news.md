# Tidier.jl updates

## v1.3.0 - 2024-04-09
- Update minimum Julia required version to 1.9
- Base package version updates
- New documentation

## v1.2.1 - 2024-01-02
- Base package version updates

## v1.2.0 - 2023-11-28
- Add and re-export TidierText.jl
- Bugfix: Re-export TidierVest.jl (forgot to do this in 1.1.0)

## v1.1.0 - 2023-11-18
- Update versions of base packages
- Add TidierVest.jl

## v1.0.0 - 2023-08-07
- Convert Tidier.jl to a meta-package that only re-exports other Tidier packages

## v0.7.7 - 2023-07-15
- Added documentation on how to interpolate variables inside of `for` loops. Note: `!!` interpolation doesn't work inside of `for` loops because macros are expanded during parsing and not at runtime.
- Fixed bug in `parse_pivot_arg()` to enable interpolation inside of pivoting functions when used inside a `for` loop.
- Added `cumsum()`, `cumprod()`, and `accumulate()` to the do-not-vectorize list.

## v0.7.6 - 2023-05-04
- Fixed bug to allow multiple columns in `@distinct()` separated by commas or using selection helpers.

## v0.7.5 - 2023-04-30
- Fixed bug to ensure that `&&` and `||` are auto-vectorized
- Added docstrings and examples to show different ways of filtering by multiple "and" conditions, including `&&`, `&`, and separating multiple expressions with commas.

## v0.7.4 - 2023-04-11
- Added `as_float()`, `as_integer()`, and `as_string()`

## v0.7.3 - 2023-04-10
- Added `@glimpse()`

## v0.7.2 - 2023-04-05
- Moved repo to TidierOrg

## v0.7.1 - 2023-04-01
- Added `@drop_na()` with optional column selection parameter
- Re-exported `lead()` and `lag()` from ShiftedArrays.jl and added both to the do-not-vectorize list
- Bug fix: Fixed `ntile()` condition for when all elements are missing

## v0.7.0 - 2023-03-27

- Added `@count()` and `@tally()`
- Added `@bind_rows()` and `@bind_cols()`
- Added `@clean_names()` to mimic R's `janitor::clean_names()` by wrapping the Cleaner.jl package
- Added support for backticks to select columns containing spaces.
- Added support for `ntile()`, which is on the do-not-vectorize list because it takes in a vector and returns a vector.
- Bug fix: removed selection helpers (`startswith`, `contains`, and `endswith` from the do-not-vectorize list).

## v0.6.0 - 2023-03-18

- Added `@distinct()`. It behaves slightly differently from dplyr when provided arguments in that it returns all columns, not just the selected ones.
- Added support for `n()` and `row_number()`.
- Added support for negative selection helper functions (e.g., `-contains("a")`).
- Added support for negative selection using `!` (e.g., `!a`, `!(a:b)`, `!contains("a")`).
- In `@pivot_longer()`, the `names_to` and `values_to` arguments now also support strings (in addition to bare unquoted names).
- In `@pivot_wider()`, the `names_from` and `values_from` arguments now also support strings (in addition to bare unquoted names).
- Bug fix: `@mutate(a = 1)` or any scalar previously errored because the `1` was being wrapped inside a `QuoteNode`. Now, 1 is correctly broadcasted.
- Bug fix: `@slice(df, 1,2,1)` previously only returned rows 1 and 2 only (and not 1 again). `@slice(df, 1,2,1)` now returns rows 1, 2, and 1 again.
- Bug fix: added `repeat()` to the do-not-vectorize list.

## v0.5.0 - 2023-03-10

- Added `@pivot_wider()` and `@pivot_wider()`.
- Added `if_else()` and `case_when()`.
- Updated documentation to include `Main.variable` example as an alternative syntax for interpolation.
- Simplified internal use of `subset()` by using keyword argument of `skipmissing = true` instead of using `coalesce(..., false)`.
- For developers: doctests can now be run locally using `runtests.jl`.

## v0.4.1 - 2023-03-05

- In addition to `in` being auto-vectorized as before, the second argument is automatically wrapped inside of `Ref(Set(arg2))` if not already done to ensure that it is evaluated correctly and fast. See: https://bkamins.github.io/julialang/2023/02/10/in.html for details. This same behavior is also implemented for `∈` and `∉`.
- Added documentation and docstrings for new `in` behavior with `@filter()` and `@mutate()`.
- Improved interpolation to support values and not just column names. Note: there is a change of behavior now for strings, which are treated as values and not as column names. Updated examples in the documentation webpage for interpolation.
- Bug fix: Re-exported `Cols()` because this is required for interpolated columns inside of `across()`. Previously, this was passing tests because `using RDatasets` was exporting `Cols()`.

## v0.4.0 - 2023-02-29

- Rewrote the parsing engine to remove all regular expression and string parsing
- Selection helpers now work within both `@select()` and `across()`.
- `@group_by()` now sorts the groups (similar to `dplyr`) and supports tidy expressions, for example `@group_by(df, d = b + c)`.
- `@slice()` now supports grouped data frames. For example, `@slice(gdf, 1:2)` will slice the first 2 rows from each group if `gdf` is a grouped data frame.
- All functions now work correctly with both grouped and ungrouped data frames following `dplyr` behavior. In other words, all functions retain grouping for grouped data frames (e.g., `ungroup = false`), other than `@summarize()`, which "peels off" one layer of grouping in a similar fashion to `dplyr`.
- Added `@ungroup` to explicitly remove grouping
- Added `@pull` macro to extract vectors
- Added joins: `@left_join()`, `@right_join()`, `@inner_join()`, and `@full_join()`, which support natural joins (i.e., where no `by` argument is given) or explicit joins by providing keys. All join functions ungroup both data frames before joining.
- Added `starts_with()` as an alias for Julia's `startswith()`, `ends_with()` as an alias for Julia's `endswith()`, and `matches()` as an alias for Julia's `Regex()`.
- Enabled interpolation of global user variables using `!!` similar to R's `rlang`.
- Enabled a `~` tilde operator to mark functions (or operators) as unvectorized so that Tidier.jl does not "auto-vectorize" them.
- Disabled `@info` logging of generated `DataFrames.jl` code. This code can be shown by setting an option using the new `Tidier_set()` function.
- Fixed a bug where functions were evaluated inside the module, which meant that user-provided functions would not work.
- `@filter()` now skips rows that evaluate to missing values.
- Re-export a handful of functions from the `DataFrames.jl` package.
- Added doctests to all examples in the docstrings.

## v0.3.0 - 2023-02-11
- Updated auto-vectorization so that operators are vectorized differently from other types of functions. This leads to nicer printing of the generated DataFrames.jl code. For example, 1 .+ 1 instead of (+).(1,1)
- The generated DataFrames.jl code now prints to the screen
- Updated the ordering of columns when using `across()` so that each column is summarized in consecutive columns (e.g., `Rating_mean`, `Rating_median`, `Budget_mean`, `Budget_median`) instead of being organized by function (e.g. of prior ordering: `Rating_mean`, `Budget_mean`, `Rating_median`, `Budget_median`) 
- Added exported functions for `across()` and `desc()` as a placeholder for documentation, though these functions will throw an error if called because they should only be called inside of Tidier macros
- Corrected GitHub actions and added tests (contributed by @rdboyes)
- Bumped version to 0.3.0

## v0.2.0 - 2023-02-09

- Fixed bug with `@rename()` so that it supports multiple arguments
- Added support for numerical selection (both positive and negative) to `@select()`
- Added support for `@slice()`, including positive and negative indexing
- Added support for `@arrange()`, including the use of `desc()` to specify descending order
- Added support for `across()`, which has been confirmed to work with both `@mutate()`, `@summarize()`, and `@summarise()`.
- Updated auto-vectorization so that `@summarize` and `@summarise` do not vectorize any functions
- Re-export `Statistics` and `Chain.jl`
- Bumped version to 0.2.0

## v0.1.0 - 2023-02-07

- Initial release, version 0.1.0
