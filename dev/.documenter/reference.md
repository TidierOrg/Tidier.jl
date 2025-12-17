


## Reference - Exported functions {#Reference-Exported-functions}
<details class='jldocstring custom-block' open>
<summary><a id='TidierFiles.write_file-Tuple{SQLQuery, Any, Vararg{Any}}' href='#TidierFiles.write_file-Tuple{SQLQuery, Any, Vararg{Any}}'><span class="jlbinding">TidierFiles.write_file</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
 write_file(sql_query::SQLQuery, path)
```


Write a local file to from sql_query. Only supports DuckDB at this time.

**Arguments**
- `sql_query`: The SQL query
  
- `path`: file path with file type suffix ie &quot;path.csv&quot;, &quot;path.parquet&quot;, etc 
  

**Examples**

```julia
julia> db = connect(duckdb());

julia> df = DataFrame(a = ["1-1", "2-2", "3-3-3"]); 

julia> @chain dt(db, df, "df") @filter(a == "2-2") write_file("test.parquet")
(Count = [1],)
```



<Badge type="info" class="source-link" text="source"><a href="github.com/TidierOrg/Tidier.jl" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Tidier.@anti_join-Tuple{Any, Any, Vararg{Any}}' href='#Tidier.@anti_join-Tuple{Any, Any, Vararg{Any}}'><span class="jlbinding">Tidier.@anti_join</span></a> <Badge type="info" class="jlObjectType jlMacro" text="Macro" /></summary>



```julia
@anti_join(df1, df2, [by])
```


Perform an anti-join on `df1` and `df2` with an optional `by`.

**Arguments**
- `df1`: A DataFrame.
  
- `df2`: A DataFrame.
  
- `by`: An optional column or tuple of columns. `by` supports interpolation of individual columns. If `by` is not supplied, then it will be inferred from shared names of columns between `df1` and `df2`.
  

**Examples**

```julia
julia> df1 = DataFrame(a = ["a", "b"], b = 1:2);

julia> df2 = DataFrame(a = ["a", "c"], c = 3:4);
  
julia> @anti_join(df1, df2)
1×2 DataFrame
 Row │ a       b     
     │ String  Int64 
─────┼───────────────
   1 │ b           2

julia> @anti_join(df1, df2, a)
1×2 DataFrame
 Row │ a       b     
     │ String  Int64 
─────┼───────────────
   1 │ b           2

julia> @anti_join(df1, df2, a = a)
1×2 DataFrame
 Row │ a       b     
     │ String  Int64 
─────┼───────────────
   1 │ b           2

julia> @anti_join(df1, df2, "a")
1×2 DataFrame
 Row │ a       b     
     │ String  Int64 
─────┼───────────────
   1 │ b           2

julia> @anti_join(df1, df2, "a" = "a")
1×2 DataFrame
 Row │ a       b     
     │ String  Int64 
─────┼───────────────
   1 │ b           2
```


```julia
@anti_join(sql_query, join_table, orignal_table_col == new_table_col)
```


Perform an anti join between two SQL queries based on a specified condition.  Joins can be equi joins or inequality joins. For equi joins, the joining table  key column is dropped. Inequality joins can be made into AsOf or rolling joins  by wrapping the inequality in closest(key &gt;= key2). With inequality joins, the  columns from both tables are kept. Multiple joining criteria can be added, but  need to be separated by commas, ie `closest(key >= key2), key3 == key3`

**Arguments**
- `sql_query`: The primary SQL query to operate on.
  
- `join_table::{SQLQuery, String}`: The secondary SQL table to join with the primary query table. Table that exist on the database already should be written as a string of the name
  
- `orignal_table_col`: Column from the original table that matches for join.  Accepts cols as bare column names or strings 
  
- `new_table_col`: Column from the new table that matches for join.  Accepts cols as bare column names or strings
  

**Examples**

```julia
julia> df = DataFrame(id = [string('A' + i ÷ 26, 'A' + i % 26) for i in 0:9], 
                        groups = [i % 2 == 0 ? "aa" : "bb" for i in 1:10], 
                        value = repeat(1:5, 2), 
                        percent = 0.1:0.1:1.0);

julia> df2 = DataFrame(id2 = ["AA", "AC", "AE", "AG", "AI", "AK", "AM"],
                category = ["X", "Y", "X", "Y", "X", "Y", "X"],
                score = [88, 92, 77, 83, 95, 68, 74]);

julia> db = connect(duckdb());


julia> dfj = dt(db, df2, "df_join");

julia> @chain dt(db, df, "df_view") begin
        @anti_join(dfj, id == id2)
        @collect
       end
5×4 DataFrame
 Row │ id      groups  value  percent 
     │ String  String  Int64  Float64 
─────┼────────────────────────────────
   1 │ AB      aa          2      0.2
   2 │ AD      aa          4      0.4
   3 │ AF      aa          1      0.6
   4 │ AH      aa          3      0.8
   5 │ AJ      aa          5      1.0
```



<Badge type="info" class="source-link" text="source"><a href="github.com/TidierOrg/Tidier.jl" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Tidier.@arrange-Tuple{Any, Vararg{Any}}' href='#Tidier.@arrange-Tuple{Any, Vararg{Any}}'><span class="jlbinding">Tidier.@arrange</span></a> <Badge type="info" class="jlObjectType jlMacro" text="Macro" /></summary>



```julia
@arrange(df, exprs...)
```


Order the rows of a DataFrame by the values of specified columns.

**Arguments**
- `df`: A DataFrame.
  
- `exprs...`: Variables from the input DataFrame. Use `desc()` to sort in descending order. Multiple variables can be specified, separated by commas.
  

**Examples**

```julia
julia> df = DataFrame(a = repeat('a':'e', inner = 2), b = 1:10, c = 11:20);
  
julia> @chain df begin
         @arrange(a)
       end
10×3 DataFrame
 Row │ a     b      c     
     │ Char  Int64  Int64 
─────┼────────────────────
   1 │ a         1     11
   2 │ a         2     12
   3 │ b         3     13
   4 │ b         4     14
   5 │ c         5     15
   6 │ c         6     16
   7 │ d         7     17
   8 │ d         8     18
   9 │ e         9     19
  10 │ e        10     20

julia> @chain df begin
         @arrange(a, desc(b))
       end
10×3 DataFrame
 Row │ a     b      c     
     │ Char  Int64  Int64 
─────┼────────────────────
   1 │ a         2     12
   2 │ a         1     11
   3 │ b         4     14
   4 │ b         3     13
   5 │ c         6     16
   6 │ c         5     15
   7 │ d         8     18
   8 │ d         7     17
   9 │ e        10     20
  10 │ e         9     19
```


```julia
@arrange(sql_query, columns...)
```


Order SQL table rows based on specified column(s). Of note, `@arrange` should not be used when performing ordered window functions,  `@window_order`, or preferably the `_order` argument in `@mutate` should be used instead

**Arguments**
- `sql_query::SQLQuery`: The SQL query to arrange
  
- `columns`: Columns to order the rows by. Can include multiple columns for nested sorting. Wrap column name with `desc()` for descending order.
  

**Examples**

```julia
julia> df = DataFrame(id = [string('A' + i ÷ 26, 'A' + i % 26) for i in 0:9], 
                        groups = [i % 2 == 0 ? "aa" : "bb" for i in 1:10], 
                        value = repeat(1:5, 2), 
                        percent = 0.1:0.1:1.0);

julia> db = connect(duckdb());

julia> @chain dt(db, df, "df_view") begin
         @arrange(value, desc(percent))
         @collect
       end
10×4 DataFrame
 Row │ id      groups  value  percent 
     │ String  String  Int64  Float64 
─────┼────────────────────────────────
   1 │ AF      aa          1      0.6
   2 │ AA      bb          1      0.1
   3 │ AG      bb          2      0.7
   4 │ AB      aa          2      0.2
   5 │ AH      aa          3      0.8
   6 │ AC      bb          3      0.3
   7 │ AI      bb          4      0.9
   8 │ AD      aa          4      0.4
   9 │ AJ      aa          5      1.0
  10 │ AE      bb          5      0.5

julia> @chain dt(db, df, "df_view") begin
         @arrange(desc(df_view.value))
         @collect
       end
10×4 DataFrame
 Row │ id      groups  value  percent 
     │ String  String  Int64  Float64 
─────┼────────────────────────────────
   1 │ AE      bb          5      0.5
   2 │ AJ      aa          5      1.0
   3 │ AD      aa          4      0.4
   4 │ AI      bb          4      0.9
   5 │ AC      bb          3      0.3
   6 │ AH      aa          3      0.8
   7 │ AB      aa          2      0.2
   8 │ AG      bb          2      0.7
   9 │ AA      bb          1      0.1
  10 │ AF      aa          1      0.6
```



<Badge type="info" class="source-link" text="source"><a href="github.com/TidierOrg/Tidier.jl" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Tidier.@count-Tuple{Any, Vararg{Any}}' href='#Tidier.@count-Tuple{Any, Vararg{Any}}'><span class="jlbinding">Tidier.@count</span></a> <Badge type="info" class="jlObjectType jlMacro" text="Macro" /></summary>



```julia
@count(df, exprs..., [wt], [sort])
```


Count the unique values of one or more variables, with an optional weighting.

`@chain df @count(a, b)` is roughly equivalent to `@chain df @group_by(a, b) @summarize(n = n())`. Supply `wt` to perform weighted counts, switching the summary from `n = n()` to `n = sum(wt)`. Note that if grouping columns are provided, the result will be an ungrouped data frame, which is slightly different behavior than R&#39;s `tidyverse`.

**Arguments**
- `df`: A DataFrame or GroupedDataFrame.
  
- `exprs...`: Column names, separated by commas.
  
- `wt`: Optional parameter. Used to calculate a sum over the provided `wt` variable instead of counting the rows.
  
- `sort`: Defaults to `false`. Whether the result should be sorted from highest to lowest `n`.
  

**Examples**

```julia
julia> df = DataFrame(a = vcat(repeat(["a"], inner = 3),
                           repeat(["b"], inner = 3),
                           repeat(["c"], inner = 1),
                           missing),
                      b = 1:8)
8×2 DataFrame
 Row │ a        b     
     │ String?  Int64 
─────┼────────────────
   1 │ a            1
   2 │ a            2
   3 │ a            3
   4 │ b            4
   5 │ b            5
   6 │ b            6
   7 │ c            7
   8 │ missing      8

julia> @chain df @count()
1×1 DataFrame
 Row │ n     
     │ Int64 
─────┼───────
   1 │     8

julia> @chain df begin
         @count(a)
       end
4×2 DataFrame
 Row │ a        n     
     │ String?  Int64 
─────┼────────────────
   1 │ a            3
   2 │ b            3
   3 │ c            1
   4 │ missing      1

julia> @chain df begin
         @count(a, wt = b)
       end
4×2 DataFrame
 Row │ a        n     
     │ String?  Int64 
─────┼────────────────
   1 │ a            6
   2 │ b           15
   3 │ c            7
   4 │ missing      8

julia> @chain df begin
         @count(a, wt = b, sort = true)
       end
4×2 DataFrame
 Row │ a        n     
     │ String?  Int64 
─────┼────────────────
   1 │ b           15
   2 │ missing      8
   3 │ c            7
   4 │ a            6

julia> @chain df begin
         @count(a)
         @count(n)
       end 
2×2 DataFrame
 Row │ n      nn    
     │ Int64  Int64 
─────┼──────────────
   1 │     3      2
   2 │     1      2      
```


```julia
@count(sql_query, columns...)
```


Count the number of rows grouped by specified column(s).

**Arguments**
- `sql_query::SQLQuery`: The SQL query to operate on.
  
- `columns`: Columns to group by before counting. If no columns are specified, counts all rows in the query.
  

**Examples**

```julia
julia> df = DataFrame(id = [string('A' + i ÷ 26, 'A' + i % 26) for i in 0:9], 
                        groups = [i % 2 == 0 ? "aa" : "bb" for i in 1:10], 
                        value = repeat(1:5, 2), 
                        percent = 0.1:0.1:1.0);

julia> db = connect(duckdb());

julia> @chain dt(db, df, "df_view") begin
         @count(groups)
         @arrange(groups)
         @collect
       end
2×2 DataFrame
 Row │ groups  n     
     │ String  Int64 
─────┼───────────────
   1 │ aa          5
   2 │ bb          5
```



<Badge type="info" class="source-link" text="source"><a href="github.com/TidierOrg/Tidier.jl" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Tidier.@distinct-Tuple{Any, Vararg{Any}}' href='#Tidier.@distinct-Tuple{Any, Vararg{Any}}'><span class="jlbinding">Tidier.@distinct</span></a> <Badge type="info" class="jlObjectType jlMacro" text="Macro" /></summary>



```julia
distinct(df, exprs...)
```


Return distinct rows of a DataFrame.

If no columns or expressions are provided, then unique rows across all columns are returned. Otherwise, unique rows are determined based on the columns or expressions provided, and then all columns are returned.

**Arguments**
- `df`: A DataFrame.
  
- `exprs...`: One or more unquoted variable names separated by commas. Variable names         can also be used as their positions in the data, like `x:y`, to select         a range of variables.
  

**Examples**

```julia
julia> df = DataFrame(a = repeat('a':'e', inner = 2), b = repeat(1:5, 2), c = 11:20);
  
julia> @chain df @distinct()
10×3 DataFrame
 Row │ a     b      c     
     │ Char  Int64  Int64 
─────┼────────────────────
   1 │ a         1     11
   2 │ a         2     12
   3 │ b         3     13
   4 │ b         4     14
   5 │ c         5     15
   6 │ c         1     16
   7 │ d         2     17
   8 │ d         3     18
   9 │ e         4     19
  10 │ e         5     20

julia> @chain df @distinct(a)
5×3 DataFrame
 Row │ a     b      c     
     │ Char  Int64  Int64 
─────┼────────────────────
   1 │ a         1     11
   2 │ b         3     13
   3 │ c         5     15
   4 │ d         2     17
   5 │ e         4     19

julia> @chain df begin
         @distinct(starts_with("a"))
       end
5×3 DataFrame
 Row │ a     b      c     
     │ Char  Int64  Int64 
─────┼────────────────────
   1 │ a         1     11
   2 │ b         3     13
   3 │ c         5     15
   4 │ d         2     17
   5 │ e         4     19

julia> @chain df begin
         @distinct(a, b)
       end
10×3 DataFrame
 Row │ a     b      c     
     │ Char  Int64  Int64 
─────┼────────────────────
   1 │ a         1     11
   2 │ a         2     12
   3 │ b         3     13
   4 │ b         4     14
   5 │ c         5     15
   6 │ c         1     16
   7 │ d         2     17
   8 │ d         3     18
   9 │ e         4     19
  10 │ e         5     20
```


```julia
@distinct(sql_query, columns...)
```


Select distinct rows based on specified column(s). Distinct works differently in TidierData vs SQL and therefore TidierDB. Distinct will also select only the only columns it is given (or all if given none)

**Arguments**

`sql_query::SQLQuery`: The SQL query to operate on. `columns`: Columns to determine uniqueness. If no columns are specified, all columns are used to identify distinct rows.

**Examples**

```julia
julia> df = DataFrame(id = [string('A' + i ÷ 26, 'A' + i % 26) for i in 0:9], 
                        groups = [i % 2 == 0 ? "aa" : "bb" for i in 1:10], 
                        value = repeat(1:5, 2), 
                        percent = 0.1:0.1:1.0);

julia> db = connect(duckdb());


julia> @chain dt(db, df, "df_view") begin
         @distinct(value)
         @arrange(value)
         @collect
       end
5×1 DataFrame
 Row │ value 
     │ Int64 
─────┼───────
   1 │     1
   2 │     2
   3 │     3
   4 │     4
   5 │     5

julia> @chain dt(db, df, "df_view") begin
         @distinct
         @arrange(id)
         @collect
       end
10×4 DataFrame
 Row │ id      groups  value  percent 
     │ String  String  Int64  Float64 
─────┼────────────────────────────────
   1 │ AA      bb          1      0.1
   2 │ AB      aa          2      0.2
   3 │ AC      bb          3      0.3
   4 │ AD      aa          4      0.4
   5 │ AE      bb          5      0.5
   6 │ AF      aa          1      0.6
   7 │ AG      bb          2      0.7
   8 │ AH      aa          3      0.8
   9 │ AI      bb          4      0.9
  10 │ AJ      aa          5      1.0
```



<Badge type="info" class="source-link" text="source"><a href="github.com/TidierOrg/Tidier.jl" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Tidier.@drop_missing-Tuple{Any, Vararg{Any}}' href='#Tidier.@drop_missing-Tuple{Any, Vararg{Any}}'><span class="jlbinding">Tidier.@drop_missing</span></a> <Badge type="info" class="jlObjectType jlMacro" text="Macro" /></summary>



```julia
@drop_missing(df, [cols...])
```


Drop all rows with missing values.

When called without arguments, `@drop_missing()` drops all rows with missing values in any column. If columns are provided as an optional argument, only missing values from named columns are considered when dropping rows.

**Arguments**
- `df`: A DataFrame or GroupedDataFrame.
  
- `cols...`: An optional column, or multiple columns separated by commas or specified using selection helpers.
  

**Examples**

```julia
julia> df = DataFrame(
              a = [1, 2, missing, 4],
              b = [1, missing, 3, 4]
            )
4×2 DataFrame
 Row │ a        b       
     │ Int64?   Int64?  
─────┼──────────────────
   1 │       1        1
   2 │       2  missing 
   3 │ missing        3
   4 │       4        4

julia> @chain df @drop_missing()
2×2 DataFrame
 Row │ a      b     
     │ Int64  Int64 
─────┼──────────────
   1 │     1      1
   2 │     4      4

julia> @chain df @drop_missing(a)
3×2 DataFrame
 Row │ a      b       
     │ Int64  Int64?  
─────┼────────────────
   1 │     1        1
   2 │     2  missing 
   3 │     4        4

julia> @chain df @drop_missing(a, b)
2×2 DataFrame
 Row │ a      b     
     │ Int64  Int64 
─────┼──────────────
   1 │     1      1
   2 │     4      4

julia> @chain df @drop_missing(starts_with("a"))
3×2 DataFrame
 Row │ a      b       
     │ Int64  Int64?  
─────┼────────────────
   1 │     1        1
   2 │     2  missing 
   3 │     4        4
```


```julia
@drop_missing(sql_query, [cols...])
```


Drop all rows with missing values.

When called without arguments, `@drop_missing()` drops all rows with missing values in any column. If columns are provided as an optional argument, only missing values from named columns are considered when dropping rows.

**Arguments**
- `sql_query`: The SQL query
  
- `cols...`: An optional column, or multiple columns separated by commas or specified using selection helpers.
  

**Examples**

```julia
julia> df = DataFrame(
              a = [1, 2, missing, 4],
              b = [1, missing, 3, 4]
            )
4×2 DataFrame
 Row │ a        b       
     │ Int64?   Int64?  
─────┼──────────────────
   1 │       1        1
   2 │       2  missing 
   3 │ missing        3
   4 │       4        4

julia> db = connect(duckdb()); dbdf = dt(db, df, "df");

julia> @chain dbdf @drop_missing() @collect
2×2 DataFrame
 Row │ a      b     
     │ Int64  Int64 
─────┼──────────────
   1 │     1      1
   2 │     4      4

julia> @chain dbdf @drop_missing(a) @collect
3×2 DataFrame
 Row │ a      b       
     │ Int64  Int64?  
─────┼────────────────
   1 │     1        1
   2 │     2  missing 
   3 │     4        4

julia> @chain dbdf @drop_missing(a, b) @collect
2×2 DataFrame
 Row │ a      b     
     │ Int64  Int64 
─────┼──────────────
   1 │     1      1
   2 │     4      4

julia> @chain dbdf @drop_missing(starts_with("a")) @collect
3×2 DataFrame
 Row │ a      b       
     │ Int64  Int64?  
─────┼────────────────
   1 │     1        1
   2 │     2  missing 
   3 │     4        4
```



<Badge type="info" class="source-link" text="source"><a href="github.com/TidierOrg/Tidier.jl" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Tidier.@filter-Tuple{Any, Vararg{Any}}' href='#Tidier.@filter-Tuple{Any, Vararg{Any}}'><span class="jlbinding">Tidier.@filter</span></a> <Badge type="info" class="jlObjectType jlMacro" text="Macro" /></summary>



```julia
@filter(df, exprs...)
```


Subset a DataFrame and return a copy of DataFrame where specified conditions are satisfied.

**Arguments**
- `df`: A DataFrame.
  
- `exprs...`: transformation(s) that produce vectors containing `true` or `false`.
  

**Examples**

```julia
julia> df = DataFrame(a = 'a':'e', b = 1:5, c = 11:15);

julia> @chain df begin
         @filter(b >= mean(b))
       end
3×3 DataFrame
 Row │ a     b      c     
     │ Char  Int64  Int64 
─────┼────────────────────
   1 │ c         3     13
   2 │ d         4     14
   3 │ e         5     15

julia> @chain df begin
         @filter(b >= 3 && c >= 14)
       end
2×3 DataFrame
 Row │ a     b      c     
     │ Char  Int64  Int64 
─────┼────────────────────
   1 │ d         4     14
   2 │ e         5     15

julia> @chain df begin
         @filter(b in (1, 3))
       end
2×3 DataFrame
 Row │ a     b      c     
     │ Char  Int64  Int64 
─────┼────────────────────
   1 │ a         1     11
   2 │ c         3     13
```


```julia
@filter(sql_query, conditions...)
```


Filter rows in a SQL table based on specified conditions.

**Arguments**
- `sql_query::SQLQuery`: The SQL query to filter rows from.
  
- `conditions`: Expressions specifying the conditions that rows must satisfy to be included in the output.                   Rows for which the expression evaluates to `true` will be included in the result.                   Multiple conditions can be combined using logical operators (`&&`, `||`). `@filter` will automatically                   detect whether the conditions belong in WHERE vs HAVING. 
  

Temporarily, it is best to use begin and end when filtering multiple conditions. (ex 2 below)

**Examples**

```julia
julia> df = DataFrame(id = [string('A' + i ÷ 26, 'A' + i % 26) for i in 0:9], 
                        groups = [i % 2 == 0 ? "aa" : "bb" for i in 1:10], 
                        value = repeat(1:5, 2), 
                        percent = 0.1:0.1:1.0);

julia> db = connect(duckdb());


julia> @chain dt(db, df, "df_view") begin
         @filter(percent > .5)
         @collect
       end
5×4 DataFrame
 Row │ id      groups  value  percent 
     │ String  String  Int64  Float64 
─────┼────────────────────────────────
   1 │ AF      aa          1      0.6
   2 │ AG      bb          2      0.7
   3 │ AH      aa          3      0.8
   4 │ AI      bb          4      0.9
   5 │ AJ      aa          5      1.0

julia> @chain dt(db, df, "df_view") begin
         @group_by(groups)
         @summarise(mean = mean(percent))
         @filter begin 
           groups == "bb" || # logical operators can still be used like this
           mean > .5
         end
         @arrange(groups)
         @collect
       end
2×2 DataFrame
 Row │ groups  mean    
     │ String  Float64 
─────┼─────────────────
   1 │ aa          0.6
   2 │ bb          0.5

julia> q = @chain dt(db, df, "df_view") @summarize(mean = mean(value));

julia> @eval @chain dt(db, df, "df_view") begin
         @filter(value < $q) 
         @collect
       end
4×4 DataFrame
 Row │ id      groups  value  percent 
     │ String  String  Int64  Float64 
─────┼────────────────────────────────
   1 │ AA      bb          1      0.1
   2 │ AB      aa          2      0.2
   3 │ AF      aa          1      0.6
   4 │ AG      bb          2      0.7
```



<Badge type="info" class="source-link" text="source"><a href="github.com/TidierOrg/Tidier.jl" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Tidier.@full_join-Tuple{Any, Any, Vararg{Any}}' href='#Tidier.@full_join-Tuple{Any, Any, Vararg{Any}}'><span class="jlbinding">Tidier.@full_join</span></a> <Badge type="info" class="jlObjectType jlMacro" text="Macro" /></summary>



```julia
@full_join(df1, df2, [by])
```


Perform a full join on `df1` and `df2` with an optional `by`.

**Arguments**
- `df1`: A DataFrame.
  
- `df2`: A DataFrame.
  
- `by`: An optional column or tuple of columns. `by` supports interpolation of individual columns. If `by` is not supplied, then it will be inferred from shared names of columns between `df1` and `df2`.
  

**Examples**

```julia
julia> df1 = DataFrame(a = ["a", "b"], b = 1:2);

julia> df2 = DataFrame(a = ["a", "c"], c = 3:4);
  
julia> @full_join(df1, df2)
3×3 DataFrame
 Row │ a       b        c       
     │ String  Int64?   Int64?  
─────┼──────────────────────────
   1 │ a             1        3
   2 │ b             2  missing 
   3 │ c       missing        4

julia> @full_join(df1, df2, a)
3×3 DataFrame
 Row │ a       b        c       
     │ String  Int64?   Int64?  
─────┼──────────────────────────
   1 │ a             1        3
   2 │ b             2  missing 
   3 │ c       missing        4

julia> @full_join(df1, df2, a = a)
3×3 DataFrame
 Row │ a       b        c       
     │ String  Int64?   Int64?  
─────┼──────────────────────────
   1 │ a             1        3
   2 │ b             2  missing 
   3 │ c       missing        4

julia> @full_join(df1, df2, "a")
3×3 DataFrame
 Row │ a       b        c       
     │ String  Int64?   Int64?  
─────┼──────────────────────────
   1 │ a             1        3
   2 │ b             2  missing 
   3 │ c       missing        4

julia> @full_join(df1, df2, "a" = "a")
3×3 DataFrame
 Row │ a       b        c       
     │ String  Int64?   Int64?  
─────┼──────────────────────────
   1 │ a             1        3
   2 │ b             2  missing 
   3 │ c       missing        4
```


```julia
@inner_join(sql_query, join_table, orignal_table_col == new_table_col)
```


Perform an full join between two SQL queries based on a specified condition.  Joins can be equi joins or inequality joins. For equi joins, the joining table  key column is dropped. Inequality joins can be made into AsOf or rolling joins  by wrapping the inequality in closest(key &gt;= key2). With inequality joins, the  columns from both tables are kept. Multiple joining criteria can be added, but  need to be separated by commas, ie `closest(key >= key2), key3 == key3`

**Arguments**
- `sql_query`: The primary SQL query to operate on.
  
- `join_table::{SQLQuery, String}`: The secondary SQL table to join with the primary query table. Table that exist on the database already should be written as a string of the name
  
- `orignal_table_col`: Column from the original table that matches for join.  Accepts cols as bare column names or strings 
  
- `new_table_col`: Column from the new table that matches for join.  Accepts cols as bare column names or strings
  

**Examples**

```julia
julia> df = DataFrame(id = [string('A' + i ÷ 26, 'A' + i % 26) for i in 0:9], 
                        groups = [i % 2 == 0 ? "aa" : "bb" for i in 1:10], 
                        value = repeat(1:5, 2), 
                        percent = 0.1:0.1:1.0);

julia> df2 = DataFrame(id = ["AA", "AC", "AE", "AG", "AI", "AK", "AM"],
                category = ["X", "Y", "X", "Y", "X", "Y", "X"],
                score = [88, 92, 77, 83, 95, 68, 74]);

julia> db = connect(duckdb());


julia> dfj = dt(db, df2, "df_join");

julia> @chain dt(db, df, "df_view") begin
         @full_join((@chain dt(db, "df_join") @filter(score > 70)), id == id)
         @collect
       end
11×6 DataFrame
 Row │ id      groups   value    percent    category  score   
     │ String  String?  Int64?   Float64?   String?   Int64?  
─────┼────────────────────────────────────────────────────────
   1 │ AA      bb             1        0.1  X              88
   2 │ AC      bb             3        0.3  Y              92
   3 │ AE      bb             5        0.5  X              77
   4 │ AG      bb             2        0.7  Y              83
   5 │ AI      bb             4        0.9  X              95
   6 │ AB      aa             2        0.2  missing   missing 
   7 │ AD      aa             4        0.4  missing   missing 
   8 │ AF      aa             1        0.6  missing   missing 
   9 │ AH      aa             3        0.8  missing   missing 
  10 │ AJ      aa             5        1.0  missing   missing 
  11 │ AM      missing  missing  missing    X              74
```



<Badge type="info" class="source-link" text="source"><a href="github.com/TidierOrg/Tidier.jl" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Tidier.@group_by-Tuple{Any, Vararg{Any}}' href='#Tidier.@group_by-Tuple{Any, Vararg{Any}}'><span class="jlbinding">Tidier.@group_by</span></a> <Badge type="info" class="jlObjectType jlMacro" text="Macro" /></summary>



```julia
@group_by(df, exprs...)
```


Return a `GroupedDataFrame` where operations are performed by groups specified by unique  sets of `cols`.

**Arguments**
- `df`: A DataFrame.
  
- `exprs...`: DataFrame columns to group by or tidy expressions. Can be a single tidy expression or multiple expressions separated by commas.
  

**Examples**

```julia
julia> df = DataFrame(a = 'a':'e', b = 1:5, c = 11:15);

julia> @chain df begin
         @group_by(a)
         @summarize(b = mean(b))
       end
5×2 DataFrame
 Row │ a     b       
     │ Char  Float64 
─────┼───────────────
   1 │ a         1.0
   2 │ b         2.0
   3 │ c         3.0
   4 │ d         4.0
   5 │ e         5.0  

julia> @chain df begin
         @group_by(d = uppercase(a))
         @summarize(b = mean(b))
       end
5×2 DataFrame
 Row │ d     b       
     │ Char  Float64 
─────┼───────────────
   1 │ A         1.0
   2 │ B         2.0
   3 │ C         3.0
   4 │ D         4.0
   5 │ E         5.0

julia> @chain df begin
         @group_by(-(b, c)) # same as `a`
         @summarize(b = mean(b))
       end
5×2 DataFrame
 Row │ a     b       
     │ Char  Float64 
─────┼───────────────
   1 │ a         1.0
   2 │ b         2.0
   3 │ c         3.0
   4 │ d         4.0
   5 │ e         5.0

julia> @chain df begin
         @group_by(!(b, c)) # same as `a`
         @summarize(b = mean(b))
       end
5×2 DataFrame
 Row │ a     b       
     │ Char  Float64 
─────┼───────────────
   1 │ a         1.0
   2 │ b         2.0
   3 │ c         3.0
   4 │ d         4.0
   5 │ e         5.0
```


```julia
@group_by(sql_query, columns...)
```


Group SQL table rows by specified column(s). If grouping is performed as a terminal operation without a  subsequent mutatation or summarization (as in the example below), then the resulting data frame will only  contains those groups. Collecting following a grouping will not return a grouped dataframe as TidierData does. 

**Arguments**
- `sql_query`: The SQL query to operate on.
  
- `exprs`: Expressions specifying the columns to group by. Columns can be specified by name.
  

**Examples**

```julia
julia> df = DataFrame(id = [string('A' + i ÷ 26, 'A' + i % 26) for i in 0:9], 
                        groups = [i % 2 == 0 ? "aa" : "bb" for i in 1:10], 
                        value = repeat(1:5, 2), 
                        percent = 0.1:0.1:1.0);

julia> db = connect(duckdb());

julia> @chain dt(db, df, "df_view") begin
         @group_by(groups)
         @arrange(groups)
         @collect
       end
2×1 DataFrame
 Row │ groups 
     │ String 
─────┼────────
   1 │ aa
   2 │ bb

julia> @chain dt(db, df, "df_view") begin
         @group_by(big_val = if_else(value > 3, "big", "small"))
         @summarise(n=n())
         @arrange(big_val)
         @collect
       end
2×2 DataFrame
 Row │ big_val  n     
     │ String   Int64 
─────┼────────────────
   1 │ big          4
   2 │ small        6
```



<Badge type="info" class="source-link" text="source"><a href="github.com/TidierOrg/Tidier.jl" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Tidier.@head-Tuple{Any, Vararg{Any}}' href='#Tidier.@head-Tuple{Any, Vararg{Any}}'><span class="jlbinding">Tidier.@head</span></a> <Badge type="info" class="jlObjectType jlMacro" text="Macro" /></summary>



```julia
   @head(df, value)
```


Shows the first n rows of the the data frame or of each group in a grouped data frame. 

**Arguments**
- `df`: The data frame.
  
- `value`: number of rows to be returned. Defaults to 6 if left blank.
  

**Examples**

```julia
julia> df = DataFrame(a = vcat(repeat(["a"], inner = 4),
                                  repeat(["b"], inner = 4)),
                             b = 1:8)
8×2 DataFrame
 Row │ a       b     
     │ String  Int64 
─────┼───────────────
   1 │ a           1
   2 │ a           2
   3 │ a           3
   4 │ a           4
   5 │ b           5
   6 │ b           6
   7 │ b           7
   8 │ b           8
   
julia> @head(df, 3)
3×2 DataFrame
 Row │ a        b     
     │ String?  Int64 
─────┼────────────────
   1 │ a            1
   2 │ a            2
   3 │ a            3

julia> @head(df)
6×2 DataFrame
 Row │ a       b     
     │ String  Int64 
─────┼───────────────
   1 │ a           1
   2 │ a           2
   3 │ a           3
   4 │ a           4
   5 │ b           5
   6 │ b           6

julia> @chain df begin
         @group_by a
         @head 2
       end
GroupedDataFrame with 2 groups based on key: a
First Group (2 rows): a = "a"
 Row │ a       b     
     │ String  Int64 
─────┼───────────────
   1 │ a           1
   2 │ a           2
⋮
Last Group (2 rows): a = "b"
 Row │ a       b     
     │ String  Int64 
─────┼───────────────
   1 │ b           5
   2 │ b           6
```


```julia
@head(sql_query, value)
```


Limit SQL table number of rows returned based on specified value.  `LIMIT` in SQL

**Arguments**
- `sql_query`: The SQL query to operate on.
  
- `value`: Number to limit how many rows are returned. If left empty, it will default to 6 rows
  

**Examples**

```julia
julia> db = connect(duckdb());

julia> df = DataFrame(id = [string('A' + i ÷ 26, 'A' + i % 26) for i in 0:9], 
                        groups = [i % 2 == 0 ? "aa" : "bb" for i in 1:10], 
                        value = repeat(1:5, 2), 
                        percent = 0.1:0.1:1.0);
                     

julia> @chain dt(db, df, "df_view") begin
        @head(1) ## supports expressions ie `3-2` would return the same df below
        @collect
       end
1×4 DataFrame
 Row │ id      groups  value  percent 
     │ String  String  Int64  Float64 
─────┼────────────────────────────────
   1 │ AA      bb          1      0.1
```



<Badge type="info" class="source-link" text="source"><a href="github.com/TidierOrg/Tidier.jl" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Tidier.@inner_join-Tuple{Any, Any, Vararg{Any}}' href='#Tidier.@inner_join-Tuple{Any, Any, Vararg{Any}}'><span class="jlbinding">Tidier.@inner_join</span></a> <Badge type="info" class="jlObjectType jlMacro" text="Macro" /></summary>



```julia
@inner_join(df1, df2, [by])
```


Perform a inner join on `df1` and `df2` with an optional `by`.

**Arguments**
- `df1`: A DataFrame.
  
- `df2`: A DataFrame.
  
- `by`: An optional column or tuple of columns. `by` supports interpolation of individual columns. If `by` is not supplied, then it will be inferred from shared names of columns between `df1` and `df2`.
  

**Examples**

```julia
julia> df1 = DataFrame(a = ["a", "b"], b = 1:2);

julia> df2 = DataFrame(a = ["a", "c"], c = 3:4);
  
julia> @inner_join(df1, df2)
1×3 DataFrame
 Row │ a       b      c     
     │ String  Int64  Int64 
─────┼──────────────────────
   1 │ a           1      3

julia> @inner_join(df1, df2, a)
1×3 DataFrame
 Row │ a       b      c     
     │ String  Int64  Int64 
─────┼──────────────────────
   1 │ a           1      3

julia> @inner_join(df1, df2, a = a)
1×3 DataFrame
 Row │ a       b      c     
     │ String  Int64  Int64 
─────┼──────────────────────
   1 │ a           1      3

julia> @inner_join(df1, df2, "a")
1×3 DataFrame
 Row │ a       b      c     
     │ String  Int64  Int64 
─────┼──────────────────────
   1 │ a           1      3

julia> @inner_join(df1, df2, "a" = "a")
1×3 DataFrame
 Row │ a       b      c     
     │ String  Int64  Int64 
─────┼──────────────────────
   1 │ a           1      3
```


```julia
@inner_join(sql_query, join_table, orignal_table_col == new_table_col)
```


Perform an inner join between two SQL queries based on a specified condition.  Joins can be equi joins or inequality joins. For equi joins, the joining table  key column is dropped. Inequality joins can be made into AsOf or rolling joins  by wrapping the inequality in closest(key &gt;= key2). With inequality joins, the  columns from both tables are kept. Multiple joining criteria can be added, but  need to be separated by commas, ie `closest(key >= key2), key3 == key3`

**Arguments**
- `sql_query`: The primary SQL query to operate on.
  
- `join_table::{SQLQuery, String}`: The secondary SQL table to join with the primary query table. Table that exist on the database already should be written as a string of the name
  
- `orignal_table_col`: Column from the original table that matches for join.  Accepts cols as bare column names or strings 
  
- `new_table_col`: Column from the new table that matches for join.  Accepts columns as bare column names or strings
  

**Examples**

```julia
julia> df = DataFrame(id = [string('A' + i ÷ 26, 'A' + i % 26) for i in 0:9], 
                        groups = [i % 2 == 0 ? "aa" : "bb" for i in 1:10], 
                        value = repeat(1:5, 2), 
                        percent = 0.1:0.1:1.0);

julia> df2 = DataFrame(id2 = ["AA", "AC", "AE", "AG", "AI", "AK", "AM"],
                category = ["X", "Y", "X", "Y", "X", "Y", "X"],
                score = [88, 92, 77, 83, 95, 68, 74]);

julia> db = connect(duckdb());


julia> dfj = dt(db, df2, "df_join");

julia> @chain dt(db, df, "df_view") begin
         @inner_join(dfj, id == id2)
         @collect
       end
5×6 DataFrame
 Row │ id      groups  value  percent  category  score 
     │ String  String  Int64  Float64  String    Int64 
─────┼─────────────────────────────────────────────────
   1 │ AA      bb          1      0.1  X            88
   2 │ AC      bb          3      0.3  Y            92
   3 │ AE      bb          5      0.5  X            77
   4 │ AG      bb          2      0.7  Y            83
   5 │ AI      bb          4      0.9  X            95
```



<Badge type="info" class="source-link" text="source"><a href="github.com/TidierOrg/Tidier.jl" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Tidier.@left_join-Tuple{Any, Any, Vararg{Any}}' href='#Tidier.@left_join-Tuple{Any, Any, Vararg{Any}}'><span class="jlbinding">Tidier.@left_join</span></a> <Badge type="info" class="jlObjectType jlMacro" text="Macro" /></summary>



```julia
@left_join(df1, df2, [by])
```


Perform a left join on `df1` and `df2` with an optional `by`.

**Arguments**
- `df1`: A DataFrame.
  
- `df2`: A DataFrame.
  
- `by`: An optional column or tuple of columns. `by` supports interpolation of individual columns. If `by` is not supplied, then it will be inferred from shared names of columns between `df1` and `df2`.
  

**Examples**

```julia
julia> df1 = DataFrame(a = ["a", "b"], b = 1:2);

julia> df2 = DataFrame(a = ["a", "c"], c = 3:4);
  
julia> @left_join(df1, df2)
2×3 DataFrame
 Row │ a       b      c       
     │ String  Int64  Int64?  
─────┼────────────────────────
   1 │ a           1        3
   2 │ b           2  missing 

julia> @left_join(df1, df2, a)
2×3 DataFrame
 Row │ a       b      c       
     │ String  Int64  Int64?  
─────┼────────────────────────
   1 │ a           1        3
   2 │ b           2  missing

julia> @left_join(df1, df2, a = a)
2×3 DataFrame
 Row │ a       b      c       
     │ String  Int64  Int64?  
─────┼────────────────────────
   1 │ a           1        3
   2 │ b           2  missing

julia> @left_join(df1, df2, "a")
2×3 DataFrame
 Row │ a       b      c       
     │ String  Int64  Int64?  
─────┼────────────────────────
   1 │ a           1        3
   2 │ b           2  missing

julia> @left_join(df1, df2, "a" = "a")
2×3 DataFrame
 Row │ a       b      c       
     │ String  Int64  Int64?  
─────┼────────────────────────
   1 │ a           1        3
   2 │ b           2  missing
```


```julia
@left_join(sql_query, join_table, orignal_table_col == new_table_col)
```


Perform a left join between two SQL queries based on a specified condition.  Joins can be equi joins or inequality joins. For equi joins, the joining table  key column is dropped. Inequality joins can be made into AsOf or rolling joins  by wrapping the inequality in closest(key &gt;= key2). With inequality joins, the  columns from both tables are kept. Multiple joining criteria can be added, but  need to be separated by commas, ie `closest(key >= key2), key3 == key3`

**Arguments**
- `sql_query::SQLQuery`: The primary SQL query to operate on.
  
- `join_table::{SQLQuery, String}`: The secondary SQL table to join with the primary query table. Table that exist on the database already should be written as a string of the name
  
- `orignal_table_col`: Column from the original table that matches for join.  Accepts cols as bare column names or strings 
  
- `new_table_col`: Column from the new table that matches for join.  Accepts cols as bare column names or strings
  

**Examples**

```julia
julia> df = DataFrame(id = [string('A' + i ÷ 26, 'A' + i % 26) for i in 0:9], 
                        groups = [i % 2 == 0 ? "aa" : "bb" for i in 1:10], 
                        value = repeat(1:5, 2), 
                        percent = 0.1:0.1:1.0);

julia> df2 = DataFrame(id2 = ["AA", "AC", "AE", "AG", "AI", "AK", "AM"],
                category = ["X", "Y", "X", "Y", "X", "Y", "X"],
                score = [88, 92, 77, 83, 95, 68, 74]);

julia> db = connect(duckdb());

julia> dfm = dt(db, df, "df_mem"); dfj = dt(db, df2, "df_join");

julia> @chain dfm begin
         @left_join(t(dfj), id == id2 )
         @collect
       end
10×6 DataFrame
 Row │ id      groups  value  percent  category  score   
     │ String  String  Int64  Float64  String?   Int64?  
─────┼───────────────────────────────────────────────────
   1 │ AA      bb          1      0.1  X              88
   2 │ AC      bb          3      0.3  Y              92
   3 │ AE      bb          5      0.5  X              77
   4 │ AG      bb          2      0.7  Y              83
   5 │ AI      bb          4      0.9  X              95
   6 │ AB      aa          2      0.2  missing   missing 
   7 │ AD      aa          4      0.4  missing   missing 
   8 │ AF      aa          1      0.6  missing   missing 
   9 │ AH      aa          3      0.8  missing   missing 
  10 │ AJ      aa          5      1.0  missing   missing 

julia> query = @chain dt(db, "df_join") begin
                  @filter(score > 85) # only show scores above 85 in joining table
                end;

julia> @chain dfm begin
         @left_join(query, id == id2)
         @collect
       end
10×6 DataFrame
 Row │ id      groups  value  percent  category  score   
     │ String  String  Int64  Float64  String?   Int64?  
─────┼───────────────────────────────────────────────────
   1 │ AA      bb          1      0.1  X              88
   2 │ AC      bb          3      0.3  Y              92
   3 │ AI      bb          4      0.9  X              95
   4 │ AB      aa          2      0.2  missing   missing 
   5 │ AD      aa          4      0.4  missing   missing 
   6 │ AE      bb          5      0.5  missing   missing 
   7 │ AF      aa          1      0.6  missing   missing 
   8 │ AG      bb          2      0.7  missing   missing 
   9 │ AH      aa          3      0.8  missing   missing 
  10 │ AJ      aa          5      1.0  missing   missing 

julia>  @chain dfm begin
         @mutate(test = percent * 100)
         @left_join(dfj, test <= score, id = id2)
         @collect
       end;


julia>  @chain dfm begin
         @mutate(test = percent * 200)
         @left_join(dfj, closest(test >= score)) # asof join
         @collect
       end;
```



<Badge type="info" class="source-link" text="source"><a href="github.com/TidierOrg/Tidier.jl" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Tidier.@mutate-Tuple{Any, Vararg{Any}}' href='#Tidier.@mutate-Tuple{Any, Vararg{Any}}'><span class="jlbinding">Tidier.@mutate</span></a> <Badge type="info" class="jlObjectType jlMacro" text="Macro" /></summary>



```julia
@mutate(df, exprs...)
```


Create new columns as functions of existing columns. The results have the same number of rows as `df`.

**Arguments**
- `df`: A DataFrame.
  
- `exprs...`: add new columns or replace values of existed columns using        `new_variable = values` syntax.
  

**Examples**

```julia
julia> df = DataFrame(a = 'a':'e', b = 1:5, c = 11:15);

julia> @chain df begin
         @mutate(d = b + c,
                 b_minus_mean_b = b - mean(b))
       end
5×5 DataFrame
 Row │ a     b      c      d      b_minus_mean_b 
     │ Char  Int64  Int64  Int64  Float64        
─────┼───────────────────────────────────────────
   1 │ a         1     11     12            -2.0
   2 │ b         2     12     14            -1.0
   3 │ c         3     13     16             0.0
   4 │ d         4     14     18             1.0
   5 │ e         5     15     20             2.0

julia> @chain df begin
         @mutate begin
           d = b + c
           b_minus_mean_b = b - mean(b)
         end
       end
5×5 DataFrame
 Row │ a     b      c      d      b_minus_mean_b 
     │ Char  Int64  Int64  Int64  Float64        
─────┼───────────────────────────────────────────
   1 │ a         1     11     12            -2.0
   2 │ b         2     12     14            -1.0
   3 │ c         3     13     16             0.0
   4 │ d         4     14     18             1.0
   5 │ e         5     15     20             2.0

julia> @chain df begin
         @mutate(d = b in (1,3))
       end
5×4 DataFrame
 Row │ a     b      c      d     
     │ Char  Int64  Int64  Bool  
─────┼───────────────────────────
   1 │ a         1     11   true
   2 │ b         2     12  false
   3 │ c         3     13   true
   4 │ d         4     14  false
   5 │ e         5     15  false

julia> @chain df begin
         @mutate(across((b, c), mean))
       end
5×5 DataFrame
 Row │ a     b      c      b_mean   c_mean  
     │ Char  Int64  Int64  Float64  Float64 
─────┼──────────────────────────────────────
   1 │ a         1     11      3.0     13.0
   2 │ b         2     12      3.0     13.0
   3 │ c         3     13      3.0     13.0
   4 │ d         4     14      3.0     13.0
   5 │ e         5     15      3.0     13.0

julia> @chain df begin
         @summarize(across(contains("b"), mean))
       end
1×1 DataFrame
 Row │ b_mean  
     │ Float64 
─────┼─────────
   1 │     3.0

julia> @chain df begin
         @summarize(across(-contains("a"), mean))
       end
1×2 DataFrame
 Row │ b_mean   c_mean  
     │ Float64  Float64 
─────┼──────────────────
   1 │     3.0     13.0

julia> @chain df begin
         @mutate(across(where(is_number), minimum))
       end
5×5 DataFrame
 Row │ a     b      c      b_minimum  c_minimum 
     │ Char  Int64  Int64  Int64      Int64     
─────┼──────────────────────────────────────────
   1 │ a         1     11          1         11
   2 │ b         2     12          1         11
   3 │ c         3     13          1         11
   4 │ d         4     14          1         11
   5 │ e         5     15          1         11
```


```julia
@mutate(sql_query, exprs...; _by, _frame, _order)
```


Mutate SQL table by adding new columns or modifying existing ones.

**Arguments**
- `sql_query::SQLQuery`: The SQL query to operate on.
  
- `exprs`: Expressions for mutating the table. New columns can be added or existing columns modified using `column_name = expression syntax`, where expression can involve existing columns.
  
- `_by`: optional argument that supports single column names, or vectors of columns to allow for grouping for the transformation in the macro call
  
- `_frame`: optional argument that allows window frames to be determined within `@mutate`. supports single digits or tuples of numbers. supports `desc()` prefix
  
- `_order`: optional argument that allows window orders to be determined within `@mutate`. supports single columns or vectors of names  
  

**Examples**

```julia
julia> df = DataFrame(id = [string('A' + i ÷ 26, 'A' + i % 26) for i in 0:9], 
                        groups = [i % 2 == 0 ? "aa" : "bb" for i in 1:10], 
                        value = repeat(1:5, 2), 
                        percent = 0.1:0.1:1.0);

julia> db = connect(duckdb());


julia> @chain dt(db, df, "df_view") begin
         @mutate(value = value * 4, new_col = percent^2)
         @collect
       end
10×5 DataFrame
 Row │ id      groups  value  percent  new_col 
     │ String  String  Int64  Float64  Float64 
─────┼─────────────────────────────────────────
   1 │ AA      bb          4      0.1     0.01
   2 │ AB      aa          8      0.2     0.04
   3 │ AC      bb         12      0.3     0.09
   4 │ AD      aa         16      0.4     0.16
   5 │ AE      bb         20      0.5     0.25
   6 │ AF      aa          4      0.6     0.36
   7 │ AG      bb          8      0.7     0.49
   8 │ AH      aa         12      0.8     0.64
   9 │ AI      bb         16      0.9     0.81
  10 │ AJ      aa         20      1.0     1.0

julia> @chain dt(db, df, "df_view") begin
         @mutate(max = maximum(percent), sum = sum(percent), _by = groups)
         @arrange(groups, percent)
         @collect
       end
10×6 DataFrame
 Row │ id      groups  value  percent  max      sum     
     │ String  String  Int64  Float64  Float64  Float64 
─────┼──────────────────────────────────────────────────
   1 │ AB      aa          2      0.2      1.0      3.0
   2 │ AD      aa          4      0.4      1.0      3.0
   3 │ AF      aa          1      0.6      1.0      3.0
   4 │ AH      aa          3      0.8      1.0      3.0
   5 │ AJ      aa          5      1.0      1.0      3.0
   6 │ AA      bb          1      0.1      0.9      2.5
   7 │ AC      bb          3      0.3      0.9      2.5
   8 │ AE      bb          5      0.5      0.9      2.5
   9 │ AG      bb          2      0.7      0.9      2.5
  10 │ AI      bb          4      0.9      0.9      2.5

julia> @chain dt(db, df, "df_view") begin
          @mutate(value1 = sum(value), 
                      _order = percent, 
                      _frame = (-1, 1), 
                      _by = groups) 
          @mutate(value2 = sum(value), 
                      _order = desc(percent),
                      _frame = 2)  
          @arrange(groups)
          @collect
       end
10×6 DataFrame
 Row │ id      groups  value  percent  value1  value2  
     │ String  String  Int64  Float64  Int128  Int128? 
─────┼─────────────────────────────────────────────────
   1 │ AJ      aa          5      1.0       8       21
   2 │ AH      aa          3      0.8       9       16
   3 │ AF      aa          1      0.6       8       10
   4 │ AD      aa          4      0.4       7        3
   5 │ AB      aa          2      0.2       6  missing 
   6 │ AI      bb          4      0.9       6       18
   7 │ AG      bb          2      0.7      11       15
   8 │ AE      bb          5      0.5      10        6
   9 │ AC      bb          3      0.3       9        1
  10 │ AA      bb          1      0.1       4  missing 

julia> @chain dt(db, df, "df_view") begin
         @mutate(across([:value, :percent], agg(kurtosis)))
         @collect
       end
10×6 DataFrame
 Row │ id      groups  value  percent  value_kurtosis  percent_kurtosis 
     │ String  String  Int64  Float64  Float64         Float64          
─────┼──────────────────────────────────────────────────────────────────
   1 │ AA      bb          1      0.1        -1.33393              -1.2
   2 │ AB      aa          2      0.2        -1.33393              -1.2
   3 │ AC      bb          3      0.3        -1.33393              -1.2
   4 │ AD      aa          4      0.4        -1.33393              -1.2
   5 │ AE      bb          5      0.5        -1.33393              -1.2
   6 │ AF      aa          1      0.6        -1.33393              -1.2
   7 │ AG      bb          2      0.7        -1.33393              -1.2
   8 │ AH      aa          3      0.8        -1.33393              -1.2
   9 │ AI      bb          4      0.9        -1.33393              -1.2
  10 │ AJ      aa          5      1.0        -1.33393              -1.2

julia> @chain dt(db, df, "df_view") begin
          @mutate(value2 = sum(value), 
                      _order = desc([:value, :percent]),
                      _frame = 2);  
          @collect
       end;
```



<Badge type="info" class="source-link" text="source"><a href="github.com/TidierOrg/Tidier.jl" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Tidier.@pivot_longer-Tuple{Any, Vararg{Any}}' href='#Tidier.@pivot_longer-Tuple{Any, Vararg{Any}}'><span class="jlbinding">Tidier.@pivot_longer</span></a> <Badge type="info" class="jlObjectType jlMacro" text="Macro" /></summary>



@pivot_longer(df, cols, [names_to], [values_to])

Reshapes the DataFrame to make it longer, increasing the number of rows and reducing the number of columns.

**Arguments**
- `df`: A DataFrame.
  
- `cols`: Columns to pivot into longer format. Multiple columns can be selected but providing tuples of columns is not yet supported.
  
- `names_to`: Optional, defaults to `variable`. The name of the newly created column whose values will contain the input DataFrame&#39;s column names.
  
- `values_to`: Optional, defaults to `value`. The name of the newly created column containing the input DataFrame&#39;s cell values.
  

**Examples**

```julia
julia> df_wide = DataFrame(id = [1, 2], A = [1, 3], B = [2, 4]);

julia> @pivot_longer(df_wide, A:B)
4×3 DataFrame
 Row │ id     variable  value 
     │ Int64  String    Int64
─────┼────────────────────────
   1 │     1  A             1
   2 │     2  A             3
   3 │     1  B             2
   4 │     2  B             4

julia> @pivot_longer(df_wide, -id)
4×3 DataFrame
 Row │ id     variable  value 
     │ Int64  String    Int64
─────┼────────────────────────
   1 │     1  A             1
   2 │     2  A             3
   3 │     1  B             2
   4 │     2  B             4

julia> @pivot_longer(df_wide, A:B, names_to = "letter", values_to = "number")
4×3 DataFrame
 Row │ id     letter  number 
     │ Int64  String  Int64
─────┼───────────────────────
   1 │     1  A            1
   2 │     2  A            3
   3 │     1  B            2
   4 │     2  B            4

julia> @pivot_longer(df_wide, A:B, names_to = letter, values_to = number)
4×3 DataFrame
 Row │ id     letter  number 
     │ Int64  String  Int64
─────┼───────────────────────
   1 │     1  A            1
   2 │     2  A            3
   3 │     1  B            2
   4 │     2  B            4

julia> @pivot_longer(df_wide, A:B, names_to = "letter")
4×3 DataFrame
 Row │ id     letter  value 
     │ Int64  String  Int64
─────┼──────────────────────
   1 │     1  A           1
   2 │     2  A           3
   3 │     1  B           2
   4 │     2  B           4

```


@pivot_longer(df, names_from, values_from)

Reshapes the SQL_query to make it longer, increasing the number of rows and reducing the number of columns.

**Arguments**
- `sql_query`: The SQL query
  
- `cols`: Columns to pivot into longer format. Multiple columns can be selected
  
- `names_from`: Optional, defaults to variable. The name of the newly created column whose values will contain the input DataFrame&#39;s column names.
  
- `values_from`:  Optional, defaults to value. The name of the newly created column containing the input DataFrame&#39;s cell values.
  

**Examples**

```julia
julia> df = DataFrame(id = [1, 2], A = [1, 3], B = [2, 4]);

julia> db = connect(duckdb()); df_wide = dt(db, df, "df");

julia> @collect @pivot_longer(df_wide, A:B)
4×3 DataFrame
 Row │ id     variable  value 
     │ Int64  String    Int64 
─────┼────────────────────────
   1 │     1  A             1
   2 │     2  A             3
   3 │     1  B             2
   4 │     2  B             4

julia> @collect @pivot_longer(df_wide, A:B, names_to = "letter", values_to = "number")
4×3 DataFrame
 Row │ id     letter  number 
     │ Int64  String  Int64  
─────┼───────────────────────
   1 │     1  A            1
   2 │     2  A            3
   3 │     1  B            2
   4 │     2  B            4
```



<Badge type="info" class="source-link" text="source"><a href="github.com/TidierOrg/Tidier.jl" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Tidier.@pivot_wider-Tuple{Any, Vararg{Any}}' href='#Tidier.@pivot_wider-Tuple{Any, Vararg{Any}}'><span class="jlbinding">Tidier.@pivot_wider</span></a> <Badge type="info" class="jlObjectType jlMacro" text="Macro" /></summary>



@pivot_wider(df, names_from, values_from[, values_fill])

Reshapes the DataFrame to make it wider, increasing the number of columns and reducing the number of rows.

**Arguments**
- `df`: A DataFrame.
  
- `names_from`: The name of the column to get the name of the output columns from.
  
- `values_from`: The name of the column to get the cell values from.
  
- `values_fill`: The value to replace a missing name/value combination (default is `missing`)
  

**Examples**

```julia
julia> df_long = DataFrame(id = [1, 1, 2, 2],
                           variable = ["A", "B", "A", "B"],
                           value = [1, 2, 3, 4]);

julia> df_long_missing = DataFrame(id = [1, 1, 2],
                           variable = ["A", "B", "B"],
                           value = [1, 2, 4]);

julia> @pivot_wider(df_long, names_from = variable, values_from = value)
2×3 DataFrame
 Row │ id     A       B      
     │ Int64  Int64?  Int64?
─────┼───────────────────────
   1 │     1       1       2
   2 │     2       3       4

julia> @pivot_wider(df_long, names_from = "variable", values_from = "value")
2×3 DataFrame
 Row │ id     A       B      
     │ Int64  Int64?  Int64?
─────┼───────────────────────
   1 │     1       1       2
   2 │     2       3       4

julia> @pivot_wider(df_long_missing, names_from = variable, values_from = value, values_fill = 0)
2×3 DataFrame
 Row │ id     A      B     
     │ Int64  Int64  Int64
─────┼─────────────────────
   1 │     1      1      2
   2 │     2      0      4

julia> df_mult = DataFrame(
                  paddockId = [0, 0, 1, 1, 2, 2],
                  color = repeat([:red, :blue], 3),
                  count = repeat([3, 4], 3),
                  weight = [0.2, 0.3, 0.2, 0.3, 0.2, 0.2],
              );

julia> @pivot_wider(df_mult, names_from = color, values_from = count:weight)
3×5 DataFrame
 Row │ paddockId  red_count  blue_count  red_weight  blue_weight 
     │ Int64      Int64?     Int64?      Float64?    Float64?    
─────┼───────────────────────────────────────────────────────────
   1 │         0          3           4         0.2          0.3
   2 │         1          3           4         0.2          0.3
   3 │         2          3           4         0.2          0.2
```


@pivot_wider(df, names_from, values_from)

Reshapes the SQL_query to make it wider, increasing the number of columns and reducing the number of rows.

`@pivot_wider` requires some eagerness to pull the disticnt values in the `names_from` columns. It will take the  query until the point of the `@pivot_wider`, and run a query to pull the disinct values in the `names_from` column

**Arguments**
- `sql_query`: The SQL query
  
- `names_from`: The name of the column to get the name of the output columns from.
  
- `values_from`: The name of the column to get the cell values from.
  

**Examples**

```julia
julia> df_long = DataFrame(id = [1, 1, 2, 2],
                           variable = ["A", "B", "A", "B"],
                           value = [1, 2, 3, 4]);

julia> db = connect(duckdb()); dbdf = dt(db, df_long, "df");

julia> @collect @pivot_wider(dbdf, names_from = variable, values_from = value)
2×3 DataFrame
 Row │ id     A      B     
     │ Int64  Int64  Int64 
─────┼─────────────────────
   1 │     1      1      2
   2 │     2      3      4

julia> future_col_names = (:variable, [:A, :B]); 

julia> @eval @collect @pivot_wider(dbdf, names_from = $future_col_names, values_from = value)
2×3 DataFrame
 Row │ id     A      B     
     │ Int64  Int64  Int64 
─────┼─────────────────────
   1 │     1      1      2
   2 │     2      3      4
```



<Badge type="info" class="source-link" text="source"><a href="github.com/TidierOrg/Tidier.jl" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Tidier.@relocate-Tuple{Any, Vararg{Any}}' href='#Tidier.@relocate-Tuple{Any, Vararg{Any}}'><span class="jlbinding">Tidier.@relocate</span></a> <Badge type="info" class="jlObjectType jlMacro" text="Macro" /></summary>



```julia
@relocate(df, columns, before = nothing, after = nothing)
```


Rearranges the columns of a data frame. This function allows for moving specified columns to a new position within the data frame, either before or after a given target column. The `columns`, `before`, and `after` arguments all accept tidy selection functions. Only one of `before` or `after` should be specified. If neither are specified, the selected columns will be moved to the beginning of the data frame.

**Arguments**
- `df`: The data frame.
  
- `columns`: Column or columns to to be moved.
  
- `before`: (Optional) Column or columns before which the specified columns will be moved. If not provided or `nothing`, this argument is ignored.
  
- `after`: (Optional) Column or columns after which the specified columns will be moved. If not provided or `nothing`, this argument is ignored. 
  

**Examples**

```julia
julia> df = DataFrame(A = 1:5, B = 6:10, C = ["A", "b", "C", "D", "E"], D = ['A', 'B','A', 'B','C'],
                      E = 1:5, F = ["A", "b", "C", "D", "E"]);

julia> @relocate(df, where(is_string), before = where(is_integer))
5×6 DataFrame
 Row │ C       F       A      B      E      D    
     │ String  String  Int64  Int64  Int64  Char 
─────┼───────────────────────────────────────────
   1 │ A       A           1      6      1  A
   2 │ b       b           2      7      2  B
   3 │ C       C           3      8      3  A
   4 │ D       D           4      9      4  B
   5 │ E       E           5     10      5  C


julia> @relocate(df, B, C, D, after = E)
5×6 DataFrame
 Row │ A      E      B      C       D     F      
     │ Int64  Int64  Int64  String  Char  String 
─────┼───────────────────────────────────────────
   1 │     1      1      6  A       A     A
   2 │     2      2      7  b       B     b
   3 │     3      3      8  C       A     C
   4 │     4      4      9  D       B     D
   5 │     5      5     10  E       C     E

julia> @relocate(df, B, C, D, after = starts_with("E"))
5×6 DataFrame
 Row │ A      E      B      C       D     F      
     │ Int64  Int64  Int64  String  Char  String 
─────┼───────────────────────────────────────────
   1 │     1      1      6  A       A     A
   2 │     2      2      7  b       B     b
   3 │     3      3      8  C       A     C
   4 │     4      4      9  D       B     D
   5 │     5      5     10  E       C     E

julia> @relocate(df, B:C) # bring columns to the front
5×6 DataFrame
 Row │ B      C       A      D     E      F      
     │ Int64  String  Int64  Char  Int64  String 
─────┼───────────────────────────────────────────
   1 │     6  A           1  A         1  A
   2 │     7  b           2  B         2  b
   3 │     8  C           3  A         3  C
   4 │     9  D           4  B         4  D
   5 │    10  E           5  C         5  E
```


```julia
@relocate(sql_query, columns, before = nothing, after = nothing)
```


Rearranges the columns in the queried table. This function allows for moving specified columns to a new position within the table, either before or after a given target column. The `columns`, `before`, and `after` arguments all accept tidy selection functions. Only one of `before` or `after` should be specified. If neither are specified, the selected columns will be moved to the beginning of the table.

**Arguments**
- `sql_query`: The SQL query 
  
- `columns`: Column or columns to to be moved.
  
- `before`: (Optional) Column or columns before which the specified columns will be moved. If not provided or `nothing`, this argument is ignored.
  
- `after`: (Optional) Column or columns after which the specified columns will be moved. If not provided or `nothing`, this argument is ignored. 
  

**Examples**

```julia
julia> df = DataFrame(id = [string('A' + i ÷ 26, 'A' + i % 26) for i in 0:9], 
                        groups = [i % 2 == 0 ? "aa" : "bb" for i in 1:10], 
                        value = repeat(1:5, 2), 
                        percent = 0.1:0.1:1.0);

julia> db = connect(duckdb());


julia> @chain dt(db, df, "df_view") begin 
        @relocate(groups, value, ends_with("d"), after = percent) 
        @collect
       end
10×4 DataFrame
 Row │ percent  groups  value  id     
     │ Float64  String  Int64  String 
─────┼────────────────────────────────
   1 │     0.1  bb          1  AA
   2 │     0.2  aa          2  AB
   3 │     0.3  bb          3  AC
   4 │     0.4  aa          4  AD
   5 │     0.5  bb          5  AE
   6 │     0.6  aa          1  AF
   7 │     0.7  bb          2  AG
   8 │     0.8  aa          3  AH
   9 │     0.9  bb          4  AI
  10 │     1.0  aa          5  AJ

julia> @chain dt(db, df, "df_view") begin 
        @relocate([:percent, :groups], before = id) 
        @collect
       end
10×4 DataFrame
 Row │ percent  groups  id      value 
     │ Float64  String  String  Int64 
─────┼────────────────────────────────
   1 │     0.1  bb      AA          1
   2 │     0.2  aa      AB          2
   3 │     0.3  bb      AC          3
   4 │     0.4  aa      AD          4
   5 │     0.5  bb      AE          5
   6 │     0.6  aa      AF          1
   7 │     0.7  bb      AG          2
   8 │     0.8  aa      AH          3
   9 │     0.9  bb      AI          4
  10 │     1.0  aa      AJ          5
```



<Badge type="info" class="source-link" text="source"><a href="github.com/TidierOrg/Tidier.jl" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Tidier.@rename-Tuple{Any, Vararg{Any}}' href='#Tidier.@rename-Tuple{Any, Vararg{Any}}'><span class="jlbinding">Tidier.@rename</span></a> <Badge type="info" class="jlObjectType jlMacro" text="Macro" /></summary>



```julia
@rename(df, exprs...)
```


Change the names of individual column names in a DataFrame. Users can also use `@select()` to rename and select columns.

**Arguments**
- `df`: A DataFrame.
  
- `exprs...`: Use `new_name = old_name` syntax to rename selected columns.
  

**Examples**

```julia
julia> df = DataFrame(a = 'a':'e', b = 1:5, c = 11:15);

julia> @chain df begin
         @rename(d = b, e = c)
       end
5×3 DataFrame
 Row │ a     d      e     
     │ Char  Int64  Int64 
─────┼────────────────────
   1 │ a         1     11
   2 │ b         2     12
   3 │ c         3     13
   4 │ d         4     14
   5 │ e         5     15
```


```julia
@rename(sql_query, renamings...)
```


Rename one or more columns in a SQL query.

**Arguments**

-`sql_query`: The SQL query to operate on. -`renamings`: One or more pairs of old and new column names, specified as new name = old name 

**Examples**

```julia
julia> df = DataFrame(id = [string('A' + i ÷ 26, 'A' + i % 26) for i in 0:9], 
                        groups = [i % 2 == 0 ? "aa" : "bb" for i in 1:10], 
                        value = repeat(1:5, 2), 
                        percent = 0.1:0.1:1.0);

julia> db = connect(duckdb());


julia> @chain dt(db, df, "df_view") begin
       @rename(new_name = percent)
       @collect
       end
10×4 DataFrame
 Row │ id      groups  value  new_name 
     │ String  String  Int64  Float64  
─────┼─────────────────────────────────
   1 │ AA      bb          1       0.1
   2 │ AB      aa          2       0.2
   3 │ AC      bb          3       0.3
   4 │ AD      aa          4       0.4
   5 │ AE      bb          5       0.5
   6 │ AF      aa          1       0.6
   7 │ AG      bb          2       0.7
   8 │ AH      aa          3       0.8
   9 │ AI      bb          4       0.9
  10 │ AJ      aa          5       1.0
```



<Badge type="info" class="source-link" text="source"><a href="github.com/TidierOrg/Tidier.jl" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Tidier.@right_join-Tuple{Any, Any, Vararg{Any}}' href='#Tidier.@right_join-Tuple{Any, Any, Vararg{Any}}'><span class="jlbinding">Tidier.@right_join</span></a> <Badge type="info" class="jlObjectType jlMacro" text="Macro" /></summary>



```julia
@right_join(df1, df2, [by])
```


Perform a right join on `df1` and `df2` with an optional `by`.

**Arguments**
- `df1`: A DataFrame.
  
- `df2`: A DataFrame.
  
- `by`: An optional column or tuple of columns. `by` supports interpolation of individual columns. If `by` is not supplied, then it will be inferred from shared names of columns between `df1` and `df2`.
  

**Examples**

```julia
julia> df1 = DataFrame(a = ["a", "b"], b = 1:2);

julia> df2 = DataFrame(a = ["a", "c"], c = 3:4);
  
julia> @right_join(df1, df2)
2×3 DataFrame
 Row │ a       b        c     
     │ String  Int64?   Int64 
─────┼────────────────────────
   1 │ a             1      3
   2 │ c       missing      4

julia> @right_join(df1, df2, a)
2×3 DataFrame
 Row │ a       b        c     
     │ String  Int64?   Int64 
─────┼────────────────────────
   1 │ a             1      3
   2 │ c       missing      4

julia> @right_join(df1, df2, a = a)
2×3 DataFrame
 Row │ a       b        c     
     │ String  Int64?   Int64 
─────┼────────────────────────
   1 │ a             1      3
   2 │ c       missing      4

julia> @right_join(df1, df2, "a")
2×3 DataFrame
 Row │ a       b        c     
     │ String  Int64?   Int64 
─────┼────────────────────────
   1 │ a             1      3
   2 │ c       missing      4

julia> @right_join(df1, df2, "a" = "a")
2×3 DataFrame
 Row │ a       b        c     
     │ String  Int64?   Int64 
─────┼────────────────────────
   1 │ a             1      3
   2 │ c       missing      4
```


```julia
@right_join(sql_query, join_table, orignal_table_col == new_table_col)
```


Perform a right join between two SQL queries based on a specified condition.  Joins can be equi joins or inequality joins. For equi joins, the joining table  key column is dropped. Inequality joins can be made into AsOf or rolling joins  by wrapping the inequality in closest(key &gt;= key2). With inequality joins, the  columns from both tables are kept. Multiple joining criteria can be added, but  need to be separated by commas, ie `closest(key >= key2), key3 == key3`

**Arguments**
- `sql_query`: The primary SQL query to operate on.
  
- `join_table::{SQLQuery, String}`: The secondary SQL table to join with the primary query table. Table that exist on the database already should be written as a string of the name
  
- `orignal_table_col`: Column from the original table that matches for join.  Accepts cols as bare column names or strings 
  
- `new_table_col`: Column from the new table that matches for join.  Accepts columnss as bare column names or strings
  

**Examples**

```julia
julia> df = DataFrame(id = [string('A' + i ÷ 26, 'A' + i % 26) for i in 0:9], 
                        groups = [i % 2 == 0 ? "aa" : "bb" for i in 1:10], 
                        value = repeat(1:5, 2), 
                        percent = 0.1:0.1:1.0);

julia> df2 = DataFrame(id2 = ["AA", "AC", "AE", "AG", "AI", "AK", "AM"],
                category = ["X", "Y", "X", "Y", "X", "Y", "X"],
                score = [88, 92, 77, 83, 95, 68, 74]);

julia> db = connect(duckdb());


julia> dfj = dt(db, df2, "df_join");

julia> @chain dt(db, df, "df_view") begin
         @right_join(dfj, id == id2)
         @arrange(score)
         @collect
       end
7×6 DataFrame
 Row │ id      groups   value    percent    category  score 
     │ String  String?  Int64?   Float64?   String    Int64 
─────┼──────────────────────────────────────────────────────
   1 │ AK      missing  missing  missing    Y            68
   2 │ AM      missing  missing  missing    X            74
   3 │ AE      bb             5        0.5  X            77
   4 │ AG      bb             2        0.7  Y            83
   5 │ AA      bb             1        0.1  X            88
   6 │ AC      bb             3        0.3  Y            92
   7 │ AI      bb             4        0.9  X            95

julia> query = @chain dfj begin
                  @filter(score >= 74) # only show scores above 85 in joining table
                end;

julia> @chain dt(db, df, "df_view") begin
         @right_join(query, id == id2)
         @collect
       end
6×6 DataFrame
 Row │ id      groups   value    percent    category  score 
     │ String  String?  Int64?   Float64?   String    Int64 
─────┼──────────────────────────────────────────────────────
   1 │ AA      bb             1        0.1  X            88
   2 │ AC      bb             3        0.3  Y            92
   3 │ AE      bb             5        0.5  X            77
   4 │ AG      bb             2        0.7  Y            83
   5 │ AI      bb             4        0.9  X            95
   6 │ AM      missing  missing  missing    X            74
```



<Badge type="info" class="source-link" text="source"><a href="github.com/TidierOrg/Tidier.jl" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Tidier.@select-Tuple{Any, Vararg{Any}}' href='#Tidier.@select-Tuple{Any, Vararg{Any}}'><span class="jlbinding">Tidier.@select</span></a> <Badge type="info" class="jlObjectType jlMacro" text="Macro" /></summary>



```julia
@select(df, exprs...)
```


Select variables in a DataFrame.

**Arguments**
- `df`: A DataFrame.
  
- `exprs...`: One or more unquoted variable names separated by commas. Variable names         can also be used as their positions in the data, like `x:y`, to select         a range of variables.
  

**Examples**

```julia
julia> df = DataFrame(a = 'a':'e', b = 1:5, c = 11:15);

julia> @chain df @select(a, b, c)
5×3 DataFrame
 Row │ a     b      c     
     │ Char  Int64  Int64 
─────┼────────────────────
   1 │ a         1     11
   2 │ b         2     12
   3 │ c         3     13
   4 │ d         4     14
   5 │ e         5     15

julia> @chain df @select(a:b)
5×2 DataFrame
 Row │ a     b     
     │ Char  Int64 
─────┼─────────────
   1 │ a         1
   2 │ b         2
   3 │ c         3
   4 │ d         4
   5 │ e         5

julia> @chain df @select(1:2)
5×2 DataFrame
 Row │ a     b     
     │ Char  Int64 
─────┼─────────────
   1 │ a         1
   2 │ b         2
   3 │ c         3
   4 │ d         4
   5 │ e         5

julia> @chain df @select(-(a:b))
5×1 DataFrame
 Row │ c     
     │ Int64 
─────┼───────
   1 │    11
   2 │    12
   3 │    13
   4 │    14
   5 │    15

julia> @chain df @select(!(a:b))
5×1 DataFrame
 Row │ c     
     │ Int64 
─────┼───────
   1 │    11
   2 │    12
   3 │    13
   4 │    14
   5 │    15

julia> @chain df @select(-(a, b))
5×1 DataFrame
 Row │ c     
     │ Int64 
─────┼───────
   1 │    11
   2 │    12
   3 │    13
   4 │    14
   5 │    15

julia> @chain df @select(!(a, b))
5×1 DataFrame
 Row │ c     
     │ Int64 
─────┼───────
   1 │    11
   2 │    12
   3 │    13
   4 │    14
   5 │    15

julia> @chain df begin
         @select(contains("b"), starts_with("c"))
       end
5×2 DataFrame
 Row │ b      c     
     │ Int64  Int64 
─────┼──────────────
   1 │     1     11
   2 │     2     12
   3 │     3     13
   4 │     4     14
   5 │     5     15

julia> @chain df @select(-(1:2))
5×1 DataFrame
 Row │ c     
     │ Int64 
─────┼───────
   1 │    11
   2 │    12
   3 │    13
   4 │    14
   5 │    15

julia> @chain df @select(!(1:2))
5×1 DataFrame
 Row │ c     
     │ Int64 
─────┼───────
   1 │    11
   2 │    12
   3 │    13
   4 │    14
   5 │    15

julia> @chain df @select(-c)
5×2 DataFrame
 Row │ a     b     
     │ Char  Int64 
─────┼─────────────
   1 │ a         1
   2 │ b         2
   3 │ c         3
   4 │ d         4
   5 │ e         5

julia> @chain df begin
         @select(-contains("a"))
       end
5×2 DataFrame
 Row │ b      c     
     │ Int64  Int64 
─────┼──────────────
   1 │     1     11
   2 │     2     12
   3 │     3     13
   4 │     4     14
   5 │     5     15
   
julia> @chain df begin
         @select(!contains("a"))
       end
5×2 DataFrame
 Row │ b      c     
     │ Int64  Int64 
─────┼──────────────
   1 │     1     11
   2 │     2     12
   3 │     3     13
   4 │     4     14
   5 │     5     15

julia> @chain df begin
         @select(where(is_number))
       end
5×2 DataFrame
 Row │ b      c     
     │ Int64  Int64 
─────┼──────────────
   1 │     1     11
   2 │     2     12
   3 │     3     13
   4 │     4     14
   5 │     5     15
```


```julia
@select(sql_query, columns)
```


Select specified columns from a SQL table.

**Arguments**
- `sql_query::SQLQuery`: the SQL query to select columns from.
  
- `columns`: Expressions specifying the columns to select. Columns can be specified by        - name, `table.name`       - selectors - `starts_with()`        - ranges - `col1:col5`       - excluded with `!` notation
  

**Examples**

```julia
julia> df = DataFrame(id = [string('A' + i ÷ 26, 'A' + i % 26) for i in 0:9], 
                        groups = [i % 2 == 0 ? "aa" : "bb" for i in 1:10], 
                        value = repeat(1:5, 2), 
                        percent = 0.1:0.1:1.0);

julia> db = connect(duckdb());


julia> df_mem = dt(db, df, "df_view");

julia> @chain df_mem begin
         @select(groups:percent)
         @collect
       end
10×3 DataFrame
 Row │ groups  value  percent 
     │ String  Int64  Float64 
─────┼────────────────────────
   1 │ bb          1      0.1
   2 │ aa          2      0.2
   3 │ bb          3      0.3
   4 │ aa          4      0.4
   5 │ bb          5      0.5
   6 │ aa          1      0.6
   7 │ bb          2      0.7
   8 │ aa          3      0.8
   9 │ bb          4      0.9
  10 │ aa          5      1.0

julia> @chain df_mem begin
         @select(contains("e"))
         @collect
       end
10×2 DataFrame
 Row │ value  percent 
     │ Int64  Float64 
─────┼────────────────
   1 │     1      0.1
   2 │     2      0.2
   3 │     3      0.3
   4 │     4      0.4
   5 │     5      0.5
   6 │     1      0.6
   7 │     2      0.7
   8 │     3      0.8
   9 │     4      0.9
  10 │     5      1.0
```



<Badge type="info" class="source-link" text="source"><a href="github.com/TidierOrg/Tidier.jl" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Tidier.@semi_join-Tuple{Any, Any, Vararg{Any}}' href='#Tidier.@semi_join-Tuple{Any, Any, Vararg{Any}}'><span class="jlbinding">Tidier.@semi_join</span></a> <Badge type="info" class="jlObjectType jlMacro" text="Macro" /></summary>



```julia
@semi_join(df1, df2, [by])
```


Perform an semi-join on `df1` and `df2` with an optional `by`.

**Arguments**
- `df1`: A DataFrame.
  
- `df2`: A DataFrame.
  
- `by`: An optional column or tuple of columns. `by` supports interpolation of individual columns. If `by` is not supplied, then it will be inferred from shared names of columns between `df1` and `df2`.
  

**Examples**

```julia
julia> df1 = DataFrame(a = ["a", "b"], b = 1:2);

julia> df2 = DataFrame(a = ["a", "c"], c = 3:4);
  
julia> @semi_join(df1, df2)
1×2 DataFrame
 Row │ a       b     
     │ String  Int64 
─────┼───────────────
   1 │ a           1

julia> @semi_join(df1, df2, a)
1×2 DataFrame
 Row │ a       b     
     │ String  Int64 
─────┼───────────────
   1 │ a           1

julia> @semi_join(df1, df2, a = a)
1×2 DataFrame
 Row │ a       b     
     │ String  Int64 
─────┼───────────────
   1 │ a           1

julia> @semi_join(df1, df2, "a")
1×2 DataFrame
 Row │ a       b     
     │ String  Int64 
─────┼───────────────
   1 │ a           1

julia> @semi_join(df1, df2, "a" = "a")
1×2 DataFrame
 Row │ a       b     
     │ String  Int64 
─────┼───────────────
   1 │ a           1
```


```julia
@semi_join(sql_query, join_table, orignal_table_col == new_table_col)
```


Perform an semi join between two SQL queries based on a specified condition.  Joins can be equi joins or inequality joins. For equi joins, the joining table  key column is dropped. Inequality joins can be made into AsOf or rolling joins  by wrapping the inequality in closest(key &gt;= key2). With inequality joins, the  columns from both tables are kept. Multiple joining criteria can be added, but  need to be separated by commas, ie `closest(key >= key2), key3 == key3`

**Arguments**
- `sql_query`: The primary SQL query to operate on.
  
- `join_table::{SQLQuery, String}`: The secondary SQL table to join with the primary query table. Table that exist on the database already should be written as a string of the name
  
- `orignal_table_col`: Column from the original table that matches for join.  Accepts cols as bare column names or strings 
  
- `new_table_col`: Column from the new table that matches for join.  Accepts cols as bare column names or strings
  

**Examples**

```julia
julia> df = DataFrame(id = [string('A' + i ÷ 26, 'A' + i % 26) for i in 0:9], 
                        groups = [i % 2 == 0 ? "aa" : "bb" for i in 1:10], 
                        value = repeat(1:5, 2), 
                        percent = 0.1:0.1:1.0);

julia> df2 = DataFrame(id2 = ["AA", "AC", "AE", "AG", "AI", "AK", "AM"],
                category = ["X", "Y", "X", "Y", "X", "Y", "X"],
                score = [88, 92, 77, 83, 95, 68, 74]);

julia> db = connect(duckdb());


julia> dfj = dt(db, df2, "df_join");

julia> @chain dt(db, df, "df_view") begin
         @semi_join(dfj, id == id2)
         @collect
       end
5×4 DataFrame
 Row │ id      groups  value  percent 
     │ String  String  Int64  Float64 
─────┼────────────────────────────────
   1 │ AA      bb          1      0.1
   2 │ AC      bb          3      0.3
   3 │ AE      bb          5      0.5
   4 │ AG      bb          2      0.7
   5 │ AI      bb          4      0.9
```



<Badge type="info" class="source-link" text="source"><a href="github.com/TidierOrg/Tidier.jl" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Tidier.@separate-Tuple{Any, Vararg{Any}}' href='#Tidier.@separate-Tuple{Any, Vararg{Any}}'><span class="jlbinding">Tidier.@separate</span></a> <Badge type="info" class="jlObjectType jlMacro" text="Macro" /></summary>



@separate(df, from, into, sep, extra = &quot;merge&quot;)

Separate a string column into mulitiple new columns based on a specified delimter 

**Arguments**
- `df`: A DataFrame
  
- `from`: Column that will be split
  
- `into`: New column names, supports [] or ()
  
- `sep`: the string or character on which to split
  
- `extra`: &quot;merge&quot;, &quot;warn&quot; and &quot;drop&quot; . If not enough columns are provided, extra determines whether additional entries will be merged into the final one or dropped. &quot;warn&quot; generates a warning message for dropped values.
  

**Examples**

```julia
julia> df = DataFrame(a = ["1-1", "2-2", "3-3-3"]);

julia> @separate(df, a, [b, c, d], "-")
3×3 DataFrame
 Row │ b          c          d          
     │ SubStrin…  SubStrin…  SubStrin…? 
─────┼──────────────────────────────────
   1 │ 1          1          missing    
   2 │ 2          2          missing    
   3 │ 3          3          3

julia> @chain df begin
         @separate(a, (b, c, d), "-")
       end
3×3 DataFrame
 Row │ b          c          d          
     │ SubStrin…  SubStrin…  SubStrin…? 
─────┼──────────────────────────────────
   1 │ 1          1          missing    
   2 │ 2          2          missing    
   3 │ 3          3          3

julia> @separate(df, a, (b, c), "-")
3×2 DataFrame
 Row │ b          c      
     │ SubStrin…  String 
─────┼───────────────────
   1 │ 1          1
   2 │ 2          2
   3 │ 3          3-3

julia> @chain df begin
         @separate(a, (b, c), "-", extra = "drop")
       end
3×2 DataFrame
 Row │ b          c         
     │ SubStrin…  SubStrin… 
─────┼──────────────────────
   1 │ 1          1
   2 │ 2          2
   3 │ 3          3

```


```julia
  @separate(sql_query, from_col, into_cols, sep)
```


Separate a string column into mulitiple new columns based on a specified delimter 

**Arguments**
- `sql_query`: The SQL query
  
- `from_col`: Column that will be split
  
- `into_cols`: New column names, supports [] or ()
  
- `sep`: the string or character on which to split
  

**Examples**

```julia
julia> db = connect(duckdb());

julia> df = DataFrame(a = ["1-1", "2-2", "3-3-3"]); 

julia> @chain dt(db, df, "df") @separate(a, [b, c, d], "-") @collect
3×3 DataFrame
 Row │ b       c       d       
     │ String  String  String? 
─────┼─────────────────────────
   1 │ 1       1       missing 
   2 │ 2       2       missing 
   3 │ 3       3       3

julia> @chain dt(db, df, "df") @separate( a, [c, d], "-") @collect
3×2 DataFrame
 Row │ c       d      
     │ String  String 
─────┼────────────────
   1 │ 1       1
   2 │ 2       2
   3 │ 3       3-3
```



<Badge type="info" class="source-link" text="source"><a href="github.com/TidierOrg/Tidier.jl" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Tidier.@slice_max-Tuple{Any, Vararg{Any}}' href='#Tidier.@slice_max-Tuple{Any, Vararg{Any}}'><span class="jlbinding">Tidier.@slice_max</span></a> <Badge type="info" class="jlObjectType jlMacro" text="Macro" /></summary>



```julia
@slice_max(df, column; with_ties = true, n, prop, missing_rm = true)
```


Retrieve rows with the maximum value(s) from the specified column of a DataFrame or GroupedDataFrame.

**Arguments**
- `df`: The source data frame or grouped data frame from which to slice rows.
  
- `column`: The column for which to slice the maximum values.
  
- `with_ties`: Whether or not all ties will be shown, defaults to true. When false it will only show the first row. 
  
- `prop`: The proportion of rows to slice.
  
- `n`: An optional integer argument to specify the number of maximum rows to retrieve. If with_ties = true, and the ties &gt; n, n will be overridden. 
  
- `missing_rm`: Defaults to true, skips the missing values when determining the proportion of the dataframe to slice.
  

**Examples**

```julia
julia> df = DataFrame(
           a = [missing, 0.2, missing, missing, 1, missing, 5, 6],
           b = [0.3, 2, missing, 3, 6, 5, 7, 7],
           c = [0.2, 0.2, 0.2, missing, 1, missing, 5, 6]);

julia> @chain df begin
         @slice_max(b)
       end 
2×3 DataFrame
 Row │ a         b         c        
     │ Float64?  Float64?  Float64? 
─────┼──────────────────────────────
   1 │      5.0       7.0       5.0
   2 │      6.0       7.0       6.0

julia> @chain df begin
         @slice_max(b, with_ties = false)
       end 
1×3 DataFrame
 Row │ a         b         c        
     │ Float64?  Float64?  Float64? 
─────┼──────────────────────────────
   1 │      5.0       7.0       5.0

julia> @chain df begin
         @slice_max(b, n = 3)
       end 
3×3 DataFrame
 Row │ a         b         c        
     │ Float64?  Float64?  Float64? 
─────┼──────────────────────────────
   1 │      5.0       7.0       5.0
   2 │      6.0       7.0       6.0
   3 │      1.0       6.0       1.0
   
julia> @chain df begin
         @slice_max(b, prop = 0.5, missing_rm = true)
       end
3×3 DataFrame
 Row │ a         b         c        
     │ Float64?  Float64?  Float64? 
─────┼──────────────────────────────
   1 │      5.0       7.0       5.0
   2 │      6.0       7.0       6.0
   3 │      1.0       6.0       1.0
```


```julia
@slice_max(sql_query, column, n = 1)
```


Select rows with the largest values in specified column. This will always return ties. 

**Arguments**
- `sql_query::SQLQuery`: The SQL query to operate on.
  
- `column`: Column to identify the smallest values.
  
- `n`: The number of rows to select with the largest values for each specified column. Default is 1, which selects the row with the smallest value.
  

**Examples**

```julia
julia> df = DataFrame(id = [string('A' + i ÷ 26, 'A' + i % 26) for i in 0:9], 
                        groups = [i % 2 == 0 ? "aa" : "bb" for i in 1:10], 
                        value = repeat(1:5, 2), 
                        percent = 0.1:0.1:1.0);

julia> db = connect(duckdb());


julia> @chain dt(db, df, "df_view") begin
         @group_by(groups)
         @slice_max(value, n = 2)
         @arrange(groups)
         @collect
       end
4×5 DataFrame
 Row │ id      groups  value  percent  rank_col 
     │ String  String  Int64  Float64  Int64    
─────┼──────────────────────────────────────────
   1 │ AJ      aa          5      1.0         1
   2 │ AD      aa          4      0.4         2
   3 │ AE      bb          5      0.5         1
   4 │ AI      bb          4      0.9         2

julia> @chain dt(db, df, "df_view") begin
         @slice_max(value)
         @collect
       end
2×5 DataFrame
 Row │ id      groups  value  percent  rank_col 
     │ String  String  Int64  Float64  Int64    
─────┼──────────────────────────────────────────
   1 │ AE      bb          5      0.5         1
   2 │ AJ      aa          5      1.0         1

julia> @chain dt(db, df, "df_view") begin
        @filter(percent < .9)
        @slice_max(percent)
        @collect
       end
1×5 DataFrame
 Row │ id      groups  value  percent  rank_col 
     │ String  String  Int64  Float64  Int64    
─────┼──────────────────────────────────────────
   1 │ AH      aa          3      0.8         1

julia>  @chain dt(db, df, "df_view") begin
         @group_by groups
         @slice_max(percent)
         @arrange groups
         @collect
       end
2×5 DataFrame
 Row │ id      groups  value  percent  rank_col 
     │ String  String  Int64  Float64  Int64    
─────┼──────────────────────────────────────────
   1 │ AJ      aa          5      1.0         1
   2 │ AI      bb          4      0.9         1

julia> @chain dt(db, df, "df_view") begin
         @summarize(percent_mean = mean(percent), _by = groups)
         @slice_max(percent_mean)
         @collect
       end
1×3 DataFrame
 Row │ groups  percent_mean  rank_col 
     │ String  Float64       Int64    
─────┼────────────────────────────────
   1 │ aa               0.6         1
```



<Badge type="info" class="source-link" text="source"><a href="github.com/TidierOrg/Tidier.jl" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Tidier.@slice_min-Tuple{Any, Vararg{Any}}' href='#Tidier.@slice_min-Tuple{Any, Vararg{Any}}'><span class="jlbinding">Tidier.@slice_min</span></a> <Badge type="info" class="jlObjectType jlMacro" text="Macro" /></summary>



```julia
@slice_min(df, column; with_ties = true, n, prop, missing_rm = true)
```


Retrieve rows with the minimum value(s) from the specified column of a DataFrame or GroupedDataFrame.

**Arguments**
- `df`: The source data frame or grouped data frame from which to slice rows.
  
- `column`: The column for which to slice the minimum values.
  
- `with_ties`: Whether or not all ties will be shown, defaults to true and shows all ties. When false it will only show the first row. 
  
- `prop`: The proportion of rows to slice.
  
- `n`: An optional integer argument to specify the number of minimum rows to retrieve. If with_ties = true, and the ties &gt; n, n will be overridden. 
  
- `missing_rm`: Defaults to true, skips the missing values when determining the proportion of the dataframe to slice.
  

**Examples**

```julia
julia> df = DataFrame(
           a = [missing, 0.2, missing, missing, 1, missing, 5, 6],
           b = [0.3, 2, missing, 0.3, 6, 5, 7, 7],
           c = [0.2, 0.2, 0.2, missing, 1, missing, 5, 6]);

julia> @chain df begin
         @slice_min(b)
       end 
2×3 DataFrame
 Row │ a         b         c         
     │ Float64?  Float64?  Float64?  
─────┼───────────────────────────────
   1 │  missing       0.3        0.2
   2 │  missing       0.3  missing

julia> @chain df begin
         @slice_min(b, with_ties = false)
       end 
1×3 DataFrame
 Row │ a         b         c        
     │ Float64?  Float64?  Float64? 
─────┼──────────────────────────────
   1 │  missing       0.3       0.2

julia> @chain df begin
         @slice_min(b, n = 3)
       end
3×3 DataFrame
 Row │ a          b         c         
     │ Float64?   Float64?  Float64?  
─────┼────────────────────────────────
   1 │ missing         0.3        0.2
   2 │ missing         0.3  missing   
   3 │       0.2       2.0        0.2  
   
julia> @chain df begin
         @slice_min(b, prop = 0.5, missing_rm = true)
       end
3×3 DataFrame
 Row │ a          b         c         
     │ Float64?   Float64?  Float64?  
─────┼────────────────────────────────
   1 │ missing         0.3        0.2
   2 │ missing         0.3  missing   
   3 │       0.2       2.0        0.2
```


```julia
@slice_min(sql_query, column, n = 1)
```


Select rows with the smallest values in specified column. This will always return ties. 

**Arguments**
- `sql_query::SQLQuery`: The SQL query to operate on.
  
- `column`: Column to identify the smallest values.
  
- `n`: The number of rows to select with the smallest values for each specified column. Default is 1, which selects the row with the smallest value.
  

**Examples**

```julia
julia> df = DataFrame(id = [string('A' + i ÷ 26, 'A' + i % 26) for i in 0:9], 
                        groups = [i % 2 == 0 ? "aa" : "bb" for i in 1:10], 
                        value = repeat(1:5, 2), 
                        percent = 0.1:0.1:1.0);

julia> db = connect(duckdb());


julia> @chain dt(db, df, "df_view") begin
         @group_by(groups)
         @slice_min(value, n = 2)
         @arrange(groups, percent) # arranged due to duckdb multi threading
         @collect
       end
4×5 DataFrame
 Row │ id      groups  value  percent  rank_col 
     │ String  String  Int64  Float64  Int64    
─────┼──────────────────────────────────────────
   1 │ AB      aa          2      0.2         2
   2 │ AF      aa          1      0.6         1
   3 │ AA      bb          1      0.1         1
   4 │ AG      bb          2      0.7         2

julia> @chain dt(db, df, "df_view") begin
         @slice_min(value)
         @collect
       end
2×5 DataFrame
 Row │ id      groups  value  percent  rank_col 
     │ String  String  Int64  Float64  Int64    
─────┼──────────────────────────────────────────
   1 │ AA      bb          1      0.1         1
   2 │ AF      aa          1      0.6         1

julia> @chain dt(db, df, "df_view") begin
         @filter(percent > .1)
         @slice_min(percent)
         @collect
       end
1×5 DataFrame
 Row │ id      groups  value  percent  rank_col 
     │ String  String  Int64  Float64  Int64    
─────┼──────────────────────────────────────────
   1 │ AB      aa          2      0.2         1

julia> @chain dt(db, df, "df_view") begin
         @group_by groups
         @slice_min(percent)
         @arrange groups
         @collect
       end
2×5 DataFrame
 Row │ id      groups  value  percent  rank_col 
     │ String  String  Int64  Float64  Int64    
─────┼──────────────────────────────────────────
   1 │ AB      aa          2      0.2         1
   2 │ AA      bb          1      0.1         1

julia> @chain dt(db, df, "df_view") begin
         @summarize(percent_mean = mean(percent), _by = groups)
         @slice_min(percent_mean)
         @collect
       end
1×3 DataFrame
 Row │ groups  percent_mean  rank_col 
     │ String  Float64       Int64    
─────┼────────────────────────────────
   1 │ bb               0.5         1
```



<Badge type="info" class="source-link" text="source"><a href="github.com/TidierOrg/Tidier.jl" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Tidier.@slice_sample-Tuple{Any, Vararg{Any}}' href='#Tidier.@slice_sample-Tuple{Any, Vararg{Any}}'><span class="jlbinding">Tidier.@slice_sample</span></a> <Badge type="info" class="jlObjectType jlMacro" text="Macro" /></summary>



```julia
@slice_sample(df, [n = 1, prop, replace = false])
```


Randomly sample rows from a DataFrame `df` or from each group in a GroupedDataFrame. The default is to return 1 row. Either the number of rows (`n`) or the proportion of rows (`prop`) should be provided as a keyword argument.

**Arguments**
- `df`: The source data frame or grouped data frame from which to sample rows.
  
- `n`: The number of rows to sample. Defaults to `1`.
  
- `prop`: The proportion of rows to sample.
  
- `replace`: Whether to sample with replacement. Defaults to `false`.
  

**Examples**

```julia
julia> df = DataFrame(a = 1:10, b = 11:20);

julia> using StableRNGs, Random

julia> rng = StableRNG(1);

julia> Random.seed!(rng, 1);

julia> @chain df begin 
         @slice_sample(n = 5)
       end
5×2 DataFrame
 Row │ a      b     
     │ Int64  Int64 
─────┼──────────────
   1 │     6     16
   2 │     1     11
   3 │     5     15
   4 │     4     14
   5 │     8     18

julia> @chain df begin 
         @slice_sample(n = 5, replace = true)
       end
5×2 DataFrame
 Row │ a      b     
     │ Int64  Int64 
─────┼──────────────
   1 │     7     17
   2 │     2     12
   3 │     1     11
   4 │     4     14
   5 │     2     12

julia> @chain df begin 
         @slice_sample(prop = 0.5)
       end
5×2 DataFrame
 Row │ a      b     
     │ Int64  Int64 
─────┼──────────────
   1 │     6     16
   2 │     7     17
   3 │     5     15
   4 │     9     19
   5 │     2     12

julia> @chain df begin 
         @slice_sample(prop = 0.5, replace = true)
       end
5×2 DataFrame
 Row │ a      b     
     │ Int64  Int64 
─────┼──────────────
   1 │    10     20
   2 │     4     14
   3 │     9     19
   4 │     9     19
   5 │     8     18
```


```julia
@slice_sample(sql_query, n)
```


Randomly select a specified number of rows from a SQL table.

**Arguments**
- `sql_query::SQLQuery`: The SQL query to sample
  
- `n`: The number of rows to randomly select.
  

**Examples**

```julia
julia> df = DataFrame(id = [string('A' + i ÷ 26, 'A' + i % 26) for i in 0:9], 
                        groups = [i % 2 == 0 ? "aa" : "bb" for i in 1:10], 
                        value = repeat(1:5, 2), 
                        percent = 0.1:0.1:1.0);

julia> db = connect(duckdb());


julia> @chain dt(db, df, "df_view") begin
         @group_by(groups)
         @slice_sample(n = 2)
         @collect
       end;

julia> @chain dt(db, df, "df_view") begin
       @slice_sample()
       @collect
       end;
```



<Badge type="info" class="source-link" text="source"><a href="github.com/TidierOrg/Tidier.jl" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Tidier.@summarise-Tuple{Any, Vararg{Any}}' href='#Tidier.@summarise-Tuple{Any, Vararg{Any}}'><span class="jlbinding">Tidier.@summarise</span></a> <Badge type="info" class="jlObjectType jlMacro" text="Macro" /></summary>



```julia
@summarize(df, exprs...)
@summarise(df, exprs...)
```


Create a new DataFrame with one row that aggregating all observations from the input DataFrame or GroupedDataFrame. 

**Arguments**
- `df`: A DataFrame.
  
- `exprs...`: a `new_variable = function(old_variable)` pair. `function()` should be an aggregate function that returns a single value. 
  

**Examples**

```julia
julia> df = DataFrame(a = 'a':'e', b = 1:5, c = 11:15);

julia> @chain df begin
         @summarize(mean_b = mean(b),
                    median_b = median(b))
       end
1×2 DataFrame
 Row │ mean_b   median_b 
     │ Float64  Float64  
─────┼───────────────────
   1 │     3.0       3.0

julia> @chain df begin
         @summarize begin
           mean_b = mean(b)
           median_b = median(b)
         end
       end
1×2 DataFrame
 Row │ mean_b   median_b 
     │ Float64  Float64  
─────┼───────────────────
   1 │     3.0       3.0 

julia> @chain df begin
         @summarise(mean_b = mean(b), median_b = median(b))
       end
1×2 DataFrame
 Row │ mean_b   median_b 
     │ Float64  Float64  
─────┼───────────────────
   1 │     3.0       3.0
   
julia> @chain df begin
         @summarize(across((b,c), (minimum, maximum)))
       end
1×4 DataFrame
 Row │ b_minimum  c_minimum  b_maximum  c_maximum 
     │ Int64      Int64      Int64      Int64     
─────┼────────────────────────────────────────────
   1 │         1         11          5         15

julia> @chain df begin
         @summarize(across(where(is_number), minimum))
       end
1×2 DataFrame
 Row │ b_minimum  c_minimum 
     │ Int64      Int64     
─────┼──────────────────────
   1 │         1         11
```


```julia
   @summarize(sql_query, exprs...; _by)
```


Aggregate and summarize specified columns of a SQL table.

**Arguments**
- `sql_query::SQLQuery`: The SQL query to summarize
  
- `exprs`: Expressions defining the aggregation and summarization operations. These can specify simple aggregations like mean, sum, and count, or more complex expressions involving existing column values.
  
- `_by`: optional argument that supports single column names, or vectors of columns to allow for grouping for the aggregatation in the macro call
  

**Examples**

```julia
julia> df = DataFrame(id = [string('A' + i ÷ 26, 'A' + i % 26) for i in 0:9], 
                        groups = [i % 2 == 0 ? "aa" : "bb" for i in 1:10], 
                        value = repeat(1:5, 2), 
                        percent = 0.1:0.1:1.0);

julia> db = connect(duckdb());


julia> @chain dt(db, df, "df_view") begin
         @group_by(groups)
         @summarise(across((ends_with("e"), starts_with("p")), (mean, sum)))
         @arrange(groups)
         @collect
       end
2×5 DataFrame
 Row │ groups  value_mean  percent_mean  value_sum  percent_sum 
     │ String  Float64     Float64       Int128     Float64     
─────┼──────────────────────────────────────────────────────────
   1 │ aa             3.0           0.6         15          3.0
   2 │ bb             3.0           0.5         15          2.5

julia> @chain dt(db, df, "df_view") begin
         @group_by(groups)
         @summarise(test = sum(percent), n = n())
         @arrange(groups)
         @collect
       end
2×3 DataFrame
 Row │ groups  test     n     
     │ String  Float64  Int64 
─────┼────────────────────────
   1 │ aa          3.0      5
   2 │ bb          2.5      5

julia> @chain dt(db, df, "df_view") begin
                @summarise(test = sum(percent), n = n(), _by = groups)
                @arrange(groups)
                @collect
              end
2×3 DataFrame
 Row │ groups  test     n     
     │ String  Float64  Int64 
─────┼────────────────────────
   1 │ aa          3.0      5
   2 │ bb          2.5      5
```



<Badge type="info" class="source-link" text="source"><a href="github.com/TidierOrg/Tidier.jl" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Tidier.@summarize-Tuple{Any, Vararg{Any}}' href='#Tidier.@summarize-Tuple{Any, Vararg{Any}}'><span class="jlbinding">Tidier.@summarize</span></a> <Badge type="info" class="jlObjectType jlMacro" text="Macro" /></summary>



```julia
@summarize(df, exprs...)
@summarise(df, exprs...)
```


Create a new DataFrame with one row that aggregating all observations from the input DataFrame or GroupedDataFrame. 

**Arguments**
- `df`: A DataFrame.
  
- `exprs...`: a `new_variable = function(old_variable)` pair. `function()` should be an aggregate function that returns a single value. 
  

**Examples**

```julia
julia> df = DataFrame(a = 'a':'e', b = 1:5, c = 11:15);

julia> @chain df begin
         @summarize(mean_b = mean(b),
                    median_b = median(b))
       end
1×2 DataFrame
 Row │ mean_b   median_b 
     │ Float64  Float64  
─────┼───────────────────
   1 │     3.0       3.0

julia> @chain df begin
         @summarize begin
           mean_b = mean(b)
           median_b = median(b)
         end
       end
1×2 DataFrame
 Row │ mean_b   median_b 
     │ Float64  Float64  
─────┼───────────────────
   1 │     3.0       3.0 

julia> @chain df begin
         @summarise(mean_b = mean(b), median_b = median(b))
       end
1×2 DataFrame
 Row │ mean_b   median_b 
     │ Float64  Float64  
─────┼───────────────────
   1 │     3.0       3.0
   
julia> @chain df begin
         @summarize(across((b,c), (minimum, maximum)))
       end
1×4 DataFrame
 Row │ b_minimum  c_minimum  b_maximum  c_maximum 
     │ Int64      Int64      Int64      Int64     
─────┼────────────────────────────────────────────
   1 │         1         11          5         15

julia> @chain df begin
         @summarize(across(where(is_number), minimum))
       end
1×2 DataFrame
 Row │ b_minimum  c_minimum 
     │ Int64      Int64     
─────┼──────────────────────
   1 │         1         11
```


```julia
   @summarize(sql_query, exprs...; _by)
```


Aggregate and summarize specified columns of a SQL table.

**Arguments**
- `sql_query::SQLQuery`: The SQL query to summarize
  
- `exprs`: Expressions defining the aggregation and summarization operations. These can specify simple aggregations like mean, sum, and count, or more complex expressions involving existing column values.
  
- `_by`: optional argument that supports single column names, or vectors of columns to allow for grouping for the aggregatation in the macro call
  

**Examples**

```julia
julia> df = DataFrame(id = [string('A' + i ÷ 26, 'A' + i % 26) for i in 0:9], 
                        groups = [i % 2 == 0 ? "aa" : "bb" for i in 1:10], 
                        value = repeat(1:5, 2), 
                        percent = 0.1:0.1:1.0);

julia> db = connect(duckdb());


julia> @chain dt(db, df, "df_view") begin
         @group_by(groups)
         @summarise(across((ends_with("e"), starts_with("p")), (mean, sum)))
         @arrange(groups)
         @collect
       end
2×5 DataFrame
 Row │ groups  value_mean  percent_mean  value_sum  percent_sum 
     │ String  Float64     Float64       Int128     Float64     
─────┼──────────────────────────────────────────────────────────
   1 │ aa             3.0           0.6         15          3.0
   2 │ bb             3.0           0.5         15          2.5

julia> @chain dt(db, df, "df_view") begin
         @group_by(groups)
         @summarise(test = sum(percent), n = n())
         @arrange(groups)
         @collect
       end
2×3 DataFrame
 Row │ groups  test     n     
     │ String  Float64  Int64 
─────┼────────────────────────
   1 │ aa          3.0      5
   2 │ bb          2.5      5

julia> @chain dt(db, df, "df_view") begin
                @summarise(test = sum(percent), n = n(), _by = groups)
                @arrange(groups)
                @collect
              end
2×3 DataFrame
 Row │ groups  test     n     
     │ String  Float64  Int64 
─────┼────────────────────────
   1 │ aa          3.0      5
   2 │ bb          2.5      5
```



<Badge type="info" class="source-link" text="source"><a href="github.com/TidierOrg/Tidier.jl" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Tidier.@summary-Tuple{Any, Vararg{Any}}' href='#Tidier.@summary-Tuple{Any, Vararg{Any}}'><span class="jlbinding">Tidier.@summary</span></a> <Badge type="info" class="jlObjectType jlMacro" text="Macro" /></summary>



```julia
   @summary(df, cols...)
```


For numerical columns, returns a dataframe with the Q1,Q3, min, max, mean, median, number of missing values

**Arguments**
- &#39;df&#39;: A DataFrame
  
- `cols`: columns on which summary will be performed. This is an optional arguement, without which summary will be performed on all numerical columns
  

**Examples**

```julia
julia> df = DataFrame(a = [1, 2, 3, 4, 5],
                      b = [missing, 7, 8, 9, 10],
                      c = [11, missing, 13, 14, missing],
                      d = [16.1, 17.2, 18.3, 19.4, 20.5],
                      e = ["a", "a", "a", "a", "a"]);

julia> @summary(df);

julia> @summary(df, (b:d));

julia> @chain df begin
         @summary(b:d)
       end;
```


```julia
   @summary(sql_query)
```


Get summary stastics on a table or a file when using DuckDB (max, min, q1, q2, q3, avg, std, count, unique)

**Arguments**
- `sql_query`: The SQL table or file to summarize
  

**Examples**

```julia
julia> df = DataFrame(id = [string('A' + i ÷ 26, 'A' + i % 26) for i in 0:9], 
                        groups = [i % 2 == 0 ? "aa" : "bb" for i in 1:10], 
                        value = repeat(1:5, 2), 
                        percent = 0.1:0.1:1.0);

julia> db = connect(duckdb());

julia> @chain dt(db, df, "df_view") begin
        @summary
        @collect
       end;
```



<Badge type="info" class="source-link" text="source"><a href="github.com/TidierOrg/Tidier.jl" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Tidier.@transmute-Tuple{Any, Vararg{Any}}' href='#Tidier.@transmute-Tuple{Any, Vararg{Any}}'><span class="jlbinding">Tidier.@transmute</span></a> <Badge type="info" class="jlObjectType jlMacro" text="Macro" /></summary>



```julia
@transmute(df, exprs...)
```


Create a new DataFrame with only computed columns.

**Arguments**
- `df`: A DataFrame.
  
- `exprs...`: add new columns or replace values of existed columns using        `new_variable = values` syntax.
  

**Examples**

```julia
julia> df = DataFrame(a = 'a':'e', b = 1:5, c = 11:15);

julia> @chain df begin
         @transmute(d = b + c)
       end
5×1 DataFrame
 Row │ d     
     │ Int64 
─────┼───────
   1 │    12
   2 │    14
   3 │    16
   4 │    18
   5 │    20
```


```julia
@transmute(sql_query, exprs...; _by, _frame, _order)
```


Transmute SQL table by adding new columns or modifying existing ones. Unlike `@mutate`, `@transmute` only keep columns on the left hand side of the `=`  in transmute or grouping.

**Arguments**
- `sql_query::SQLQuery`: The SQL query to operate on.
  
- `exprs`: Expressions for mutating the table. New columns can be added or existing columns modified using `column_name = expression syntax`, where expression can involve existing columns.
  
- `_by`: optional argument that supports single column names, or vectors of columns to allow for grouping for the transformation in the macro call
  
- `_frame`: optional argument that allows window frames to be determined within `@mutate`. supports single digits or tuples of numbers. supports `desc()` prefix
  
- `_order`: optional argument that allows window orders to be determined within `@mutate`. supports single columns or vectors of names  
  

**Examples**

```julia
julia> df = DataFrame(id = [string('A' + i ÷ 26, 'A' + i % 26) for i in 0:9], 
                        groups = [i % 2 == 0 ? "aa" : "bb" for i in 1:10], 
                        value = repeat(1:5, 2), 
                        percent = 0.1:0.1:1.0);

julia> db = connect(duckdb());

julia> @chain dt(db, df, "df_view") begin
         @transmute(value = value * 4, new_col = percent^2)
         @collect
       end
10×2 DataFrame
 Row │ value  new_col 
     │ Int64  Float64 
─────┼────────────────
   1 │     4     0.01
   2 │     8     0.04
   3 │    12     0.09
   4 │    16     0.16
   5 │    20     0.25
   6 │     4     0.36
   7 │     8     0.49
   8 │    12     0.64
   9 │    16     0.81
  10 │    20     1.0

julia> @chain dt(db, df, "df_view") begin
         @transmute(max = maximum(value), _by = groups)
         @arrange(groups)
         @collect
       end
10×2 DataFrame
 Row │ groups  max   
     │ String  Int64 
─────┼───────────────
   1 │ aa          5
   2 │ aa          5
   3 │ aa          5
   4 │ aa          5
   5 │ aa          5
   6 │ bb          5
   7 │ bb          5
   8 │ bb          5
   9 │ bb          5
  10 │ bb          5
```



<Badge type="info" class="source-link" text="source"><a href="github.com/TidierOrg/Tidier.jl" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Tidier.@unite-Tuple{Any, Vararg{Any}}' href='#Tidier.@unite-Tuple{Any, Vararg{Any}}'><span class="jlbinding">Tidier.@unite</span></a> <Badge type="info" class="jlObjectType jlMacro" text="Macro" /></summary>



```julia
  @unite(df, new_cols, from_cols, sep, remove = true)
```


Separate a multiple columns into one new columns using a specific delimter

**Arguments**
- `df`: A DataFrame
  
- `new_col`: New column that will recieve the combination
  
- `from_cols`: Column names that it will combine, supports [] or ()
  
- `sep`: the string or character that will separate the values in the new column
  
- `remove`: defaults to `true`, removes input columns from data frame
  

**Examples**

```julia
julia> df = DataFrame( b = ["1", "2", "3"], c = ["1", "2", "3"], d = [missing, missing, "3"]);

julia> @unite(df, new_col, (b, c, d), "-")
3×1 DataFrame
 Row │ new_col 
     │ String  
─────┼─────────
   1 │ 1-1
   2 │ 2-2
   3 │ 3-3-3
   
julia> @unite(df, new_col, (b, c, d), "-", remove = false)
3×4 DataFrame
 Row │ b       c       d        new_col 
     │ String  String  String?  String  
─────┼──────────────────────────────────
   1 │ 1       1       missing  1-1
   2 │ 2       2       missing  2-2
   3 │ 3       3       3        3-3-3
```


```julia
  @unite(sql_query, new_cols, from_cols, sep, remove = true)
```


Separate a multiple columns into one new columns using a specific delimter

**Arguments**
- `sql_query`: The SQL query
  
- `new_col`: New column that will recieve the combination
  
- `from_cols`: Column names that it will combine, supports [] or ()
  
- `sep`: the string or character that will separate the values in the new column
  

**Examples**

```julia
julia> db = connect(duckdb());

julia> df = DataFrame( b = ["1", "2", "3"], c = ["1", "2", "3"], d = [missing, missing, "3"]);

julia> @chain dt(db, df, "df") @unite(new_col, (b, c, d), "-") @collect
3×1 DataFrame
 Row │ new_col 
     │ String  
─────┼─────────
   1 │ 1-1
   2 │ 2-2
   3 │ 3-3-3
```



<Badge type="info" class="source-link" text="source"><a href="github.com/TidierOrg/Tidier.jl" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Tidier.@unnest_longer-Tuple{Any, Vararg{Any}}' href='#Tidier.@unnest_longer-Tuple{Any, Vararg{Any}}'><span class="jlbinding">Tidier.@unnest_longer</span></a> <Badge type="info" class="jlObjectType jlMacro" text="Macro" /></summary>



```julia
@unnest_longer(df, columns, indices_include=false)
```


Unnest arrays in columns from a DataFrame to create a longer DataFrame with one row for each entry of the array.

**Arguments**
- `df`: A DataFrame.
  
- `columns`: Columns to unnest. Can be a column symbols or a range of columns if they align for number of values.
  
- `indices_include`: Optional. When set to `true`, adds an index column for each unnested column, which logs the position of each array entry.
  
- `keep_empty`: Optional. When set to `true`, rows with empty arrays are kept, not skipped, and unnested as missing. 
  

**Examples**

```julia
julia> df = DataFrame(a=[1, 2], b=[[1, 2], [3, 4]], c=[[5, 6], [7, 8]])
2×3 DataFrame
 Row │ a      b       c      
     │ Int64  Array…  Array… 
─────┼───────────────────────
   1 │     1  [1, 2]  [5, 6]
   2 │     2  [3, 4]  [7, 8]

julia> @unnest_longer(df, 2)
4×3 DataFrame
 Row │ a      b      c      
     │ Int64  Int64  Array… 
─────┼──────────────────────
   1 │     1      1  [5, 6]
   2 │     1      2  [5, 6]
   3 │     2      3  [7, 8]
   4 │     2      4  [7, 8]

julia> @unnest_longer(df, b:c, indices_include = true)
4×5 DataFrame
 Row │ a      b      c      b_id   c_id  
     │ Int64  Int64  Int64  Int64  Int64 
─────┼───────────────────────────────────
   1 │     1      1      5      1      1
   2 │     1      2      6      2      2
   3 │     2      3      7      1      1
   4 │     2      4      8      2      2

julia> df2 = DataFrame(x = 1:4, y = [[], [1, 2, 3], [4, 5], Int[]])
4×2 DataFrame
 Row │ x      y            
     │ Int64  Array…       
─────┼─────────────────────
   1 │     1  Any[]
   2 │     2  Any[1, 2, 3]
   3 │     3  Any[4, 5]
   4 │     4  Any[]

julia> @unnest_longer(df2, y, keep_empty = true)
7×2 DataFrame
 Row │ x      y       
     │ Int64  Int64?  
─────┼────────────────
   1 │     1  missing 
   2 │     2        1
   3 │     2        2
   4 │     2        3
   5 │     3        4
   6 │     3        5
   7 │     4  missing 
```


```julia
@unnest_longer(sql_query, columns...)
```


Unnests specified columns into longer format. This function takes multiple columns containing arrays or other nested structures and expands them into a longer format, where each element of the arrays becomes a separate row.

**Arguments**
- `sql_query`: The SQL query 
  
- `columns...`: One or more columns containing arrays or other nested structures to be unnested.
  

**Examples**

```julia
julia> db = connect(duckdb());

julia> DuckDB.query(db, "
            CREATE TABLE nt (
                id INTEGER,
                data ROW(a INTEGER[], b INTEGER[])
                );
            INSERT INTO nt VALUES
                (1, (ARRAY[1,2], ARRAY[3,4])),
                (2, (ARRAY[5,6], ARRAY[7,8,9])),
                (3, (ARRAY[10,11], ARRAY[12,13]));");

julia> @chain dt(db, :nt) begin 
        @unnest_wider data  
        @unnest_longer a b 
        @collect
       end
7×3 DataFrame
 Row │ id     a        b     
     │ Int32  Int32?   Int32 
─────┼───────────────────────
   1 │     1        1      3
   2 │     1        2      4
   3 │     2        5      7
   4 │     2        6      8
   5 │     2  missing      9
   6 │     3       10     12
   7 │     3       11     13

julia> @chain dt(db, :nt) begin 
        @unnest_wider data  
        @unnest_longer a:b 
        @collect
       end
7×3 DataFrame
 Row │ id     a        b     
     │ Int32  Int32?   Int32 
─────┼───────────────────────
   1 │     1        1      3
   2 │     1        2      4
   3 │     2        5      7
   4 │     2        6      8
   5 │     2  missing      9
   6 │     3       10     12
   7 │     3       11     13
```



<Badge type="info" class="source-link" text="source"><a href="github.com/TidierOrg/Tidier.jl" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Tidier.@unnest_wider-Tuple{Any, Vararg{Any}}' href='#Tidier.@unnest_wider-Tuple{Any, Vararg{Any}}'><span class="jlbinding">Tidier.@unnest_wider</span></a> <Badge type="info" class="jlObjectType jlMacro" text="Macro" /></summary>



```julia
@unnest_wider(df, columns, names_sep)
```


Unnest specified columns of arrays or dictionaries into wider format dataframe with individual columns.

**Arguments**
- `df`: A DataFrame.
  
- `columns`: Columns to be unnested. These columns should contain arrays, dictionaries, dataframes, or tuples. Dictionarys headings will be converted to column names.
  
- `names_sep`: An optional string to specify the separator for creating new column names. If not provided, defaults to `_`.
  

**Examples**

```julia
julia> df = DataFrame(name = ["Zaki", "Farida"], attributes = [
               Dict("age" => 25, "city" => "New York"),
               Dict("age" => 30, "city" => "Los Angeles")]);

julia> @chain df @unnest_wider(attributes) @relocate(name, attributes_city, attributes_age)
2×3 DataFrame
 Row │ name    attributes_city  attributes_age 
     │ String  String           Int64          
─────┼─────────────────────────────────────────
   1 │ Zaki    New York                     25
   2 │ Farida  Los Angeles                  30

julia> df2 = DataFrame(a=[1, 2], b=[[1, 2], [3, 4]], c=[[5, 6], [7, 8]])
2×3 DataFrame
 Row │ a      b       c      
     │ Int64  Array…  Array… 
─────┼───────────────────────
   1 │     1  [1, 2]  [5, 6]
   2 │     2  [3, 4]  [7, 8]

julia> @unnest_wider(df2, b:c, names_sep = "")
2×5 DataFrame
 Row │ a      b1     b2     c1     c2    
     │ Int64  Int64  Int64  Int64  Int64 
─────┼───────────────────────────────────
   1 │     1      1      2      5      6
   2 │     2      3      4      7      8


julia> a1=Dict("a"=>1, "b"=>Dict("c"=>1, "d"=>2)); a2=Dict("a"=>1, "b"=>Dict("c"=>1)); a=[a1;a2]; df=DataFrame(a);

julia> @chain df @unnest_wider(b) @relocate(a, b_c, b_d)
2×3 DataFrame
 Row │ a      b_c    b_d     
     │ Int64  Int64  Int64?  
─────┼───────────────────────
   1 │     1      1        2
   2 │     1      1  missing 

julia> a0=Dict("a"=>0, "b"=>0);  a1=Dict("a"=>1, "b"=>Dict("c"=>1, "d"=>2)); a2=Dict("a"=>2, "b"=>Dict("c"=>2)); a3=Dict("a"=>3, "b"=>Dict("c"=>3)); a=[a0;a1;a2;a3]; df3=DataFrame(a);

julia> @chain df3 @unnest_wider(b) @relocate(a, b_c, b_d)
4×3 DataFrame
 Row │ a      b_c      b_d     
     │ Int64  Int64?   Int64?  
─────┼─────────────────────────
   1 │     0  missing  missing 
   2 │     1        1        2
   3 │     2        2  missing 
   4 │     3        3  missing 

julia> df = DataFrame(x1 = ["one", "two", "three"], x2 = [(1, "a"), (2, "b"), (3, "c")])
3×2 DataFrame
 Row │ x1      x2       
     │ String  Tuple…   
─────┼──────────────────
   1 │ one     (1, "a")
   2 │ two     (2, "b")
   3 │ three   (3, "c")

julia> @unnest_wider df x2
3×3 DataFrame
 Row │ x1      x2_1   x2_2   
     │ String  Int64  String 
─────┼───────────────────────
   1 │ one         1  a
   2 │ two         2  b
   3 │ three       3  c
```


```julia
@unnest_wider(sql_query, column)
```


Unnests a nested column into wider format. This function takes a column containing nested structures (e.g., rows or arrays) and expands it into separate columns.

**Arguments**
- `sql_query`: The SQL query
  
- `column`: The column containing nested structures to be unnested.
  

**Examples**

```julia
julia> db = connect(duckdb());

julia> DuckDB.query(db, "
        CREATE TABLE df3 (
            id INTEGER,
            pos ROW(lat DOUBLE, lon DOUBLE)
        );
        INSERT INTO df3 VALUES
            (1, ROW(10.1, 30.3)),
            (2, ROW(10.2, 30.2)),
            (3, ROW(10.3, 30.1));");

julia> @chain dt(db, :df3) begin
            @unnest_wider(pos)
            @collect
       end
3×3 DataFrame
 Row │ id     lat      lon     
     │ Int32  Float64  Float64 
─────┼─────────────────────────
   1 │     1     10.1     30.3
   2 │     2     10.2     30.2
   3 │     3     10.3     30.1 
julia> @chain dt(db, :df3) begin
            @unnest_wider(pos, names_sep = "_")
            @collect
       end
3×3 DataFrame
 Row │ id     pos_lat  pos_lon 
     │ Int32  Float64  Float64 
─────┼─────────────────────────
   1 │     1     10.1     30.3
   2 │     2     10.2     30.2
   3 │     3     10.3     30.1
```



<Badge type="info" class="source-link" text="source"><a href="github.com/TidierOrg/Tidier.jl" target="_blank" rel="noreferrer">source</a></Badge>

</details>


## Reference - Internal functions {#Reference-Internal-functions}
