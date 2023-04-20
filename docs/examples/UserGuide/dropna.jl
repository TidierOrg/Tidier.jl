# Summmary: The `drop_na` macro is used to drop rows in a DataFrame (or GroupedDataFrame) with missing values. By default all rows with missing values are dropped.  
# If columns are provided as an optional argument, only missing values from named columns are considered when dropping rows. 

# `@drop_na()` 

# Arguments
# df: A DataFrame or GroupedDataFrame.
# cols...: An optional column, or multiple columns separated by commas or specified using selection helpers.

# consider a few examples of how to use the `drop_na` macro.

using Tidier 
using DataFrames

# Basic Usage

<div><div style = "float: left;"><span>6×3 DataFrame</span></div><div style = "clear: both;"></div></div><div class = "data-frame" style = "overflow-x: scroll;"><table class = "data-frame" style = "margin-bottom: 6px;"><thead><tr class = "header"><th class = "rowNumber" style = "font-weight: bold; text-align: right;">Row</th><th style = "text-align: left;">a</th><th style = "text-align: left;">b</th><th style = "text-align: left;">c</th></tr><tr class = "subheader headerLastRow"><th class = "rowNumber" style = "font-weight: bold; text-align: right;"></th><th title = "Int64" style = "text-align: left;">Int64</th><th title = "Union{Missing, Int64}" style = "text-align: left;">Int64?</th><th title = "Union{Missing, Int64}" style = "text-align: left;">Int64?</th></tr></thead><tbody><tr><td class = "rowNumber" style = "font-weight: bold; text-align: right;">1</td><td style = "text-align: right;">1</td><td style = "text-align: right;">1</td><td style = "font-style: italic; text-align: right;">missing</td></tr><tr><td class = "rowNumber" style = "font-weight: bold; text-align: right;">2</td><td style = "text-align: right;">2</td><td style = "text-align: right;">2</td><td style = "font-style: italic; text-align: right;">missing</td></tr><tr><td class = "rowNumber" style = "font-weight: bold; text-align: right;">3</td><td style = "text-align: right;">3</td><td style = "text-align: right;">3</td><td style = "font-style: italic; text-align: right;">missing</td></tr><tr><td class = "rowNumber" style = "font-weight: bold; text-align: right;">4</td><td style = "text-align: right;">7</td><td style = "font-style: italic; text-align: right;">missing</td><td style = "text-align: right;">7</td></tr><tr><td class = "rowNumber" style = "font-weight: bold; text-align: right;">5</td><td style = "text-align: right;">8</td><td style = "font-style: italic; text-align: right;">missing</td><td style = "text-align: right;">8</td></tr><tr><td class = "rowNumber" style = "font-weight: bold; text-align: right;">6</td><td style = "text-align: right;">9</td><td style = "font-style: italic; text-align: right;">missing</td><td style = "text-align: right;">9</td></tr></tbody></table></div>

# We can use the `@dropna` macro to drop all rows with missing values.

df = DataFrame(a=[1,2,3,7,8,9], b=[1,2,3,missing,missing,missing], c=[missing,missing,missing,7,8,9])

# First, let's drop all rows. 

@chain df begin
  @drop_na()
end 

# Since all rows have at least one missing value, the result is an empty DataFrame.

<div><div style = "float: left;"><span>6×3 DataFrame</span></div><div style = "clear: both;"></div></div><div class = "data-frame" style = "overflow-x: scroll;"><table class = "data-frame" style = "margin-bottom: 6px;"><thead><tr class = "header"><th class = "rowNumber" style = "font-weight: bold; text-align: right;">Row</th><th style = "text-align: left;">a</th><th style = "text-align: left;">b</th><th style = "text-align: left;">c</th></tr><tr class = "subheader headerLastRow"><th class = "rowNumber" style = "font-weight: bold; text-align: right;"></th><th title = "Int64" style = "text-align: left;">Int64</th><th title = "Union{Missing, Int64}" style = "text-align: left;">Int64?</th><th title = "Union{Missing, Int64}" style = "text-align: left;">Int64?</th></tr></tbody></table></div>

# In some use cases, we may not want to drop all rows. Let's take a look at a more advanced example.

# Advanced Usage

# Notice that when called without arguments, `@drop_na()` drops all rows with missing values in any column specified.
# If columns are provided as an optional argument, only missing values from named columns are considered when dropping rows.
# The second argument is an optional column, or multiple columns separated by commas or specified using selection helpers. 
# Here is an example. 

<div><div style="float: left;"><span>4×2 DataFrame</span></div><div style="clear: both;"></div></div><div class="data-frame" style="overflow-x: scroll;"><table class="data-frame" style="margin-bottom: 6px;"><thead><tr class="header"><th class="rowNumber" style="font-weight: bold; text-align: right;">Row</th><th style="text-align: left;">a</th><th style="text-align: left;">b</th></tr><tr class="subheader headerLastRow"><th class="rowNumber" style="font-weight: bold; text-align: right;"></th><th title="Union{Missing, Int64}" style="text-align: left;">Int64?</th><th title="Union{Missing, Int64}" style="text-align: left;">Int64?</th></tr></thead><tbody><tr><td class="rowNumber" style="font-weight: bold; text-align: right;">1</td><td style="text-align: right;">1</td><td style="text-align: right;">1</td></tr><tr><td class="rowNumber" style="font-weight: bold; text-align: right;">2</td><td style="text-align: right;">2</td><td style="font-style: italic; text-align: right;">missing</td></tr><tr><td class="rowNumber" style="font-weight: bold; text-align: right;">3</td><td style="font-style: italic; text-align: right;">missing</td><td style="text-align: right;">3</td></tr><tr><td class="rowNumber" style="font-weight: bold; text-align: right;">4</td><td style="text-align: right;">4</td><td style="text-align: right;">4</td></tr></tbody></table></div>

#We can dropna  with 2 arguments, columns a and b.

df = DataFrame(
    a = [1, 2, missing, 4],
    b = [1, missing, 3, 4]
 )

@chain df begin
  @drop_na(a, b)
end 
  
# In this case, drop_na drops the 2nd and the third row since both columns a and b have a missing value in the 3rd and 2nd row respectively. 

<div><div style="float: left;"><span>2×2 DataFrame</span></div><div style="clear: both;"></div></div><div class="data-frame" style="overflow-x: scroll;"><table class="data-frame" style="margin-bottom: 6px;"><thead><tr class="header"><th class="rowNumber" style="font-weight: bold; text-align: right;">Row</th><th style="text-align: left;">a</th><th style="text-align: left;">b</th></tr></thead><tbody><tr><td class="rowNumber" style="font-weight: bold; text-align: right;">1</td><td style="text-align: right;">1</td>
<td style="text-align: right;">1</td></tr><tr><td class="rowNumber" style="font-weight: bold; text-align: right;">2</td><td style="text-align: right;">4</td><td style="text-align: right;">4</td></tr></tbody></table></div>

# We can look at a practical example using RDatasets to install this package use Pkg.add("RDatasets").

using RDatasets

iris = dataset("datasets", "iris")
neuro = dataset("boot", "neuro")

@chain neuro begin
  @drop_na()
end

# The code above drops all missing values. Notice the original variable neuro is not modified. 
# If we want to drop only missing values in the first row we can use positional index 1.

@chain neuro begin
  @drop_na(1)
end

# Additional Help

# We can use the dir command to get additional help.
