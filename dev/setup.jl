include("environments.jl")

length(ARGS) == 4 || error(
    "usage: julia dev/setup.jl ENV LOCALMATH_CHECKOUT COREPOTTS_CHECKOUT POTTS_CHECKOUT"
)
selected = selected_packages(ARGS[2:4])
Pkg.activate(abspath(ARGS[1]))
develop_selected!(selected)
Pkg.add(["SciMLBase", "Test", "Aqua", "ExplicitImports"])
environment = dirname(Base.active_project())
println("Tests: julia --project=", environment, " -e 'using Pkg; Pkg.test(\"PottsModels\")'")
println("Docs: julia dev/docs.jl LOCALMATH_CHECKOUT COREPOTTS_CHECKOUT POTTS_CHECKOUT")
