# Summmary: The `drop_na` macro is used to drop rows in a DataFrame (or GroupedDataFrame) with missing values. By default all rows with missing values are dropped.  
# If columns are provided as an optional argument, only missing values from named columns are considered when dropping rows. 
# In this tutorial we will cover the following.

# `@drop_na()` tutorial topics

##- Arguments
##- Basic Usage
##- Examples
##    - Adding additional columns 
##    - Using `drop_na` with other macros
##- Advanced Examples 
##    - Missing Values in Julia
##    - Using `drop_na` with RDataSets
## - Additional Help

# Arguments
## df: A DataFrame or GroupedDataFrame.
## cols...: An optional column, or multiple columns separated by commas or specified using selection helpers.

## consider a few examples of how to use the `drop_na` macro.

using Tidier 
using DataFrames

# Basic Usage

df = DataFrame(a=[1,2,3,7,8,9], b=[1,2,3,missing,missing,missing], c=[missing,missing,missing,7,8,9])

## We can use the `@dropna` macro to drop all rows with missing values.
@chain df begin
  @drop_na()
end 

# Examples

## Here is a second example using different data.

## Create a DataFrame with missing values
df = DataFrame(
    a = [1, 2, missing],
    b = [missing, 4, 5],
    c = [6, missing, 8]
)

## Drop all rows with missing values
@chain df begin
  @drop_na()
end 

## What if we want to only drop missing values in a single column? We could add column b.

@chain df begin
  @drop_na(b)
end

## We can continue this process to add additional columns separating them with a comma delimiter. This example drops missing values in columns b and c.

df = DataFrame(
    a = [1, 2, missing, 4],
    b = [1, missing, 3, 4]
 )

@chain df begin
  @drop_na(a, b)
end 
  
## In this case, drop_na drops the 2nd and the third row since both columns a and b have a missing value in the 3rd and 2nd row respectively. 
## Another interesting use case is combining drop_na with other macros such as starts_with. 
## We can use this to only drop columns with missing values in columns that start with "f" in this case, column foo matches.

df = DataFrame(
    foo = [1, 2, missing, 4],
    bar = [1, missing, 3, 4]
 )
@chain df begin
	@drop_na(starts_with("f"))
end

# Advaned Examples

## We can look at a practical example using RDatasets to install this package use Pkg.add("RDatasets").

using RDatasets
iris = dataset("datasets", "iris")

# Missing Values

## Julia provides support for representing missing values where there is no value available for a variable for an observation. 
## Julia represents missing values using the missing object which behaves like NA in R in most scenarios.
# You can read about missing values by visiting [official Julia website](https://docs.julialang.org/en/v1/manual/missing/).


## Let's add some missing values to the iris data set. We first use allowmissing to allow missing values and assing a missing value.

iris = allowmissing(iris)
iris.PetalLength[1] = missing

## Now we can use dropa to remove missing values.

@chain iris begin
	@drop_na(starts_with("Petal"))
end

# Additional Help

## You can use the following to genreate more examples and get additional help for the `drop_na` macro.

?@drop_na
