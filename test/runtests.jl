module TestTidier

using Tidier
using Test
using DataFrames
using Chain
using Statistics

@testset "select" begin
  test_df = DataFrame(a = 1:10, b = 11:20)

  dataframes = select(test_df, :a)

  tidier_by_name = @select(test_df, a)
  tidier_by_number = @select(test_df, 1)

  @test isequal(tidier_by_name, dataframes)
  @test isequal(tidier_by_number, dataframes)

end

@testset "mutate" begin
  test_df = DataFrame(a = 1:10, b = 11:20)

  dataframes = transform(test_df, :a => (x -> (x .+ 1)) => :c)

  tidier = @mutate(test_df, c = a + 1)

  @test isequal(tidier, dataframes)

end

@testset "left_join" begin
  df1 = DataFrame(id = [1,2,3], val1 = ["A", "B", "C"])
  df2 = DataFrame(id = [1,2,3], val2 = ["D", "E", "F"])
  df3 = DataFrame(employee_id = [1,2,3], val3 = ["G", "H", "I"])  

  @test isequal(@left_join(df1, df2, :id), leftjoin(df1, df2, on = :id))
  @test isequal(@left_join(df1, df2), leftjoin(df1, df2, on = :id))
  @test isequal(@left_join(df1, df2, @join_by("id")), leftjoin(df1, df2, on = :id))
  @test isequal(leftjoin(df1, df3, on = :id => :employee_id),
                @left_join(df1, df3, @join_by("id" == "employee_id")))
end

end

#
#@chain df2 begin
#  @autovec("select", a, b = b + 1)
#end
#
#@chain df2 begin
#  @select(a:b)
#  @mutate(c = a + b)
#  @rename(d = b)
#end
#
#@chain df2 begin
#  @summarize(n = length(a))
#end
#
#
#@chain df2 begin
#  @autovec("select", a)
#end
#
#@test_macro(df2, a)
#
#@chain df2 begin
#  @test_macro(a)
#end
#
#@autovec(df2, "groupby", a)
#
#@chain df2 begin
#  @autovec("groupby", a)
#end
#
#@macroexpand @chain df2 begin
#  @select(a)
#end
#
#
#@select(df2, a)
#
#@mutate(df, c = a + b)
## DataFramesMeta.@transform(df, :c = :a + :b)
## DataFramesMeta.@transform(df, :c = (+).(:a, :b))
# #DataFramesMeta.@transform(df, :c = @autovec(:a + :b))
## DataFramesMeta.@transform(df, @autovec(c = a + b))
## DataFramesMeta.@transform(df, @autovec(:c = :a + :b))
#
#transform(df, [:a,:b] => function (a,b) @autovec(a + b - mean(a)) end => :c)
#
#SubString{String}["a", "b", "e"]
#
## need to remove "5" from list of variables by using regex below to detect
## valid variable names/ranges
#
#@autovec(df, "subset", a < b, a == b)
#@autovec(df, "select", b, a)
#@autovec(df, "rename", c = a)
#@autovec(df, "transform", c = a)
#@autovec(df, "transform", c = a + b, d = a - b)
#@autovec(df, "select", c = a + b, d = a - b)
#@autovec(df, "combine", c = sum(a), d = mean(b))
#@autovec(df, "groupby", a, b)
#@autovec(df, c = sum(a))
#
#test= ["a;b", "e", "mean(e);5", "(+).(a, b);(/).(mean(e), 5)"]
#split.(test[isnothing.(match.(r"[()]", test))], ";")
#test2 = split.(test[isnothing.(match.(r"[()]", test))], ";")
#reduce(vcat, test2)
#string("function (x, y, z) ", :(1 + 1 + a/mean(b)), " end") |> Meta.parse
#
## on the left side, take the last element of the vector (which is g)
## kw args will show up as earlier elements of the arr_lhs variable
#@expand @autovec(g = mean(b; p = "hi") - c)
#
## matches all valid variable names (but also mean, median, etc)
#match(r"[^\W0-9]\w*", "ß3")
#
## This will match all select statements, with and without negation, and with and without ranges
#match(r"(-?)\(?([^\W0-9]\w*?)(:?)([^\W0-9]\w*)?\)?", "-(a:b)")
#
## need 
#match.(r"(-?)\(?([^\W0-9]\w*?)(:?)([^\W0-9]\w*)?\)?", SubString{String}["a", "b", "e", "5"])
#
#a = @string_to_function("function (x,y,z) x + y + x end")
#a(1,2,3)
#
#
#function (reduce(vcat, test2))
#
#@macroexpand(@autovec(:c = :a + :b))
#
#
#
#