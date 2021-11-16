using Pkg
Pkg.add(url="https://github.com/LilithHafner/FBD")

using FBDCompare
using Test

ci = ("CI"=>"true") ∈ ENV
gui = !ci

@testset "Kronecker" begin
    if gui
        Kronecker.plot()
    else
        Kronecker.generate_data()
        @test_broken false
    end
    @test true
end

@testset "HyperPA" begin
    HyperPA.jl_benchmark()
    HyperPA.jl_profile()
    HyperPA.jl_with_io()
    HyperPA.external()
    @test true
end
