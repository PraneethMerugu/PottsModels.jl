using PottsModels: openvt_monolayer
using Potts: PottsProblem, SequentialCPM, CPUBackend
using SciMLBase: solve, ReturnCode

# The factory assembles scientific declarations; execution remains your choice.
model = openvt_monolayer()
problem = PottsProblem(model.system, model.initial, (0, 2); seed = 0x3306)
solution = solve(
    problem, SequentialCPM(); backend = CPUBackend(),
    scalar_type = Float64, save_everystep = true, observables = (:tissue_sites,)
)
@assert solution.retcode == ReturnCode.Success
final = last(solution)
(; mcs = final.mcs, observation = final[:tissue_sites])
