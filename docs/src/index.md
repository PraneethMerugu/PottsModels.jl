# PottsModels.jl

PottsModels owns complete scientific model declarations, initializers, analysis,
tutorials and model-level tests. Potts owns the authoring interface; CorePotts
owns scientific execution; LocalMath owns spatial/publication mathematics.
There is no second model executor in this package.

Start with [building a model](building.md), then run the activity, field or
division tutorial. All three use ordinary factory → problem → solve → saved
observation workflows. Each factory returns fresh `system`, `initial` and
`quantities`; it neither starts a simulation nor selects an algorithm/backend.

These are small 2D sequential CPU examples, not calibrated paper reproductions.
Changing algorithm, backend, dimensionality or solver does not inherit a
scientific or replay guarantee from these examples.
