<a href="https://github.com/TidierOrg/Tidier.jl"><img src="https://raw.githubusercontent.com/TidierOrg/Tidier.jl/main/docs/src/assets/Tidier\_jl\_logo.png" align="left" style="padding-right:10px;" width="150"></img></a>

## <a href="https://github.com/TidierOrg/Tidier.jl">Tidier.jl</a>

Tidier.jl is a data analysis package inspired by R's tidyverse and crafted specifically for Julia. Tidier.jl is a meta-package in that its functionality comes from a series of smaller packages. Installing and using Tidier.jl brings the combined functionality of each of these packages to your fingertips.

[[GitHub]](https://github.com/TidierOrg/Tidier.jl) | [[Documentation]](https://tidierorg.github.io/Tidier.jl/dev/)

## Installing Tidier.jl

There are 2 ways to install Tidier.jl: using the package console, or using Julia code when you're using the Julia console. You might also see the console referred to as the "REPL," which stands for Read-Evaluate-Print Loop. The REPL is where you can interactively run code and view the output.

Julia's REPL is particularly cool because it provides a built-in package REPL and shell REPL, which allow you to take actions on managing packages (in the case of the package REPL) or run shell commands (in the shell REPL) without ever leaving the Julia REPL.

To install the stable version of Tidier.jl, you can type the following into the Julia REPL:

```
]add Tidier
```

The `]` character starts the Julia [package manager](https://docs.julialang.org/en/v1/stdlib/Pkg/). The `add Tidier` command tells the package manager to install the Tidier package from the Julia registry. You can exit the package REPL by pressing the backspace key to return to the Julia prompt.

If you already have the Tidier package installed, the `add Tidier` command *will not* update the package. Instead, you can update the package using the the `update Tidier` (or `up Tidier` for short) commnds. As with the `add Tidier` command, make sure you are in the package REPL before you run these package manager commands.

If you need to (or prefer to) install packages using Julia code, you can achieve the same outcome using the following code to install Tidier:

```julia
import Pkg
Pkg.add("Tidier")
```

You can update Tidier.jl using the `Pkg.update()` function, as follows:

```julia
import Pkg; Pkg.update("Tidier")
```

Note that while Julia allows you to separate statements by using multiple lines of code, you can also use a semi-colon (`;`) to separate multiple statements. This is convenient for short snippets of code. There's another practical reason to use semi-colons in coding, which is to silence the output of a function call. We will come back to this in the "Getting Started" section below.

In general, installing the latest version of the package from the Julia registry should be sufficient because we follow a continuous-release cycle. After every update to the code, we update the version based on the magnitude of the change and then release the latest version to the registry. That's why it's so important to know how to update the package!

However, if for some reason you do want to install the package directly from GitHub, you can get the newest version using either the package REPL...

```
]add Tidier#main
```

...or using Julia code.

```julia
import Pkg; Pkg.add(url="https://github.com/TidierOrg/Tidier.jl")
```

## Loading Tidier.jl

Once you've installed Tidier.jl, you can load it by typing:

```julia
using Tidier
```

When you type this command, multiple things happen behind the scenes. First, the following packages are loaded and re-exported, which is to say that all of the exported macros and functions from these packages become available:

- TidierData
- TidierPlots
- TidierCats
- TidierDates
- TidierStrings
- TidierText
- TidierVest

Don't worry if you don't know what each of these packages does yet. We will cover them in package-specific documentation pages, which can be accessed below. For now, all you need to know is that these smaller packages are actually the ones doing all the work when you use Tidier.

There are also a few other packages whose exported functions also become available. We will discuss these in the individual package documentation, but the most important ones for you to know about are:

- The `DataFrame()` function from the DataFrames package is re-exported so that you can create a data frame without loading the DataFrames package.
- The `@chain()` macro from the Chain package is re-exported, so you chain together functions and macros
- The entire Statistics package is re-exported so you can access summary statistics like `mean()` and `median()`
- The CategoricalArrays package is re-exported so you can access the `categorical()` function to define categorical variables
- The Dates package is re-exported to enable support for variables containing dates

## What can Tidier.jl do?

Before we dive into an introduction of Julia and a look into how Tidier.jl works, it's useful to show you what Tidier.jl can do. First, we will read in some data, and then we will use Tidier.jl to chain together some data analysis operations.

### First, let's read in the "Visits to Physician Office" dataset.

This dataset comes with the Ecdat R package and and is titled OFP. [You can read more about the dataset here](https://rdrr.io/cran/Ecdat/man/OFP.html). To read in datasets packaged with commonly used R packages, we can use the RDatasets Julia package.

```julia
julia> using Tidier, RDatasets
julia> ofp = dataset("Ecdat", "OFP")

4406×19 DataFrame
  Row │ OFP    OFNP   OPP    OPNP   EMR    Hosp   NumChro ⋯
      │ Int32  Int32  Int32  Int32  Int32  Int32  Int32   ⋯
──────┼────────────────────────────────────────────────────
    1 │     5      0      0      0      0      1          ⋯
    2 │     1      0      2      0      2      0
    3 │    13      0      0      0      3      3
    4 │    16      0      5      0      1      1
    5 │     3      0      0      0      0      0          ⋯
    6 │    17      0      0      0      0      0
    7 │     9      0      0      0      0      0
  ⋮   │   ⋮      ⋮      ⋮      ⋮      ⋮      ⋮       ⋮    ⋱
 4401 │    12      4      1      0      0      0
 4402 │    11      0      0      0      0      0          ⋯
 4403 │    12      0      0      0      0      0
 4404 │    10      0     20      0      1      1
 4405 │    16      1      0      0      0      0
 4406 │     0      0      0      0      0      0          ⋯
                           13 columns and 4393 rows omitted
```

Note that a preview of the data frame is automatically printed to the console. The reason this happens is that when you run this code line by line, the output of each line is printed to the console. This is convenient because it saves you from having to directly print the newly created `ofp` to the console in order to get a preview for what it contains. If this code were bundled in a code chunk (such as in a Jupyter notebook), then only the final line of the code chunk would be printed.

The exact number of rows and columns that print will depend on the physical size of the REPL window. If you resize the console (e.g., in VS Code), Julia will adjust the number of rows/columns accordingly.

If you want to suppress the output, you can add a `;` at the end of this statement, like this:

```julia
julia> ofp = dataset("Ecdat", "OFP"); # Nothing prints
```

### With the OFP dataset loaded, let's ask some basic questions.

#### What does the dataset consist of?

We can use `@glimpse()` to find out the columns, data types, and peek at the first few values contained within the dataset.

```julia
julia> @glimpse(ofp)

Rows: 4406
Columns: 19
.OFP           Int32          5, 1, 13, 16, 3, 17, 9, 3, 1, 0, 0, 44, 2, 1, 19, 
.OFNP          Int32          0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 0, 0, 0, 0, 0,
.OPP           Int32          0, 2, 0, 5, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 1, 0, 0,
.OPNP          Int32          0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0,
.EMR           Int32          0, 2, 3, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
.Hosp          Int32          1, 0, 3, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0,
.NumChron      Int32          2, 2, 4, 2, 2, 5, 0, 0, 0, 0, 1, 5, 1, 1, 1, 0, 1,
.AdlDiff       Int32          0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 1,
.Age           Float64        6.9, 7.4, 6.6, 7.6, 7.9, 6.6, 7.5, 8.7, 7.3, 7.8, 
.Black         CategoricalValue{String, UInt8}yes, no, yes, no, no, no, no, no, 
.Sex           CategoricalValue{String, UInt8}male, female, female, male, female
.Married       CategoricalValue{String, UInt8}yes, yes, no, yes, yes, no, no, no
.School        Int32          6, 10, 10, 3, 6, 7, 8, 8, 8, 8, 8, 15, 8, 8, 12, 8
.FamInc        Float64        2.881, 2.7478, 0.6532, 0.6588, 0.6588, 0.3301, 0.8
.Employed      CategoricalValue{String, UInt8}yes, no, no, no, no, no, no, no, n
.Privins       CategoricalValue{String, UInt8}yes, yes, no, yes, yes, no, yes, y
.Medicaid      CategoricalValue{String, UInt8}no, no, yes, no, no, yes, no, no, 
.Region        CategoricalValue{String, UInt8}other, other, other, other, other,
.Hlth          CategoricalValue{String, UInt8}other, other, poor, poor, other, p
```

If you're wondering why we need to place a `@` at the beginning of the word so that it reads `@glimpse()` rather than `glimpse()`, that's because including a `@` at the beginning denotes that this is a special type of function known as a macro. Macros have special capabilities in Julia, and many Tidier.jl functions that operate on data frames are implemented as macros. In this specific instance, we could have implemented `@glimpse()` without making use of any of the macro capabilities. However, for the sake of consistency, we have kept `@glimpse()` as a macro so that you can remember a basic rule of thumb: if Tidier.jl operates on a dataframe, then we will use macros rather than functions. The TidierPlots.jl package is a slight exception to this rule in that it is nearly entirely implemented as functions (rather than macros), and this will be described more in the TidierPlots documentation.

#### Can we clean up the names of the columns?

To avoid having to keep track of capitalization, data analysts often prefer column names to be in snake_case rather than TitleCase. Let's quickly apply this transformation to the `ofp` dataset.

```julia
julia> ofp = @clean_names(ofp)
julia> @glimpse(ofp)

Rows: 4406
Columns: 19
.ofp           Int32          5, 1, 13, 16, 3, 17, 9, 3, 1, 0, 0, 44, 2, 1, 19, 
.ofnp          Int32          0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 0, 0, 0, 0, 0,
.opp           Int32          0, 2, 0, 5, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 1, 0, 0,
.opnp          Int32          0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0,
.emr           Int32          0, 2, 3, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
.hosp          Int32          1, 0, 3, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0,
.num_chron     Int32          2, 2, 4, 2, 2, 5, 0, 0, 0, 0, 1, 5, 1, 1, 1, 0, 1,
.adl_diff      Int32          0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 1,
.age           Float64        6.9, 7.4, 6.6, 7.6, 7.9, 6.6, 7.5, 8.7, 7.3, 7.8, 
.black         CategoricalValue{String, UInt8}yes, no, yes, no, no, no, no, no, 
.sex           CategoricalValue{String, UInt8}male, female, female, male, female
.married       CategoricalValue{String, UInt8}yes, yes, no, yes, yes, no, no, no
.school        Int32          6, 10, 10, 3, 6, 7, 8, 8, 8, 8, 8, 15, 8, 8, 12, 8
.fam_inc       Float64        2.881, 2.7478, 0.6532, 0.6588, 0.6588, 0.3301, 0.8
.employed      CategoricalValue{String, UInt8}yes, no, no, no, no, no, no, no, n
.privins       CategoricalValue{String, UInt8}yes, yes, no, yes, yes, no, yes, y
.medicaid      CategoricalValue{String, UInt8}no, no, yes, no, no, yes, no, no, 
.region        CategoricalValue{String, UInt8}other, other, other, other, other,
.hlth          CategoricalValue{String, UInt8}other, other, poor, poor, other, p
```

Now that our column names are cleaned up, we can ask some basic analysis questions.

#### What is the mean age for people in each of the regions

Because age is measured in decades according to the [dataset documentation](https://rdrr.io/cran/Ecdat/man/OFP.html)), we will multiply everyone's age by 10 before we calculate the median.

```julia
julia> @chain ofp @group_by(region) @summarize(mean_age = mean(age * 10))

4×2 DataFrame
 Row │ region   mean_age 
     │ Cat…     Float64  
─────┼───────────────────
   1 │ other     73.987
   2 │ midwest   74.0769
   3 │ noreast   73.9343
   4 │ west      74.1165
```

Overall, the mean age looks pretty similar across regions. The fact that we were able to calculate each region's age also reveals that there are no missing values. Any region containing a missing value would have returned `missing` instead of a number.

The `@chain` macro, which is defined in the Chain package and re-exported by Tidier, allows us to pipe together multiple operations sequentially from left to right. In the example above, the `ofp` dataset is being piped into the first argument of the `@group_by()` macro, the result of which is then being piped into the `@summarize()` macro, which is then automatically removing the grouping and returning the result.

For grouped data frames, `@summarize()` behaves differently than other Tidier.jl macros: `@summarize()` removes one layer of grouping. Because the data frame was only grouped by one column, the result is no longer grouped. Had we grouped by multiple columns, the result would still be grouped by all but the last column. The other Tidier.jl macros keep the data grouped. Grouped data frames can be ungrouped using `@ungroup()`. If you apply a new `@group_by()` macro to an already-grouped data frame, then the newly specified groups override the old ones.

When we use the `@chain` macro, we are taking advantage of the fact that Julia macros can either be called using parentheses syntax, where each argument is separated by a comma, or they can be called with a spaced syntax where no parentheses are used. In the case of Tidier.jl macros, we always use the parentheses syntax, which makes is very easy to use the spaced syntax when working with `@chain`.

An alternate way of calling `@chain` using the parentheses syntax is as follows. From a purely stylistic perspective, I don't recommend this because it adds a number of extra characters. However, if you're new to Julia, it's worth knowing about this form so that you realize that there is no magic involved when working with macros.

```julia
julia> @chain(ofp, @group_by(region), @summarize(mean_age = mean(age * 10)))

4×2 DataFrame
 Row │ region   mean_age 
     │ Cat…     Float64  
─────┼───────────────────
   1 │ other     73.987
   2 │ midwest   74.0769
   3 │ noreast   73.9343
   4 │ west      74.1165
```

On the other hand, either of these single-line expressions can get quite hard-to-read as more and more expressions are chained together. To make this easier to handle, `@chain` supports multi-line expressions using `begin-end` blocks like this:

```julia
julia> @chain ofp begin
           @group_by(region)
           @summarize(mean_age = mean(age * 10))
       end

4×2 DataFrame
 Row │ region   mean_age 
     │ Cat…     Float64  
─────┼───────────────────
   1 │ other     73.987
   2 │ midwest   74.0769
   3 │ noreast   73.9343
   4 │ west      74.1165
```

This format is convenient for interactive data analysis because you can easily comment out individual operations and view the result. For example, if we wanted to know the mean age for the overall dataset, we could simply comment out the `@group_by()` operation.

```julia
julia> @chain ofp begin
           # @group_by(region)
           @summarize(mean_age = mean(age * 10))
       end

1×1 DataFrame
 Row │ mean_age 
     │ Float64  
─────┼──────────
   1 │  74.0241
```
## Frequently asked questions

### I'm a Julia user. Why should I use Tidier.jl rather than other data analysis packages?

While Julia has a number of great data analysis packages, the most mature and idiomatic Julia package for data analysis is DataFrames.jl. Most other data analysis packages in Julia build on top of DataFrames.jl, and Tidier.jl is no exception.

DataFrames.jl emphasizes idiomatic Julia code without macros. While it is elegant, it can be verbose because of the need to write out anonymous functions. DataFrames.jl also emphasizes correctness, which means that errors are favored over warnings. For example, grouping by one variable and then subsequently grouping the already-grouped data frame by another variable results in an error in DataFrames.jl. These restrictions, while justified in some instances, can make interactive data analysis feel clunky and slow.

A number of macro-based data analysis packages have emerged as extensions of DataFrames.jl to make data analysis syntax less verbose, including DataFramesMeta.jl, Query.jl, and DataFrameMacros.jl. All of these packages have their strengths, and each of these served as an inspiration towards the creation of Tidier.jl.

What sets Tidier.jl apart is that it borrows the design of the tried-and-widely-adopted tidyverse and brings it to Julia. Our goal is to make data analysis code as easy and readable as possible. In our view, the reason you should use Tidier.jl is because of the richness, consistency, and thoroughness of the design made possible by bringing together two powerful tools: DataFrames.jl and the tidyverse. In Tidier.jl, nearly every possible transformation on data frames (e.g., aggregating, pivoting, nesting, and joining) can be accomplished using a consistent syntax. While you always have the option to intermix Tidier.jl code with DataFrames.jl code, Tidier.jl strives for completeness -- there should never be a requirement to fall back to DataFrames.jl for any kind of data analysis task.

Tidier.jl also focuses on conciseness. This shows up most readily in two ways: the use of bare column names, and an approach to auto-vectorizing code.

1. **Bare column names:** If you are referring to a column named `a`, you can simply refer to it as `a` in Tidier.jl. You are essentially referring to `a` as if it was within an anonymous function, where the variable `a` was mapped to the column `a` in the data frame. If you want to refer to an object `a` that is defined outside of the data frame, then you can write `!!a`, which we refer to as "bang-bang interpolation." This syntax is motivated by the tidyverse, where [the `!!` operator was selected because it is the least-bad "polite fiction" way of representing lazy interpolation](https://adv-r.hadley.nz/quasiquotation.html#the-polite-fiction-of).

2. **Auto-vectorized code:** Most data transformation functions and operators are intended to be used on scalars. However, transformations are usually performed on columns of data (represented as 1-dimensional arrays, or vectors), which means that most functions need to be vectorized, which can get unwieldy and verbose. However, there are functions which operate directly on vectors and thus should not be vectorized when applied to columns (e.g., `mean()` and `median()`). Tidier.jl uses a customizable look-up table to know which functions to vectorize and which ones not to vectorize. This means that you can largely leave code as un-vectorized (i.e., `mean(a + 1)` rather than `mean(a .+ 1)`), and Tidier.jl will correctly infer convert the first code into the second before running it. There are several ways to manually override the defaults.

Lastly, the reason you should consider using Tidier.jl is that it brings a consistent syntax not only to data manipulation but also to plotting (by wrapping Makie.jl and AlgebraOfGraphics.jl) and to the handling of categorical variables, strings, and dates. Wherever possible, Tidier.jl uses existing classes rather than defining new ones. As a result, using Tidier.jl should never preclude you from using other Base Julia functions with which you may already be familiar.

### I'm an R user and I'm perfectly happy with the tidyverse. Why should I consider using Tidier.jl?

If you're happy with the R tidyverse, then there's no imminent reason to switch to using Tidier.jl. While DataFrames.jl (the package on which TidierData.jl depends) [is faster than R's dplyr and tidyr on benchmarks](https://duckdblabs.github.io/db-benchmark/), there are other faster backends in R that allow for the use of tidyverse syntax with better speed (e.g., dtplyr, tidytable, tidypolars).

The primary reason to consider using Tidier.jl is the value proposition of using Julia itself. Julia has many similarities to R (e.g., interactive coding in a console, functional style, multiple dispatch, dynamic data types), but unlike R, Julia is automatically compiled (to LLVM) before it runs. This means that certain compiler optimations, which are normally only possible in more verbose languages like C/C++ become available to Julia. There are a number of situations in R where the end-user is able to write fast R code as a direct result of C++ being used on the backend (e.g., through the use of the Rcpp package). This is why R is sometimes referred to as a glue language -- because it provides a very nice way of glueing together faster C++ code.

The main value proposition of Julia is that you can use it as *both* a glue language *and* as a backend language. Tidier.jl embraces the glue language aspect of Julia while relying on packages like DataFrames.jl and Makie.jl on the backend.

While Julia has very mature backends, we hope that Tidier.jl demonstrates the value of, and need for, more glue-oriented data analysis packages in Julia.

### Why does Tidier.jl re-export so many packages?

Tidier comes with batteries included. If you are using Tidier, you generally won't have to load in other packages for basic data analysis. Tidier is meant for interactive use. You can start your code with `using Tidier` and expect to have what you need at your fingertips.

If you are a package developer, then you definitely should consider depending on one of the smaller packages that make up Tidier.jl rather than Tidier itself. For example, if you want to use the categorical variable functions from Tidier, then you should use rely on only TidierCats.jl as a dependency.

### Should I update Tidier.jl or the underlying packages (e.g., TidierPlots.jl) individually?

Either approach is okay. For most users, we recommend updating Tidier.jl directly, as this will update the underlying packages up to their latest minor versions (but not necessarily up to their latest patch release). However, if you need access to the latest functionality in the underlying packages, you should feel free to update them directly. We will keep Tidier.jl future-proof to underlying package updates, so this shouldn't cause any problems with Tidier.jl.

### Where can I learn more about the underlying packages that make up Tidier.jl?

<a href="https://tidierorg.github.io/TidierData.jl/latest/"><img src="https://raw.githubusercontent.com/TidierOrg/TidierData.jl/main/docs/src/assets/Tidier\_jl\_logo.png" align="left" style="padding-right:10px;" width="150"></img></a>

## <a href="https://tidierorg.github.io/TidierData.jl/latest/">TidierData.jl</a>

TidierData.jl is a package dedicated to data transformation and reshaping, powered by DataFrames.jl, ShiftedArrays.jl, and Cleaner.jl. It focuses on functionality within the dplyr, tidyr, and janitor R packages.

[[GitHub]](https://github.com/TidierOrg/TidierData.jl) | [[Documentation]](https://tidierorg.github.io/TidierData.jl/latest/)

<br><br>

<a href="https://tidierorg.github.io/TidierPlots.jl/latest/"><img src="https://raw.githubusercontent.com/TidierOrg/TidierPlots.jl/main/assets/logo.png" align="left" style="padding-right:10px;" width="150"></img></a>

## <a href="https://tidierorg.github.io/TidierPlots.jl/latest/">TidierPlots.jl</a>

TidierPlots.jl is a package dedicated to plotting, powered by AlgebraOfGraphics.jl. It focuses on functionality within the ggplot2 R package.

[[GitHub]](https://github.com/TidierOrg/TidierPlots.jl) | [[Documentation]](https://tidierorg.github.io/TidierPlots.jl/latest/)

<br><br>

<a href="https://tidierorg.github.io/TidierCats.jl/dev/"><img src="https://raw.githubusercontent.com/TidierOrg/TidierCats.jl/main/docs/src/assets/TidierCats\_logo.png" align="left" style="padding-right:10px;" width="150"></img></a>

## <a href="https://tidierorg.github.io/TidierCats.jl/dev/">TidierCats.jl</a>

TidierCats.jl is a package dedicated to handling categorical variables, powered by CategoricalArrays.jl. It focuses on functionality within the forcats R package.

[[GitHub]](https://github.com/TidierOrg/TidierCats.jl) | [[Documentation]](https://tidierorg.github.io/TidierCats.jl/dev/)

<br><br>

<a href="https://github.com/TidierOrg/TidierDates.jl"><img src="https://raw.githubusercontent.com/TidierOrg/TidierDates.jl/main/docs/src/assets/TidierDates\_logo.png" align="left" style="padding-right:10px;" width="150"></img></a>

## <a href="https://github.com/TidierOrg/TidierDates.jl">TidierDates.jl</a>

TidierDates.jl is a package dedicated to handling dates and times. It focuses on functionality within the lubridate R package.

[[GitHub]](https://github.com/TidierOrg/TidierDates.jl) | [[Documentation]](https://tidierorg.github.io/TidierDates.jl/dev/)

<br><br>

<a href="https://tidierorg.github.io/TidierStrings.jl/dev/"><img src="https://raw.githubusercontent.com/TidierOrg/TidierStrings.jl/main/docs/src/assets/TidierStrings\_logo.png" align="left" style="padding-right:10px;" width="150"></img></a>

## <a href="https://tidierorg.github.io/TidierStrings.jl/dev/">TidierStrings.jl</a>

TidierStrings.jl is a package dedicated to handling strings. It focuses on functionality within the stringr R package.

[[GitHub]](https://github.com/TidierOrg/TidierStrings.jl) | [[Documentation]](https://tidierorg.github.io/TidierStrings.jl/dev/)

<br><br>

<a href="https://github.com/TidierOrg/TidierText.jl"><img src="https://raw.githubusercontent.com/TidierOrg/TidierText.jl/main/docs/src/assets/TidierText\_logo.png" align="left" style="padding-right:10px;" width="150"></img></a>

## <a href="https://github.com/TidierOrg/TidierText.jl">TidierText.jl</a>

TidierText.jl is a package dedicated to handling and tidying text data. It focuses on functionality within the tidytext R package.

[[GitHub]](https://github.com/TidierOrg/TidierText.jl)

<br><br>

<a href="https://github.com/TidierOrg/TidierVest.jl"><img src="https://raw.githubusercontent.com/TidierOrg/TidierVest.jl/main/docs/src/assets/TidierVest\_logo.png" align="left" style="padding-right:10px;" width="150"></img></a>

## <a href="https://github.com/TidierOrg/TidierVest.jl">TidierVest.jl</a>

TidierVest.jl is a package dedicated to scraping and tidying website data. It focuses on functionality within the rvest R package.

[[GitHub]](https://github.com/TidierOrg/TidierVest.jl)

<br><br>

## What’s new in the Tidier.jl meta-package?

See [NEWS.md](https://github.com/TidierOrg/Tidier.jl/blob/main/NEWS.md) for the latest updates.

## What's missing

Is there a tidyverse feature missing that you would like to see in Tidier.jl? Please file a GitHub issue to start a discussion.