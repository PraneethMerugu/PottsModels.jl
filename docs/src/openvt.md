# Bounded monolayer division

This 12×8 closed-lattice example has volume energy, zero cell–cell contact
energy, medium contact energy and specified-normal division at MCS 1. It uses
bounded cell capacity and conservative division-state splitting.

```@example openvt
using PottsModels
include(joinpath(pkgdir(PottsModels), "tutorials", "openvt_monolayer.jl"))
classification = classify_surface(final.ownership)
(; calibration_steps=relaxation_steps(), states=classification.states)
```

Important scientific limitations:

- `relaxation_steps` is a separate scalar span relaxation represented by eleven
  positions, not an eleven-cell CPM calibration.
- `classify_surface` operates on saved ownership. Its thresholds do not control
  growth or division.
- `exposed_neighbor_fraction` counts all non-self neighbors, including other
  cells and out-of-bounds neighbors, divided by four times occupied sites. It
  is not a medium-only boundary fraction.
- This does not reproduce a growing contact-inhibited tissue or a 10,000-cell
  GPU campaign.

The tutorial preserves the bounded existing mechanism and executes on
sequential CPU with Float64.
