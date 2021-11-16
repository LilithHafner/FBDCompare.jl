using Pkg
Pkg.add(url="https://github.com/LilithHafner/FBD")

using FBDCompare
using Test

@testset "Kronecker" begin
    Kronecker.plot()
    @test true
end

@testset "HyperPA" begin
    HyperPA.jl_benchmark()
    HyperPA.jl_profile()
    HyperPA.jl_with_io()
    HyperPA.external()
    @test true
end
