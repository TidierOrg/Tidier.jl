using Documenter, DocumenterVitepress
using Tidier, DataFrames, RDatasets

DocTestMeta = quote
    using Tidier, DataFrames, Chain, Statistics
end

DocMeta.setdocmeta!(Tidier,
    :DocTestSetup,
    DocTestMeta;
    recursive=true
)

pgs = [
    "Home" => "index.md",
    "Get Started" => ["Installation" => "installation.md", "A Simple Data Analysis" => "simple-analysis.md"],
    "API Reference" => "reference.md",
    "Changelog" => "news.md",
    "FAQ" => "faq.md",
    # "Contributing" => "contributing.md",
]

fmt  = DocumenterVitepress.MarkdownVitepress(
    repo = "https://github.com/camilogarciabotero/Tidier.jl",
    devurl = "dev",
    # deploy_url = "yourgithubusername.github.io/Tidier.jl.jl",
)

makedocs(;
    modules = [Tidier],
    authors = "Karandeep Singh et al.",
    repo = "https://github.com/camilogarciabotero/Tidier.jl",
    sitename = "Tidier.jl",
    format = fmt,
    pages= pgs,
    warnonly = true,
)

deploydocs(;
    repo = "https://github.com/camilogarciabotero/Tidier.jl",
    push_preview = true,
)

# makedocs(
#     modules=[Tidier],
#     clean=true,
#     doctest=true,
#     #format   = Documenter.HTML(prettyurls = get(ENV, "CI", nothing) == "true"),
#     sitename="Tidier.jl",
#     authors="Karandeep Singh et al.",
#     strict=[
#         :doctest,
#         :linkcheck,
#         :parse_error,
#         :example_block,
#         # Other available options are
#         # :autodocs_block, :cross_references, :docs_block, :eval_block, :example_block,
#         # :footnote, :meta_block, :missing_docs, :setup_block
#     ], 
#     checkdocs=:all, 
#     format=Markdown(),
#     draft=false,
#     build=joinpath(@__DIR__, "docs")
# )

# deploydocs(; repo="https://github.com/TidierOrg/Tidier.jl", push_preview=true,
#     deps=Deps.pip("mkdocs", "pygments", "python-markdown-math", "mkdocs-material",
#         "pymdown-extensions", "mkdocstrings", "mknotebooks",
#         "pytkdocs_tweaks", "mkdocs_include_exclude_files", "jinja2", "mkdocs-video"),
#     make=() -> run(`mkdocs build`), target="site", devbranch="main")
