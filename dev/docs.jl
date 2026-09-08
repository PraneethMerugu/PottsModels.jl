include("environments.jl")

selected = selected_packages(ARGS)
# Resolve the declared documentation contract without writing sibling paths or
# dependency additions into the checked-in documentation project.
documentation = joinpath(dirname(@__DIR__), "docs")
mktempdir() do environment
    cp(joinpath(documentation, "Project.toml"), joinpath(environment, "Project.toml"))
    Pkg.activate(environment)
    develop_selected!(selected)
    Pkg.instantiate()
    include(joinpath(documentation, "make.jl"))
end
