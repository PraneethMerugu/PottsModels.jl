using PottsModels: wortel_migration
using Potts: PottsProblem, SequentialCPM, CPUBackend
using SciMLBase: solve, ReturnCode

# The factory assembles scientific declarations; execution remains your choice.
model = wortel_migration()
problem = PottsProblem(model.system, model.initial, (0, 2); seed = 0x3302)
solution = solve(
    problem, SequentialCPM(); backend = CPUBackend(),
    scalar_type = Float32, save_everystep = true, observables = (:occupied_sites,)
)
@assert solution.retcode == ReturnCode.Success
final = last(solution)
(; mcs = final.mcs, observation = final[:occupied_sites])
