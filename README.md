
# Tidier.jl

[![Build
Status](https://github.com/kdpsingh/Tidier.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/kdpsingh/Tidier.jl/actions/workflows/CI.yml?query=branch%3Amain)

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

## What functions does Tidier.jl support?

To support R-style programming, Tidier.jl is implemented using macros.

Tidier.jl currently supports the following macros:

- `@select()`
- `@transmute()` (which is just an alias for `@select()` because they
  share the backend implementation in DataFrames.jl)
- `@rename()`
- `@mutate()`
- `@summarize()` and `@summarise()`
- `@filter()`
- `@group_by()`

## What’s missing?

Helper selector functions like `starts_with()` aren’t implemented yet.
The `across()` function isn’t implemented yet but will be relatively
straightforward to implement.

Until the docs are built, this README will document the common
functionality.

## Overview of the package

First, we need to install the package.

``` julia
import Pkg
Pkg.add(url = "https://github.com/kdpsingh/Tidier.jl")
```

    ##     Fetching: [>                                        ]  0.0 %

``` julia
using Tidier
```

Next, let’s load the `movies` dataset.

``` julia
using DataFrames
using Chain
using Statistics
using RDatasets

movies = dataset("ggplot2", "movies")
```

    ## 58788×24 DataFrame
    ##    Row │ Title                     Year   Length  Budget    Rating   Votes  R1 ⋯
    ##        │ String                    Int32  Int32   Int32?    Float64  Int32  Fl ⋯
    ## ───────┼────────────────────────────────────────────────────────────────────────
    ##      1 │ $                          1971     121   missing      6.4    348     ⋯
    ##      2 │ $1000 a Touchdown          1939      71   missing      6.0     20
    ##      3 │ $21 a Day Once a Month     1941       7   missing      8.2      5
    ##      4 │ $40,000                    1996      70   missing      8.2      6
    ##      5 │ $50,000 Climax Show, The   1975      71   missing      3.4     17     ⋯
    ##      6 │ $pent                      2000      91   missing      4.3     45
    ##      7 │ $windle                    2002      93   missing      5.3    200
    ##      8 │ '15'                       2002      25   missing      6.7     24
    ##    ⋮   │            ⋮                ⋮      ⋮        ⋮         ⋮       ⋮       ⋱
    ##  58782 │ pURe kILLjoy               1998      87   missing      5.2      6     ⋯
    ##  58783 │ sIDney                     2002      15   missing      7.0      8
    ##  58784 │ tom thumb                  1958      98   missing      6.5    274
    ##  58785 │ www.XXX.com                2003     105   missing      1.1     12
    ##  58786 │ www.hellssoapopera.com     1999     100   missing      6.6      5     ⋯
    ##  58787 │ xXx                        2002     132  85000000      5.5  18514
    ##  58788 │ xXx: State of the Union    2005     101  87000000      3.9   1584
    ##                                                18 columns and 58773 rows omitted

## Describing the dataset

``` julia
describe(movies)
```

    ## 24×7 DataFrame
    ##  Row │ variable     mean       min   median  max                      nmissing ⋯
    ##      │ Symbol       Union…     Any   Union…  Any                      Int64    ⋯
    ## ─────┼──────────────────────────────────────────────────────────────────────────
    ##    1 │ Title                   $             xXx: State of the Union         0 ⋯
    ##    2 │ Year         1976.13    1893  1983.0  2005                            0
    ##    3 │ Length       82.3379    1     90.0    5220                            0
    ##    4 │ Budget       1.34125e7  0     3.0e6   200000000                   53573
    ##    5 │ Rating       5.93285    1.0   6.1     10.0                            0 ⋯
    ##    6 │ Votes        632.13     5     30.0    157608                          0
    ##    7 │ R1           7.01438    0.0   4.5     100.0                           0
    ##    8 │ R2           4.02238    0.0   4.5     84.5                            0
    ##   ⋮  │      ⋮           ⋮       ⋮      ⋮                ⋮                ⋮     ⋱
    ##   18 │ Action       0.0797442  0     0.0     1                               0 ⋯
    ##   19 │ Animation    0.0627679  0     0.0     1                               0
    ##   20 │ Comedy       0.293784   0     0.0     1                               0
    ##   21 │ Drama        0.371011   0     0.0     1                               0
    ##   22 │ Documentary  0.0590597  0     0.0     1                               0 ⋯
    ##   23 │ Romance      0.0806967  0     0.0     1                               0
    ##   24 │ Short        0.160883   0     0.0     1                               0
    ##                                                      1 column and 9 rows omitted

## Selecting columns

### Select the first 5 columns individually by name

``` julia
@chain movies begin
  @select(Title, Year, Length, Budget, Rating)
end
```

    ## 58788×5 DataFrame
    ##    Row │ Title                     Year   Length  Budget    Rating
    ##        │ String                    Int32  Int32   Int32?    Float64
    ## ───────┼────────────────────────────────────────────────────────────
    ##      1 │ $                          1971     121   missing      6.4
    ##      2 │ $1000 a Touchdown          1939      71   missing      6.0
    ##      3 │ $21 a Day Once a Month     1941       7   missing      8.2
    ##      4 │ $40,000                    1996      70   missing      8.2
    ##      5 │ $50,000 Climax Show, The   1975      71   missing      3.4
    ##      6 │ $pent                      2000      91   missing      4.3
    ##      7 │ $windle                    2002      93   missing      5.3
    ##      8 │ '15'                       2002      25   missing      6.7
    ##    ⋮   │            ⋮                ⋮      ⋮        ⋮         ⋮
    ##  58782 │ pURe kILLjoy               1998      87   missing      5.2
    ##  58783 │ sIDney                     2002      15   missing      7.0
    ##  58784 │ tom thumb                  1958      98   missing      6.5
    ##  58785 │ www.XXX.com                2003     105   missing      1.1
    ##  58786 │ www.hellssoapopera.com     1999     100   missing      6.6
    ##  58787 │ xXx                        2002     132  85000000      5.5
    ##  58788 │ xXx: State of the Union    2005     101  87000000      3.9
    ##                                                   58773 rows omitted

### Select the first 5 columns by name

The multicolumn select is a wrapper around the `Between()` function in
DataFrames.jl.

Note: Indexing columns by number is not supported yet.

``` julia
@chain movies begin
  @select(Title:Rating)
end
```

    ## 58788×5 DataFrame
    ##    Row │ Title                     Year   Length  Budget    Rating
    ##        │ String                    Int32  Int32   Int32?    Float64
    ## ───────┼────────────────────────────────────────────────────────────
    ##      1 │ $                          1971     121   missing      6.4
    ##      2 │ $1000 a Touchdown          1939      71   missing      6.0
    ##      3 │ $21 a Day Once a Month     1941       7   missing      8.2
    ##      4 │ $40,000                    1996      70   missing      8.2
    ##      5 │ $50,000 Climax Show, The   1975      71   missing      3.4
    ##      6 │ $pent                      2000      91   missing      4.3
    ##      7 │ $windle                    2002      93   missing      5.3
    ##      8 │ '15'                       2002      25   missing      6.7
    ##    ⋮   │            ⋮                ⋮      ⋮        ⋮         ⋮
    ##  58782 │ pURe kILLjoy               1998      87   missing      5.2
    ##  58783 │ sIDney                     2002      15   missing      7.0
    ##  58784 │ tom thumb                  1958      98   missing      6.5
    ##  58785 │ www.XXX.com                2003     105   missing      1.1
    ##  58786 │ www.hellssoapopera.com     1999     100   missing      6.6
    ##  58787 │ xXx                        2002     132  85000000      5.5
    ##  58788 │ xXx: State of the Union    2005     101  87000000      3.9
    ##                                                   58773 rows omitted

### Select all but the first 5 columns by name

Note: Currently, the `-start` or `-(start:finish)` notation is
recommended. The negation is a wrapper around the `Not()` function in
DataFrames.jl.

``` julia
@chain movies begin
  @select(-(Title:Rating))
end
```

    ## 58788×19 DataFrame
    ##    Row │ Votes  R1       R2       R3       R4       R5       R6       R7       ⋯
    ##        │ Int32  Float64  Float64  Float64  Float64  Float64  Float64  Float64  ⋯
    ## ───────┼────────────────────────────────────────────────────────────────────────
    ##      1 │   348      4.5      4.5      4.5      4.5     14.5     24.5     24.5  ⋯
    ##      2 │    20      0.0     14.5      4.5     24.5     14.5     14.5     14.5
    ##      3 │     5      0.0      0.0      0.0      0.0      0.0     24.5      0.0
    ##      4 │     6     14.5      0.0      0.0      0.0      0.0      0.0      0.0
    ##      5 │    17     24.5      4.5      0.0     14.5     14.5      4.5      0.0  ⋯
    ##      6 │    45      4.5      4.5      4.5     14.5     14.5     14.5      4.5
    ##      7 │   200      4.5      0.0      4.5      4.5     24.5     24.5     14.5
    ##      8 │    24      4.5      4.5      4.5      4.5      4.5     14.5     14.5
    ##    ⋮   │   ⋮       ⋮        ⋮        ⋮        ⋮        ⋮        ⋮        ⋮     ⋱
    ##  58782 │     6      0.0     14.5     14.5     14.5      0.0     34.5      0.0  ⋯
    ##  58783 │     8     14.5      0.0      0.0     14.5      0.0      0.0     24.5
    ##  58784 │   274      4.5      4.5      4.5      4.5     14.5     14.5     24.5
    ##  58785 │    12     45.5      0.0      0.0      0.0      0.0      0.0     24.5
    ##  58786 │     5     24.5      0.0     24.5      0.0      0.0      0.0      0.0  ⋯
    ##  58787 │ 18514      4.5      4.5      4.5      4.5     14.5     14.5     14.5
    ##  58788 │  1584     24.5      4.5      4.5      4.5      4.5     14.5      4.5
    ##                                                11 columns and 58773 rows omitted

### Mix and match selection

``` julia
@chain movies begin
  @select(Title, Budget:Rating)
end
```

    ## 58788×3 DataFrame
    ##    Row │ Title                     Budget    Rating
    ##        │ String                    Int32?    Float64
    ## ───────┼─────────────────────────────────────────────
    ##      1 │ $                          missing      6.4
    ##      2 │ $1000 a Touchdown          missing      6.0
    ##      3 │ $21 a Day Once a Month     missing      8.2
    ##      4 │ $40,000                    missing      8.2
    ##      5 │ $50,000 Climax Show, The   missing      3.4
    ##      6 │ $pent                      missing      4.3
    ##      7 │ $windle                    missing      5.3
    ##      8 │ '15'                       missing      6.7
    ##    ⋮   │            ⋮                 ⋮         ⋮
    ##  58782 │ pURe kILLjoy               missing      5.2
    ##  58783 │ sIDney                     missing      7.0
    ##  58784 │ tom thumb                  missing      6.5
    ##  58785 │ www.XXX.com                missing      1.1
    ##  58786 │ www.hellssoapopera.com     missing      6.6
    ##  58787 │ xXx                       85000000      5.5
    ##  58788 │ xXx: State of the Union   87000000      3.9
    ##                                    58773 rows omitted

## Rename columns

### Rename using `@select()`

You can use the `@select()` function to rename and select columns.

``` julia
@chain movies begin
  @select(title = Title, money = Budget)
end
```

    ## 58788×2 DataFrame
    ##    Row │ title                     money
    ##        │ String                    Int32?
    ## ───────┼────────────────────────────────────
    ##      1 │ $                          missing
    ##      2 │ $1000 a Touchdown          missing
    ##      3 │ $21 a Day Once a Month     missing
    ##      4 │ $40,000                    missing
    ##      5 │ $50,000 Climax Show, The   missing
    ##      6 │ $pent                      missing
    ##      7 │ $windle                    missing
    ##      8 │ '15'                       missing
    ##    ⋮   │            ⋮                 ⋮
    ##  58782 │ pURe kILLjoy               missing
    ##  58783 │ sIDney                     missing
    ##  58784 │ tom thumb                  missing
    ##  58785 │ www.XXX.com                missing
    ##  58786 │ www.hellssoapopera.com     missing
    ##  58787 │ xXx                       85000000
    ##  58788 │ xXx: State of the Union   87000000
    ##                           58773 rows omitted

### Rename using `@rename()`

You can also use the `@rename()` function to directly rename columns
without performing selection.

Note: There is currently a bug such that only one column name can be
renamed at a time.

``` julia
@chain movies begin
  @rename(title = Title)
  @rename(money = Budget)
  @select(title, money)
end
```

    ## 58788×2 DataFrame
    ##    Row │ title                     money
    ##        │ String                    Int32?
    ## ───────┼────────────────────────────────────
    ##      1 │ $                          missing
    ##      2 │ $1000 a Touchdown          missing
    ##      3 │ $21 a Day Once a Month     missing
    ##      4 │ $40,000                    missing
    ##      5 │ $50,000 Climax Show, The   missing
    ##      6 │ $pent                      missing
    ##      7 │ $windle                    missing
    ##      8 │ '15'                       missing
    ##    ⋮   │            ⋮                 ⋮
    ##  58782 │ pURe kILLjoy               missing
    ##  58783 │ sIDney                     missing
    ##  58784 │ tom thumb                  missing
    ##  58785 │ www.XXX.com                missing
    ##  58786 │ www.hellssoapopera.com     missing
    ##  58787 │ xXx                       85000000
    ##  58788 │ xXx: State of the Union   87000000
    ##                           58773 rows omitted

## Mutate columns

### Update an existing column

We will scale the `Budget` down to millions of dollars. Since there are
many missing values for `Budget`, we will first remove the missing
values.

``` julia
@chain movies begin
  @filter(!ismissing(Budget))
  @mutate(Budget = Budget/1_000_000)
  @select(Title, Budget)
end
```

    ## 5215×2 DataFrame
    ##   Row │ Title                        Budget
    ##       │ String                       Float64
    ## ──────┼────────────────────────────────────────
    ##     1 │ 'G' Men                       0.45
    ##     2 │ 'Manos' the Hands of Fate     0.019
    ##     3 │ 'Til There Was You           23.0
    ##     4 │ .com for Murder               5.0
    ##     5 │ 10 Things I Hate About You   16.0
    ##     6 │ 100 Mile Rule                 1.1
    ##     7 │ 100 Proof                     0.14
    ##     8 │ 101                           0.2
    ##   ⋮   │              ⋮                   ⋮
    ##  5209 │ Zoo Radio                     0.1
    ##  5210 │ Zookeeper, The                6.0
    ##  5211 │ Zoolander                    28.0
    ##  5212 │ Zvezda                        1.3
    ##  5213 │ Zzyzx                         1.0
    ##  5214 │ xXx                          85.0
    ##  5215 │ xXx: State of the Union      87.0
    ##                               5200 rows omitted

### Update an existing column

If we knew we wanted to select only the `Title` and `Budget` columns, we
could have also used the `@transmute()` macro, which is just an alias
for `@select()` since the two macros both use the `select()` function
from DataFrames.jl.

``` julia
@chain movies begin
  @filter(!ismissing(Budget))
  @transmute(Title = Title, Budget = Budget/1_000_000)
end
```

    ## 5215×2 DataFrame
    ##   Row │ Title                        Budget
    ##       │ String                       Float64
    ## ──────┼────────────────────────────────────────
    ##     1 │ 'G' Men                       0.45
    ##     2 │ 'Manos' the Hands of Fate     0.019
    ##     3 │ 'Til There Was You           23.0
    ##     4 │ .com for Murder               5.0
    ##     5 │ 10 Things I Hate About You   16.0
    ##     6 │ 100 Mile Rule                 1.1
    ##     7 │ 100 Proof                     0.14
    ##     8 │ 101                           0.2
    ##   ⋮   │              ⋮                   ⋮
    ##  5209 │ Zoo Radio                     0.1
    ##  5210 │ Zookeeper, The                6.0
    ##  5211 │ Zoolander                    28.0
    ##  5212 │ Zvezda                        1.3
    ##  5213 │ Zzyzx                         1.0
    ##  5214 │ xXx                          85.0
    ##  5215 │ xXx: State of the Union      87.0
    ##                               5200 rows omitted

### Add a new column

``` julia
@chain movies begin
  @filter(!ismissing(Budget))
  @mutate(Budget_Millions = Budget/1_000_000)
  @select(Title, Budget, Budget_Millions)
end
```

    ## 5215×3 DataFrame
    ##   Row │ Title                        Budget    Budget_Millions
    ##       │ String                       Int32?    Float64
    ## ──────┼────────────────────────────────────────────────────────
    ##     1 │ 'G' Men                        450000         0.45
    ##     2 │ 'Manos' the Hands of Fate       19000         0.019
    ##     3 │ 'Til There Was You           23000000        23.0
    ##     4 │ .com for Murder               5000000         5.0
    ##     5 │ 10 Things I Hate About You   16000000        16.0
    ##     6 │ 100 Mile Rule                 1100000         1.1
    ##     7 │ 100 Proof                      140000         0.14
    ##     8 │ 101                            200000         0.2
    ##   ⋮   │              ⋮                  ⋮             ⋮
    ##  5209 │ Zoo Radio                      100000         0.1
    ##  5210 │ Zookeeper, The                6000000         6.0
    ##  5211 │ Zoolander                    28000000        28.0
    ##  5212 │ Zvezda                        1300000         1.3
    ##  5213 │ Zzyzx                         1000000         1.0
    ##  5214 │ xXx                          85000000        85.0
    ##  5215 │ xXx: State of the Union      87000000        87.0
    ##                                               5200 rows omitted

## Summarizing data

Both `@summarize` and `@summarise` can be used.

``` julia
@chain movies begin
  @filter(!ismissing(Budget))
  @summarize(nrow = length(Title))
end
```

    ## 1×1 DataFrame
    ##  Row │ nrow
    ##      │ Int64
    ## ─────┼───────
    ##    1 │  5215

## Filtering data

Let’s take a look at the movies whose budget was more than average.
While it’s easy in R to do this all wthin a single `@filter()`
statement, there are still some bugs I am ironing out. In the meantime,
splitting it up as follows works perfectly fine.

``` julia
@chain movies begin
  @mutate(Budget = Budget / 1_000_000)
  @mutate(Mean_Budget = mean(skipmissing(Budget)))
  @filter(!ismissing(Budget))
  @filter(Budget >= Mean_Budget)
  @select(Title, Budget, Mean_Budget)
end
```

    ## 1438×3 DataFrame
    ##   Row │ Title                       Budget    Mean_Budget
    ##       │ String                      Float64?  Float64
    ## ──────┼───────────────────────────────────────────────────
    ##     1 │ 'Til There Was You              23.0      13.4125
    ##     2 │ 10 Things I Hate About You      16.0      13.4125
    ##     3 │ 102 Dalmatians                  85.0      13.4125
    ##     4 │ 13 Going On 30                  37.0      13.4125
    ##     5 │ 13th Warrior, The               85.0      13.4125
    ##     6 │ 1492: Conquest of Paradise      47.0      13.4125
    ##     7 │ 15 Minutes                      42.0      13.4125
    ##     8 │ 1941                            35.0      13.4125
    ##   ⋮   │             ⋮                  ⋮           ⋮
    ##  1432 │ Yes, Giorgio                    19.0      13.4125
    ##  1433 │ Ying xiong                      30.0      13.4125
    ##  1434 │ You've Got Mail                 65.0      13.4125
    ##  1435 │ Young Sherlock Holmes           18.0      13.4125
    ##  1436 │ Zoolander                       28.0      13.4125
    ##  1437 │ xXx                             85.0      13.4125
    ##  1438 │ xXx: State of the Union         87.0      13.4125
    ##                                          1423 rows omitted

## Slicing

Slicing has not been implemented yet. Here is a workaround for now.

``` julia
@chain movies begin
  @mutate(row_number = 1:length(Title))
  @filter(row_number <= 5)
end
```

    ## 5×25 DataFrame
    ##  Row │ Title                     Year   Length  Budget   Rating   Votes  R1    ⋯
    ##      │ String                    Int32  Int32   Int32?   Float64  Int32  Float ⋯
    ## ─────┼──────────────────────────────────────────────────────────────────────────
    ##    1 │ $                          1971     121  missing      6.4    348      4 ⋯
    ##    2 │ $1000 a Touchdown          1939      71  missing      6.0     20      0
    ##    3 │ $21 a Day Once a Month     1941       7  missing      8.2      5      0
    ##    4 │ $40,000                    1996      70  missing      8.2      6     14
    ##    5 │ $50,000 Climax Show, The   1975      71  missing      3.4     17     24 ⋯
    ##                                                               19 columns omitted

## Grouping

### Combining `@group_by()` with `@mutate()`

``` julia
@chain movies begin
  @group_by(Year)
  @mutate(Mean_Yearly_Rating = mean(skipmissing(Rating)))
  @select(Year, Rating, Mean_Yearly_Rating)
end
```

    ## 58788×3 DataFrame
    ##    Row │ Year   Rating   Mean_Yearly_Rating
    ##        │ Int32  Float64  Float64
    ## ───────┼────────────────────────────────────
    ##      1 │  1971      6.4             5.66517
    ##      2 │  1939      6.0             6.35041
    ##      3 │  1941      8.2             6.34107
    ##      4 │  1996      8.2             5.74712
    ##      5 │  1975      3.4             5.62908
    ##      6 │  2000      4.3             5.93442
    ##      7 │  2002      5.3             6.28432
    ##      8 │  2002      6.7             6.28432
    ##    ⋮   │   ⋮       ⋮             ⋮
    ##  58782 │  1998      5.2             5.85818
    ##  58783 │  2002      7.0             6.28432
    ##  58784 │  1958      6.5             5.90152
    ##  58785 │  2003      1.1             6.34796
    ##  58786 │  1999      6.6             5.6371
    ##  58787 │  2002      5.5             6.28432
    ##  58788 │  2005      3.9             6.51261
    ##                           58773 rows omitted

### Combining `@group_by()` with `@summarize()`

``` julia
@chain movies begin
  @group_by(Year)
  @summarize(Mean_Yearly_Rating = mean(skipmissing(Rating)))
end
```

    ## 113×2 DataFrame
    ##  Row │ Year   Mean_Yearly_Rating
    ##      │ Int32  Float64
    ## ─────┼───────────────────────────
    ##    1 │  1893             7.0
    ##    2 │  1894             4.88889
    ##    3 │  1895             5.5
    ##    4 │  1896             5.26923
    ##    5 │  1897             4.67778
    ##    6 │  1898             5.04
    ##    7 │  1899             4.27778
    ##    8 │  1900             4.73125
    ##   ⋮  │   ⋮            ⋮
    ##  107 │  1999             5.6371
    ##  108 │  2000             5.93442
    ##  109 │  2001             6.10104
    ##  110 │  2002             6.28432
    ##  111 │  2003             6.34796
    ##  112 │  2004             6.66201
    ##  113 │  2005             6.51261
    ##                   98 rows omitted
