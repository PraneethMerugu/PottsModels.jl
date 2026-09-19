using Documenter
using PottsModels

include(joinpath(dirname(@__DIR__), "dev", "ci_telemetry.jl"))
using .CITelemetry: record_duration

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
