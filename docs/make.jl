push!(LOAD_PATH,"../src/")
println(LOAD_PATH)

using Documenter
using EQDSKReader

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
        "API" => "api.md",
    ],
)

deploydocs(;
    repo="github.com/dvp2015/EQDSKReader.jl",
    devbranch="main",
)


# generated with PkgTemplates
#== See also: 
- https://towardsdatascience.com/how-to-automate-julia-documentation-with-documenter-jl-21a44d4a188f

makedocs args:
root - Root will determine where the file-system root is for this project. This is equivalent to the top of the repository in Github, and most of the time is going to be "./"
source - Source is the directory of your source files from the root directory.
build - Build is the directory where you want Documenter to put your new HTML site from the root directory.
clean - This is a boolean that will determine whether or not Documenter is going to clean the build after finishing.
doctest - Doc test is another boolean that will determine whether or not Documenter will let you know of any problems with your module's docstrings, e.g. undocumented functions.
modules - These are the modules that we imported before, they will be put into a list here for Documenter to process.
repo - Repo will determine where your " edit on github" link will go. We will be ignoring this for now.
sitename - Just a name for your site, this will appear in the title of your HTML document, as well as the upper left-hand corner of the default style documentation site.
expandfirst - This parameter will take a page and expand it in the left side context menu. I usually leave this blank, as your current page will always be expanded.
pages - This will be a mapped dictionary of all your documentation files (e.g. index.md) and their corresponding titles. The titles will fill into the menu (on the left with the default style.)
==#