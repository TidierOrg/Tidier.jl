
# A Simple Data Analysis {#A-Simple-Data-Analysis}

## Loading Tidier.jl {#Loading-Tidier.jl}

Once you&#39;ve installed Tidier.jl, you can load it by typing:

```julia
using Tidier
```


When you type this command, multiple things happen behind the scenes. First, the following packages are loaded and re-exported, which is to say that all of the exported macros and functions from these packages become available, TidierData, TidierPlots, TidierDB, TidierCats, TidierDates, TidierStrings, TidierText, TidierVest, and TidierIteration.

Don&#39;t worry if you don&#39;t know what each of these packages does yet. We will cover them in package-specific documentation pages, which can be accessed below. For now, all you need to know is that these smaller packages are actually the ones doing all the work when you use Tidier.

There are also a few other packages whose exported functions also become available. We will discuss these in the individual package documentation, but the most important ones for you to know about are:
- The `DataFrame()` function from the DataFrames package is re-exported so that you can create a data frame without loading the DataFrames package.
  
- The `@chain()` macro from the Chain package is re-exported, so you chain together functions and macros
  
- The entire Statistics package is re-exported so you can access summary statistics like `mean()` and `median()`
  
- The CategoricalArrays package is re-exported so you can access the `categorical()` function to define categorical variables
  
- The Dates package is re-exported to enable support for variables containing dates
  

## What can Tidier.jl do? {#What-can-Tidier.jl-do?}

Before we dive into an introduction of Julia and a look into how Tidier.jl works, it&#39;s useful to show you what Tidier.jl can do. First, we will read in some data, and then we will use Tidier.jl to chain together some data analysis operations.

### First, let&#39;s read in the &quot;Visits to Physician Office&quot; dataset. {#First,-let's-read-in-the-"Visits-to-Physician-Office"-dataset.}

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


### With the OFP dataset loaded, let&#39;s ask some basic questions. {#With-the-OFP-dataset-loaded,-let's-ask-some-basic-questions.}

#### What does the dataset consist of? {#What-does-the-dataset-consist-of?}

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


If you&#39;re wondering why we need to place a `@` at the beginning of the word so that it reads `@glimpse()` rather than `glimpse()`, that&#39;s because including a `@` at the beginning denotes that this is a special type of function known as a macro. Macros have special capabilities in Julia, and many Tidier.jl functions that operate on data frames are implemented as macros. In this specific instance, we could have implemented `@glimpse()` without making use of any of the macro capabilities. However, for the sake of consistency, we have kept `@glimpse()` as a macro so that you can remember a basic rule of thumb: if Tidier.jl operates on a dataframe, then we will use macros rather than functions. The TidierPlots.jl package is a slight exception to this rule in that it is nearly entirely implemented as functions (rather than macros), and this will be described more in the TidierPlots documentation.

#### Can we clean up the names of the columns? {#Can-we-clean-up-the-names-of-the-columns?}

To avoid having to keep track of capitalization, data analysts often prefer column names to be in snake_case rather than TitleCase. Let&#39;s quickly apply this transformation to the `ofp` dataset.

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

#### What is the mean age for people in each of the regions {#What-is-the-mean-age-for-people-in-each-of-the-regions}

Because age is measured in decades according to the [dataset documentation](https://rdrr.io/cran/Ecdat/man/OFP.html)), we will multiply everyone&#39;s age by 10 before we calculate the median.

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


Overall, the mean age looks pretty similar across regions. The fact that we were able to calculate each region&#39;s age also reveals that there are no missing values. Any region containing a missing value would have returned `missing` instead of a number.

The `@chain` macro, which is defined in the Chain package and re-exported by Tidier, allows us to pipe together multiple operations sequentially from left to right. In the example above, the `ofp` dataset is being piped into the first argument of the `@group_by()` macro, the result of which is then being piped into the `@summarize()` macro, which is then automatically removing the grouping and returning the result.

For grouped data frames, `@summarize()` behaves differently than other Tidier.jl macros: `@summarize()` removes one layer of grouping. Because the data frame was only grouped by one column, the result is no longer grouped. Had we grouped by multiple columns, the result would still be grouped by all but the last column. The other Tidier.jl macros keep the data grouped. Grouped data frames can be ungrouped using `@ungroup()`. If you apply a new `@group_by()` macro to an already-grouped data frame, then the newly specified groups override the old ones.

When we use the `@chain` macro, we are taking advantage of the fact that Julia macros can either be called using parentheses syntax, where each argument is separated by a comma, or they can be called with a spaced syntax where no parentheses are used. In the case of Tidier.jl macros, we always use the parentheses syntax, which makes is very easy to use the spaced syntax when working with `@chain`.

An alternate way of calling `@chain` using the parentheses syntax is as follows. From a purely stylistic perspective, I don&#39;t recommend this because it adds a number of extra characters. However, if you&#39;re new to Julia, it&#39;s worth knowing about this form so that you realize that there is no magic involved when working with macros.

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

