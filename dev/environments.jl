using Pkg
using TOML
using UUIDs: UUID

function selected_packages(arguments)
    length(arguments) == 3 || error("supply LocalMath, CorePotts and Potts checkout paths")
    paths = (arguments..., dirname(@__DIR__))
    identities = (
        ("LocalMath", "82808884-8acc-4a5c-a056-be440a0fbea1"),
        ("CorePotts", "047998c1-3edd-4edf-b561-cee99549c5a6"),
        ("Potts", "e4c62a4c-8889-4cc8-ad3a-75efc86c53b9"),
        ("PottsModels", "d96e602c-5c36-4c60-bc86-1ae31a2f1743"),
    )
    return map(paths, identities) do path, (name, uuid)
        project = joinpath(abspath(path), "Project.toml")
        isfile(project) || error("missing package Project.toml: $path")
        actual = TOML.parsefile(project)
        get(actual, "name", nothing) == name && get(actual, "uuid", nothing) == uuid ||
            error("expected $name ($uuid) at $path")
        (; name, uuid = UUID(uuid), path = realpath(path))
    end
end

function develop_selected!(selected)
    Pkg.develop([PackageSpec(; path = item.path) for item in selected])
    resolved = Pkg.dependencies()
    for item in selected
        info = get(resolved, item.uuid, nothing)
        info !== nothing && info.name == item.name &&
            realpath(info.source) == item.path ||
            error("resolved package does not match requested checkout: $(item.name)")
        println(item.name, ": ", info.source)
    end
    return nothing
end
