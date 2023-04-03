module TestTidier

using Tidier
using Test
using Documenter
using DataFrames

DocMeta.setdocmeta!(Tidier, :DocTestSetup, :(using Tidier); recursive=true)

doctest(Tidier)

@testset "type conversions" begin
    conversion_test = DataFrame(
        non_floats = ["1.0", "2", "hello", 1, 2.0],
        non_ints = ["1", "1.0", "hello", 1.5, 2.0],
        non_strings = ["1", "1.0", "hello", 1, 2.0]
    )

    conversion_truth = DataFrame(
        non_floats = [1.0, 2.0, missing, 1.0, 2.0],
        non_ints = [1, missing, missing, missing, 2],
        non_strings = ["1", "1.0", "hello", "1", "2.0"]
    )

    conversion_test = @chain conversion_test begin
        @mutate(non_floats = as_float(non_floats))
        @mutate(non_ints = as_integer(non_ints))
        @mutate(non_strings = as_string(non_strings))
    end

    res = isequal.(conversion_test, conversion_truth)

    @test all(res.non_floats)
    @test all(res.non_ints)
    @test all(res.non_strings)
end


end