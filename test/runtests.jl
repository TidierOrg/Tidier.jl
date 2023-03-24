module TestTidier

using Tidier
using Test
using Documenter

DocMeta.setdocmeta!(Tidier, :DocTestSetup, :(using Tidier); recursive=true)

doctest(Tidier)

end
