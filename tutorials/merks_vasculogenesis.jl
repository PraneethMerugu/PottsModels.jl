using PottsModels: merks_vasculogenesis
using Potts: PottsProblem, SequentialCPM, CPUBackend
using SciMLBase: solve, ReturnCode

# The factory assembles scientific declarations; execution remains your choice.
model = merks_vasculogenesis()
problem = PottsProblem(model.system, model.initial, (0, 2); seed = 0x3303)
solution = solve(
    problem, SequentialCPM(); backend = CPUBackend(),
    scalar_type = Float64, save_everystep = true, observables = (:field_snapshot,)
)
@assert solution.retcode == ReturnCode.Success
final = last(solution)
(; mcs = final.mcs, observation = final[:field_snapshot])
