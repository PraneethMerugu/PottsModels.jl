# Activity-coupled migration

The Wortel-inspired bounded model uses an 8×8 periodic lattice with Moore
relations, volume/contact/surface energies, local connectivity and per-site
activity. An accepted extension activates the copied site; completed-MCS decay
and retained history age it; ownership changes clear it.

These are CPM event and spatial-identity semantics. A per-cell ODE would not
preserve the per-site distribution or accepted-copy trigger. The model does
not reproduce a calibrated speed–persistence campaign.

```@example wortel
using PottsModels
Main.CITelemetry.record_duration("documentation.wortel"; kind="tutorial") do
    include(joinpath(pkgdir(PottsModels), "tutorials", "wortel_migration.jl"))
end
```

Execution here is sequential CPU with Float32. GPU and 3D support are not
established by this example.
