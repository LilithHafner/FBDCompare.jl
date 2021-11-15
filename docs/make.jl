using FBDCompare
using Documenter

DocMeta.setdocmeta!(FBDCompare, :DocTestSetup, :(using FBDCompare); recursive=true)

makedocs(;
    modules=[FBDCompare],
    authors="Lilith Orion Hafner <60898866+LilithHafner@users.noreply.github.com> and contributors",
    repo="https://github.com/LilithHafner/FBDCompare.jl/blob/{commit}{path}#{line}",
    sitename="FBDCompare.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://LilithHafner.github.io/FBDCompare.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/LilithHafner/FBDCompare.jl",
    devbranch="main",
)
