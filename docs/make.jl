using Documenter
using PottsModels

makedocs(;
    modules = [PottsModels],
    sitename = "PottsModels.jl",
    remotes = nothing,
    format = Documenter.HTML(; prettyurls = false, edit_link = nothing, repolink = nothing),
    pages = [
        "Start here" => "index.md", "Build a model" => "building.md",
        "Activity migration" => "wortel.md", "Vasculogenesis" => "merks.md",
        "Monolayer division" => "openvt.md", "API" => "api.md",
    ],
    checkdocs = :exports,
    doctest = true,
)
