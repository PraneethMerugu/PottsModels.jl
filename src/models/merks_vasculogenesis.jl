"""
    merks_vasculogenesis()

Field-coupled vasculogenesis on an 8×8 closed lattice. Returns fresh declarations and initialization without solving. This bounded example is not a calibrated reproduction of Merks et al. (2006).
"""
function merks_vasculogenesis()
    @variables concentration
    @parameters begin
        target_volume = 6.0
        volume_strength = 1.0
        chemotaxis_strength = 2.0
        diffusion = 0.08
        secretion = 0.02
        decay = 0.01
        temperature = 6.0
    end

    endothelial = CellKind(:endothelial; extinction = RetireAtZero())
    extracellular = MediumKind(:extracellular)
    field = FieldState(
        concentration;
        name = :concentration,
        initial = 0.0,
        evolution = DiscreteFieldEuler(),
        diffusion,
        secretion,
        decay,
        substeps = 2,
        duration_per_mcs = 1.0,
        source_kind = endothelial,
        stencil = :field_stencil,
    )
    system = PottsSystem(
        name = :merks_2006,
        statements = StatementSet(
            (
                Lattice(
                    (8, 8);
                    boundary = Closed(),
                    relations = (
                        proposal = Moore(),
                        connectivity = Moore(),
                        connectivity_background = VonNeumann(),
                        field_stencil = VonNeumann(),
                    ),
                ),
                endothelial,
                extracellular,
                field,
                Volume(endothelial; target = target_volume, strength = volume_strength),
                Chemotaxis(
                    endothelial,
                    field;
                    strength = chemotaxis_strength,
                    mode = ExtensionsOnly(),
                    sample = Nearest(),
                ),
                LocalConnectivity(endothelial),
                Protocol(Sweep(; temperature); name = :main),
                Observation(:field_snapshot, concentration),
            )
        ),
        unknowns = [concentration],
        parameters = [
            target_volume,
            volume_strength,
            chemotaxis_strength,
            diffusion,
            secretion,
            decay,
            temperature,
        ],
    )
    labels = zeros(Int32, 8, 8)
    labels[3:5, 3:5] .= 1
    initial = PottsInitialState(
        ownership = LabelledCells(
            labels;
            cells = [endothelial],
            medium = extracellular,
        ),
        values = (concentration => zeros(Float64, 8, 8),),
    )
    return (; system, initial, quantities = (; concentration))
end
