using Pkg
Pkg.add(url="https://github.com/LilithHafner/FBD")

using FBDCompare
using Test

ci = ("CI"=>"true") ∈ ENV

@testset "HyperPA" begin
    HyperPA.jl_benchmark()
    HyperPA.jl_profile()
    HyperPA.jl_with_io()
    if ci
        @test_broken false #=
Traceback (most recent call last):
  File "hyper_preferential_attachment.py", line 8, in <module>
    import numpy as np
ModuleNotFoundError: No module named 'numpy'
=#  else
        HyperPA.external()
    end
    @test true
end

@testset "hypergraphsize" begin
    @test FBDCompare.hypergraphsize((Dict{Int64, Dict}(4 => Dict{Vector{Int64}, Int64}(), 2 => Dict([2, 4] => 1, [2, 6] => 1, [7, 7] => 1), 3 => Dict([5, 6, 6] => 1, [6, 6, 6] => 1), 1 => Dict([3] => 1, [7] => 1)), 1:7)) == 14
end

#=@testset "end to end" begin
    FBDCompare.save_figures()
end=#
