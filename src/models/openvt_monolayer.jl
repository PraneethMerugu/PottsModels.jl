"""
    openvt_monolayer()

Bounded 12×8 monolayer with volume/contact energy and scheduled division. Returns fresh declarations and initialization without solving. Surface classification is postprocessing, not a growth or division control law.
"""
function openvt_monolayer()
    @variables division_mass
    @parameters begin
        target_volume = 8.0
        volume_strength = 2.0
        temperature = 2.0
        division_threshold = 8.0
    end
    tissue = CellKind(:tissue; extinction = RetireAtZero())
    medium = MediumKind(:medium)
    division_relation = SpatialRelation(:division; neighborhood = VonNeumann())
    mass = CellState(
        division_mass; initial = 8.0, retirement = RetireTo(0.0),
        division = SplitConservatively(0.5; rounding = :exact)
    )
    anchor = CellBinding(:dividing_cell)
    divide = LifecycleProcess(
        :openvt_division;
        domain = cells(tissue),
        anchor,
        expression = cell_volume(anchor) >= division_threshold,
        effects = (
            Divide(
                anchor;
                geometry = SpecifiedNormalPlane((1.0, 0.0)),
                relation = division_relation,
                side = CanonicalSide(),
                state = (mass => SplitConservatively(0.5; rounding = :exact),),
                on_inadmissible = ErrorOnInadmissible(),
            ),
        ),
        cadence = AtMCS(1),
    )
    system = PottsSystem(
        name = :openvt_monolayer,
        statements = StatementSet(
            (
                Lattice(
                    (12, 8); boundary = Closed(), max_cells = 8,
                    relations = (proposal = Moore(), contact = Moore())
                ),
                tissue,
                medium,
                division_relation,
                mass,
                Volume(tissue; target = target_volume, strength = volume_strength),
                ContactEnergy(
                    [
                        (tissue ↔ tissue) => 0.0,
                        (medium ↔ tissue) => 4.0,
                    ]
                ),
                divide,
                Protocol(Sweep(; temperature); name = :main),
                Observation(:tissue_sites, occupancy(tissue, :lattice)),
            )
        ),
        unknowns = [division_mass],
        parameters = [target_volume, volume_strength, temperature, division_threshold],
    )
    labels = zeros(Int32, 12, 8)
    labels[5:8, 4:5] .= 1
    initial = PottsInitialState(
        ownership = LabelledCells(
            labels; cells = [tissue], medium
        ), values = (division_mass => [8.0],)
    )
    return (; system, initial, quantities = (; division_mass))
end
