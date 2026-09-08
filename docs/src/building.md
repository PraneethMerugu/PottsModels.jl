# Build a model

1. State the scientific law and its limitations before choosing declarations.
2. Put reusable construction in a plain function, returning the authored
   `system`, `initial`, and symbolic `quantities` needed by the caller.
3. Allocate new initializer arrays per call. Do not cache mutable global models.
4. Keep problem duration, seed, algorithm, precision, backend and saving policy
   in the calling tutorial or application.
5. Test both the scientific observations and repeated construction/execution.
   A passing short simulation is not evidence of calibrated paper reproduction.

The [activity tutorial](wortel.md) demonstrates the complete calling workflow.
Read `src/models/wortel_migration.jl` for a single-file declaration containing
the lattice, cell/medium kinds, volume/contact/surface energy, activity,
history, accepted-copy activation, decay, connectivity and initialization.
The field and division factories follow the same pattern.

Extend through public Potts declarations. Do not access CorePotts storage,
duplicate its stepping loop, or install packages from a factory. Model-specific
analysis consumes explicit saved observations and must disclose whether it is
postprocessing or a feedback law.

The current small factories intentionally have fixed scientific parameters.
For a new scientific variant, write a clearly named factory or expose explicit
scientific arguments and add its defending tests; do not hide structural changes
inside numerical parameter updates.
