using EQDSKReader
using Documenter

DocMeta.setdocmeta!(EQDSKReader, :DocTestSetup, :(using EQDSKReader); recursive=true)

makedocs(;
    modules=[EQDSKReader],
    authors="Dmitri Portnov <d.portnov@iterrf.ru>",
    repo="https://gitlab.iterrf.ru/dvp/EQDSKReader.jl/blob/{commit}{path}#{line}",
    sitename="EQDSKReader.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://dvp.github.io/EQDSKReader.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="gitlab.iterrf.ru/dvp/EQDSKReader.jl",
    devbranch="main",
)
