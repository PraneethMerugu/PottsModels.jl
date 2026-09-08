# Field-coupled vasculogenesis

The Merks-inspired model uses an 8×8 closed lattice. Occupancy-driven secretion,
diffusion and decay use the explicitly named `DiscreteFieldEuler()` policy
with two substeps per MCS; chemotaxis, volume energy and connectivity govern CPM.

The moving occupancy source is part of the law. Replacing it with a static mask
or an output-only PDE adapter would change that law. A future native PDE adapter
must support the complete input/output coupling before replacing this stencil.
This example does not establish a generic PDE solver or reproduce network,
lacuna, branching or remodeling statistics.

```@example merks
using PottsModels
include(joinpath(pkgdir(PottsModels), "tutorials", "merks_vasculogenesis.jl"))
```

The saved observation is checked against the concentration field in the model
tests. Execution here is sequential CPU with Float64.
