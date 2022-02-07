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
https://github.com/LilithHafner/FBDCompare.jl/runs/4221035425?check_suite_focus=true
Traceback (most recent call last):
  File "hyper_preferential_attachment.py", line 8, in <module>
    import numpy as np
ModuleNotFoundError: No module named 'numpy'
=#  else
        HyperPA.external()
    end
    @test true
end

@test FBDCompare.hypergraphsize((Dict{Int64, Dict}(4 => Dict{Vector{Int64}, Int64}(), 2 => Dict([2, 4] => 1, [2, 6] => 1, [7, 7] => 1), 3 => Dict([5, 6, 6] => 1, [6, 6, 6] => 1), 1 => Dict([3] => 1, [7] => 1)), 1:7)) == 14

FBDCompare.save_figures()
