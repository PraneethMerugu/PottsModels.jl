using Test
using PottsModels
using Potts: PottsProblem, SequentialCPM, CPUBackend
using SciMLBase: solve, ReturnCode
using Aqua
using ExplicitImports

include("test_developer_environment.jl")

function trajectory(factory, scalar_type, observable; seed = 0x3302)
    model = factory()
    problem = PottsProblem(model.system, model.initial, (0, 2); seed)
    return solve(
        problem, SequentialCPM(); backend = CPUBackend(), scalar_type,
        save_everystep = true, observables = (observable,)
    )
end

@testset "bounded model factories" begin
    for (factory, scalar, observable, seed) in (
            (wortel_migration, Float32, :occupied_sites, 0x3302),
            (merks_vasculogenesis, Float64, :field_snapshot, 0x3303),
            (openvt_monolayer, Float64, :tissue_sites, 0x3306),
        )
        @testset "$(factory)" begin
            first_run = trajectory(factory, scalar, observable; seed)
            replay = trajectory(factory, scalar, observable; seed)
            @test first_run.retcode == ReturnCode.Success
            @test replay.retcode == ReturnCode.Success
            @test last(first_run).mcs == 2
            @test [s.ownership for s in first_run] == [s.ownership for s in replay]
            @test [s[observable] for s in first_run] == [s[observable] for s in replay]
            different_seed = trajectory(factory, scalar, observable; seed = seed + 1)
            @test different_seed.retcode == ReturnCode.Success
            @test [s.ownership for s in first_run] != [s.ownership for s in different_seed]

            # Reusing one declaration/initializer after a solve cannot inherit runtime state.
            model = factory()
            problem = PottsProblem(model.system, model.initial, (0, 2); seed)
            solve(problem, SequentialCPM(); backend = CPUBackend(), scalar_type = scalar)
            fresh_problem = PottsProblem(model.system, model.initial, (0, 2); seed)
            reused = solve(
                fresh_problem, SequentialCPM(); backend = CPUBackend(),
                scalar_type = scalar, save_everystep = true, observables = (observable,)
            )
            @test [s.ownership for s in reused] == [s.ownership for s in first_run]
            @test [s[observable] for s in reused] == [s[observable] for s in first_run]
        end
    end

    activity = last(trajectory(wortel_migration, Float32, :occupied_sites))
    @test all(isfinite, activity[:activity])
    @test 0 <= minimum(activity[:activity]) <= maximum(activity[:activity]) <= 5
    @test last(activity[:activity_history]) == activity[:activity]
    @test activity[:occupied_sites] == count(!iszero, activity.ownership)

    field = last(trajectory(merks_vasculogenesis, Float64, :field_snapshot; seed = 0x3303))
    @test all(isfinite, field[:concentration])
    @test sum(field[:concentration]) > 0
    @test field[:field_snapshot] == field[:concentration]

    monolayer = last(trajectory(openvt_monolayer, Float64, :tissue_sites; seed = 0x3306))
    @test monolayer[:tissue_sites] == count(!iszero, monolayer.ownership)
    @test !isempty(classify_surface(monolayer.ownership).states)
end

@testset "surface diagnostics and scalar calibration" begin
    @test exposed_neighbor_fraction(zeros(Int, 2, 2), 1) == 0
    @test exposed_neighbor_fraction(fill(1, 2, 2), 1) == 0.5
    @test exposed_neighbor_fraction([1 2; 1 2], 1) == 0.75
    @test classify_surface(zeros(Int, 2, 2)).states == Symbol[]
    @test classify_surface(fill(1, 2, 2)).states == [:crowded]
    @test_throws ArgumentError classify_surface(fill(1, 2, 2); gamma = 0.9, beta = 0.2)
    @test relaxation_steps() == 11
    @test_throws ErrorException relaxation_steps(; maximum_steps = 1)
end

@testset "package quality" begin
    # Aqua's fresh-project persistent-task check cannot resolve unregistered,
    # path-developed upstream packages. Ordinary selected-environment
    # precompilation and loading are exercised by the developer/CI setup.
    Aqua.test_all(PottsModels; persistent_tasks = false)
    ExplicitImports.test_explicit_imports(PottsModels)
end
