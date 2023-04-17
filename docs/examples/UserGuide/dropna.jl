The drop all rows macro works by dropping all rows with missing values. When called without arguments, `@drop_na()` drops all rows with missing values in any column. If columns are provided as an optional argument, only missing values from named columns are considered when dropping rows.


    # `@drop_na()`

    Arguments
    df: A DataFrame or GroupedDataFrame.
    cols...: An optional column, or multiple columns separated by commas or specified using selection helpers.
    Examples

    Let's look at some example data with missing values.

    <div><div style = "float: left;"><span>6×3 DataFrame</span></div><div style = "clear: both;"></div></div><div class = "data-frame" style = "overflow-x: scroll;"><table class = "data-frame" style = "margin-bottom: 6px;"><thead><tr class = "header"><th class = "rowNumber" style = "font-weight: bold; text-align: right;">Row</th><th style = "text-align: left;">a</th><th style = "text-align: left;">b</th><th style = "text-align: left;">c</th></tr><tr class = "subheader headerLastRow"><th class = "rowNumber" style = "font-weight: bold; text-align: right;"></th><th title = "Int64" style = "text-align: left;">Int64</th><th title = "Union{Missing, Int64}" style = "text-align: left;">Int64?</th><th title = "Union{Missing, Int64}" style = "text-align: left;">Int64?</th></tr></thead><tbody><tr><td class = "rowNumber" style = "font-weight: bold; text-align: right;">1</td><td style = "text-align: right;">1</td><td style = "text-align: right;">1</td><td style = "font-style: italic; text-align: right;">missing</td></tr><tr><td class = "rowNumber" style = "font-weight: bold; text-align: right;">2</td><td style = "text-align: right;">2</td><td style = "text-align: right;">2</td><td style = "font-style: italic; text-align: right;">missing</td></tr><tr><td class = "rowNumber" style = "font-weight: bold; text-align: right;">3</td><td style = "text-align: right;">3</td><td style = "text-align: right;">3</td><td style = "font-style: italic; text-align: right;">missing</td></tr><tr><td class = "rowNumber" style = "font-weight: bold; text-align: right;">4</td><td style = "text-align: right;">7</td><td style = "font-style: italic; text-align: right;">missing</td><td style = "text-align: right;">7</td></tr><tr><td class = "rowNumber" style = "font-weight: bold; text-align: right;">5</td><td style = "text-align: right;">8</td><td style = "font-style: italic; text-align: right;">missing</td><td style = "text-align: right;">8</td></tr><tr><td class = "rowNumber" style = "font-weight: bold; text-align: right;">6</td><td style = "text-align: right;">9</td><td style = "font-style: italic; text-align: right;">missing</td><td style = "text-align: right;">9</td></tr></tbody></table></div>


    Here is an example of calling the `@dropna` macro to drop all rows with missing values.

    ```julia
    using DataFrames

    df = DataFrame(a=[1,2,3,7,8,9], b=[1,2,3,missing,missing,missing], c=[missing,missing,missing,7,8,9])
    @chain df @drop_na()
    ```

    <div><div style = "float: left;"><span>6×3 DataFrame</span></div><div style = "clear: both;"></div></div><div class = "data-frame" style = "overflow-x: scroll;"><table class = "data-frame" style = "margin-bottom: 6px;"><thead><tr class = "header"><th class = "rowNumber" style = "font-weight: bold; text-align: right;">Row</th><th style = "text-align: left;">a</th><th style = "text-align: left;">b</th><th style = "text-align: left;">c</th></tr><tr class = "subheader headerLastRow"><th class = "rowNumber" style = "font-weight: bold; text-align: right;"></th><th title = "Int64" style = "text-align: left;">Int64</th><th title = "Union{Missing, Int64}" style = "text-align: left;">Int64?</th><th title = "Union{Missing, Int64}" style = "text-align: left;">Int64?</th></tr></tbody></table></div>


    Notice that when called without arguments, `@drop_na()` drops all rows with missing values in any column. If columns are provided as an optional argument, only missing values from named columns are considered when dropping rows.

    The second argument is an optional column, or multiple columns separated by commas or specified using selection helpers. Here is an example. Consider the following data.

    <div><div style="float: left;"><span>4×2 DataFrame</span></div><div style="clear: both;"></div></div><div class="data-frame" style="overflow-x: scroll;"><table class="data-frame" style="margin-bottom: 6px;"><thead><tr class="header"><th class="rowNumber" style="font-weight: bold; text-align: right;">Row</th><th style="text-align: left;">a</th><th style="text-align: left;">b</th></tr><tr class="subheader headerLastRow"><th class="rowNumber" style="font-weight: bold; text-align: right;"></th><th title="Union{Missing, Int64}" style="text-align: left;">Int64?</th><th title="Union{Missing, Int64}" style="text-align: left;">Int64?</th></tr></thead><tbody><tr><td class="rowNumber" style="font-weight: bold; text-align: right;">1</td><td style="text-align: right;">1</td><td style="text-align: right;">1</td></tr><tr><td class="rowNumber" style="font-weight: bold; text-align: right;">2</td><td style="text-align: right;">2</td><td style="font-style: italic; text-align: right;">missing</td></tr><tr><td class="rowNumber" style="font-weight: bold; text-align: right;">3</td><td style="font-style: italic; text-align: right;">missing</td><td style="text-align: right;">3</td></tr><tr><td class="rowNumber" style="font-weight: bold; text-align: right;">4</td><td style="text-align: right;">4</td><td style="text-align: right;">4</td></tr></tbody></table></div>

    We can dropna with column  as a second argument b.


    ```julia
    df = DataFrame(
                  a = [1, 2, missing, 4],
                  b = [1, missing, 3, 4]
                )
     @chain df @drop_na(a, b)
    ```


    <div><div style="float: left;"><span>2×2 DataFrame</span></div><div style="clear: both;"></div></div><div class="data-frame" style="overflow-x: scroll;"><table class="data-frame" style="margin-bottom: 6px;"><thead><tr class="header"><th class="rowNumber" style="font-weight: bold; text-align: right;">Row</th><th style="text-align: left;">a</th><th style="text-align: left;">b</th></tr></thead><tbody><tr><td class="rowNumber" style="font-weight: bold; text-align: right;">1</td><td style="text-align: right;">1</td>
    <td style="text-align: right;">1</td></tr><tr><td class="rowNumber" style="font-weight: bold; text-align: right;">2</td><td style="text-align: right;">4</td><td style="text-align: right;">4</td></tr></tbody></table></div>

    You can find further examples in [Reference](https://TidierOrg.github.io/Tidier.jl/dev/reference/).

    *This page was generated using [Literate.jl](https://github.com/fredrikekre/Literate.jl).*

# This file was generated using Literate.jl, https://github.com/fredrikekre/Literate.jl

