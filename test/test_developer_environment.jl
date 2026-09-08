include(joinpath(dirname(@__DIR__), "dev", "environments.jl"))

@testset "explicit developer checkout selection" begin
    dependencies = Pkg.dependencies()
    paths = map(
        (
            "82808884-8acc-4a5c-a056-be440a0fbea1",
            "047998c1-3edd-4edf-b561-cee99549c5a6",
            "e4c62a4c-8889-4cc8-ad3a-75efc86c53b9",
        )
    ) do uuid
        dependencies[UUID(uuid)].source
    end
    selected = selected_packages(paths)
    @test map(item -> item.path, selected) ==
        realpath.((paths..., dirname(@__DIR__)))
    @test_throws ErrorException selected_packages(paths[1:2])
    @test_throws ErrorException selected_packages((paths[2], paths[1], paths[3]))
    @test_throws ErrorException selected_packages((paths[1], paths[2], dirname(@__DIR__)))
end
