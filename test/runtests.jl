module TestTidier

using Tidier
using Test
using DataFrames
using Chain
using Statistics
using Documenter

DocMeta.setdocmeta!(Tidier, :DocTestSetup, :(using Tidier, DataFrames, Chain, Statistics); recursive=true)

doctest(Tidier)

end