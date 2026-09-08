# Contributing

Use Julia 1.12 or later. Supply explicit checkouts and a disposable development
environment; the helper does not clone, fetch, reset, select branches or modify
the global environment:

```sh
julia dev/setup.jl /tmp/models-dev /path/to/LocalMath.jl /path/to/CorePotts.jl /path/to/Potts.jl
julia --project=/tmp/models-dev -e 'using Pkg; Pkg.test("PottsModels")'
julia dev/docs.jl /path/to/LocalMath.jl /path/to/CorePotts.jl /path/to/Potts.jl
```

Ordinary environments use broad compatibility ranges, not committed manifests.
Exact replay claims require separately specified and directly tested profiles.
Both helpers verify the requested package identities and resolved source paths.
The documentation helper uses `docs/Project.toml`, including its compatibility
requirements, rather than building from the developer environment.

A model change includes its scientific assumptions, single-file declaration,
caller-owned execution tutorial, ordinary behavioral tests and nearest docs.
Package tests cover bounded model behavior and repeated execution; the strict
documentation build executes tutorial sources. Add independent scientific
oracles when introducing a new law. GPU claims require actual relevant hardware
and are not inferred from the current CPU examples.

One production owner per fact: this library assembles public declarations and
owns complete models, never Potts/CorePotts/LocalMath internals or another
executor. Replace implementations directly, with no chronology-named runtime
modes or compatibility forwarders. Preserve scientific behavior unless an
accepted decision changes it. Update tests and current docs in the same change.

Use Runic on touched Julia files. Before handoff, run the full package tests and
strict docs, then relevant cross-package tests for any changed boundary.
