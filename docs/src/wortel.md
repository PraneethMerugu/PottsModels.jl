# Activity-coupled migration

The Wortel-inspired bounded model uses an 8×8 periodic lattice with Moore
relations, volume/contact/surface energies, local connectivity and per-site
activity. Its proposal drive is composed from a lane-bound `SiteState` gather,
an exact-owner predicate, and a canonical `LocalMath.fold` implementing the raw
geometric mean over the center-inclusive Moore neighborhood. Every accepted
copy from the modeled cell kind activates the copied site; completed-MCS decay
and retained history age it; ownership changes clear it.

These are CPM event and spatial-identity semantics. A per-cell ODE would not
preserve the per-site distribution or accepted-copy trigger. The model does
not reproduce a calibrated speed–persistence campaign.

```@example wortel
using PottsModels
include(joinpath(pkgdir(PottsModels), "tutorials", "wortel_migration.jl"))
```

Execution here is sequential CPU with Float32. GPU and 3D support are not
established by this example.
