"""
    relaxation_steps(; tolerance=0.9, stiffness=0.2, maximum_steps=200)

Steps for a scalar span relaxing from 8 to 10, represented by eleven positions.
This is a deterministic scalar calculation, not an eleven-cell CPM simulation.
"""
function relaxation_steps(; tolerance = 0.9, stiffness = 0.2, maximum_steps = 200)
    positions = collect(range(0.0, 8.0; length = 11))
    initial_span = positions[end] - positions[1]
    target_span = initial_span + tolerance * (10.0 - initial_span)
    for step in 1:maximum_steps
        span = positions[end] - positions[1]
        relaxed_span = span + stiffness * (10.0 - span)
        positions .= range(-relaxed_span / 2, relaxed_span / 2; length = 11)
        positions[end] - positions[1] >= target_span && return step
    end
    error("Scalar span calibration did not reach its bounded relaxation target")
end

"""
    exposed_neighbor_fraction(ownership, label)

Fraction of the four neighbors per occupied site that are outside the array
or carry another label. Other cells count as exposed, not only medium. Returns
zero for an absent label. Defined for a saved two-dimensional ownership array.
"""
function exposed_neighbor_fraction(ownership::AbstractMatrix, label)
    sites = findall(==(label), ownership)
    isempty(sites) && return 0.0
    exposed = 0
    total = 0
    for site in sites, offset in (
                CartesianIndex(-1, 0), CartesianIndex(1, 0),
                CartesianIndex(0, -1), CartesianIndex(0, 1),
            )
        neighbor = site + offset
        total += 1
        if !checkbounds(Bool, ownership, neighbor) || ownership[neighbor] != label
            exposed += 1
        end
    end
    return exposed / total
end


"""
    classify_surface(ownership; beta=0.8, gamma=0.2)

Classify occupied labels by their exposed-neighbor fraction in a saved 2D array.
All non-self neighbors, including other cells and out-of-bounds neighbors,
count as exposed; the denominator is four times occupied sites. This diagnostic
does not feed back into the model's growth or division.
"""
function classify_surface(ownership; beta::Real = 0.8, gamma::Real = 0.2)
    0 <= gamma <= beta <= 1 || throw(ArgumentError("require 0 ≤ gamma ≤ beta ≤ 1"))
    labels = filter(!iszero, unique(ownership))
    fractions = [exposed_neighbor_fraction(ownership, label) for label in labels]
    states = map(fractions) do fraction
        fraction >= beta ? :growing : fraction <= gamma ? :contact_inhibited : :crowded
    end
    return (; labels, fractions, states)
end
