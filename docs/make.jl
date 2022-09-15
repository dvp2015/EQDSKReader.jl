using EQDSKReader
using Documenter

DocMeta.setdocmeta!(EQDSKReader, :DocTestSetup, :(using EQDSKReader); recursive=true)

makedocs(;
    modules=[EQDSKReader],
    authors="dvp2015 <dmitri_portnov@yahoo.com>",
    repo="https://github.com/dvp2015/EQDSKReader.jl/blob/{commit}{path}#{line}",
    sitename="EQDSKReader.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://dvp2015.github.io/EQDSKReader.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/dvp2015/EQDSKReader.jl",
    devbranch="main",
)
