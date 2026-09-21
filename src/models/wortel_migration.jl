"""
    wortel_migration()

Activity-coupled migration on an 8×8 periodic lattice. Returns fresh model declarations and initialization without solving. This bounded example is not a calibrated reproduction of Wortel et al. (2021).
"""
_wortel_geometric_finish(total, count) = exp(total / count)

function _wortel_local_activity(activity, lane, anchor, owner)
    values = gather(
        site_value(activity, lane);
        bind = lane,
        at = anchor,
        over = :act_neighbors,
        where = site_owner(lane) == owner,
    )
    return LocalMath.fold(values;
        map = log,
        combine = +,
        init = 0.0,
        finish = _wortel_geometric_finish,
        domain = >=(0.0),
        invalid = :reject,
        empty = 0.0,
        order = :canonical,
    )
end

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
    lane = SiteBinding(:act_neighbor)
    surface_anchor = CellBinding(:surface_anchor)
    source_activity = _wortel_local_activity(
        activity, lane, copy.source_site, copy.source_cell)
    target_activity = _wortel_local_activity(
        activity, lane, copy.target_site, copy.target_cell)
    inverse_maximum_activity = exp(-log(maximum_activity))
    act_drive = -(activity_strength * inverse_maximum_activity) * (
        ifelse(kind_matches(copy.source_kind, endothelial), source_activity, 0.0) -
        ifelse(kind_matches(copy.target_kind, endothelial), target_activity, 0.0)
    )

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
                        act_neighbors = Moore(; include_center = true),
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
                ProposalDrive(
                    :activity_drive, act_drive; drive_scale = :energy
                )
                AcceptedCopy(
                    :activate,
                    Assign(activity_value, maximum_activity);
                    when = kind_matches(copy.source_kind, endothelial),
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
