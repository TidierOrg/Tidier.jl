# Tidier.jl updates

## 2023-02-09

- Fixed bug with `@rename()` so that it supports multiple arguments
- Added support for numerical selection (both positive and negative) to `@select()`
- Added support for `@slice()`, including positive and negative indexing
- Added support for `@arrange()`, including the use of `desc()` to specify descending order
- Added support for `across()`, which has been confirmed to work with both `@mutate()`, `@summarize()`, and `@summarise()`.
- Re-export `Statistics` and `Chain.jl`
- Bumped version to 0.2.0

## 2023-02-07

- Initial release, version 0.1.0