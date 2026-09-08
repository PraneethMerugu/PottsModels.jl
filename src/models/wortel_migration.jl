"""
    wortel_migration()

Activity-coupled migration on an 8×8 periodic lattice. Returns fresh model declarations and initialization without solving. This bounded example is not a calibrated reproduction of Wortel et al. (2021).
"""
function wortel_migration()
    @variables activity_value activity_history
    @parameters begin
        target_volume = 6.0
        volume_strength = 1.0
        maximum_activity = 5.0
        activity_strength = 4.0
        temperature = 8.0
    end

    endothelial = CellKind(:endothelial; extinction = RetireAtZero())
    extracellular = MediumKind(:extracellular)
    activity = SiteState(
        activity_value;
        name = :activity,
        owner = endothelial,
        initial = 0.0,
        lifecycle = ClearOnOwnershipChange(),
    )
    memory = HistoryState(
        activity_history;
        name = :activity_history,
        initial = 0.0,
        of = activity_value,
        depth = 2,
        cadence = EveryMCS(),
    )
    copy = ProposalContext(:copy)
    surface_anchor = CellBinding(:surface_anchor)

    system = PottsSystem(
        name = :wortel_2021,
        statements = (
            @statements begin
                Lattice(
                    (8, 8);
                    boundary = Periodic(),
                    relations = (
                        proposal = Moore(),
                        contact = Moore(),
                        surface = Moore(),
                        activity_neighborhood = Moore(),
                        connectivity = Moore(),
                        connectivity_background = VonNeumann(),
                    ),
                )
                endothelial
                extracellular
                Volume(endothelial; target = target_volume, strength = volume_strength)
                ContactEnergy(
                    [
                        (extracellular ↔ endothelial) => 6.0,
                        (endothelial ↔ endothelial) => 2.0,
                    ]
                )
                HamiltonianTerm(
                    :surface_constraint;
                    domain = cells(endothelial),
                    anchor = surface_anchor,
                    expression = 0.05 * (cell_surface(surface_anchor) - 8.0)^2,
                )
                activity
                memory
                ActEnergy(
                    endothelial,
                    activity_value;
                    maximum = maximum_activity,
                    strength = activity_strength,
                    reduction = :activity_neighborhood,
                )
                AcceptedCopy(
                    :activate,
                    Assign(activity_value, maximum_activity);
                    when = copy.is_extension,
                )
                Synchronous(
                    :decay,
                    Assign(activity_value, max(activity_value - 1, 0));
                    phase = AfterMCS(),
                )
                LocalConnectivity(endothelial)
                Protocol(Sweep(; temperature); name = :main)
                Observation(:occupied_sites, occupancy(endothelial, :lattice))
            end
        ),
        unknowns = [activity_value, activity_history],
        parameters = [
            target_volume,
            volume_strength,
            maximum_activity,
            activity_strength,
            temperature,
        ],
    )
    labels = zeros(Int32, 8, 8)
    labels[2:3, 2:3] .= 1
    labels[6:7, 6:7] .= 2
    initial = PottsInitialState(
        ownership = LabelledCells(
            labels;
            cells = [endothelial, endothelial],
            medium = extracellular,
        ),
        values = (activity_value => zeros(Float32, 8, 8),),
    )
    return (; system, initial, quantities = (; activity_value, activity_history))
end
