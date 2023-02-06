using .Tidier
using Test

using DataFrames: DataFrame
# using DataFramesMeta
using Chain
using Statistics

df = DataFrame(a = 1:10, b = 11:20)

@select(df, :a)

@macroexpand @autovec(1+1)

@testset "Tidier.jl" begin
  # Write your tests here.
end
