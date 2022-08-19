using FBDCompare
using Test

if true#("CI"=>"true") ∈ ENV # a proxy for "are we missing python dependencies?"
    @testset "HyperPA before install" begin
        @test FBDCompare.hypergraphsize(FBDCompare.new_hyperpa()) > 10_000
        @test FBDCompare.new_hyperpa_python() == [[1]] # Does not blow up,
        @test FBDCompare.old_hyperpa() == [[1]] # but returns a dummy graph
    end

    run(`pip3 install numpy scipy argparse`)
end

@testset "HyperPA" begin
    @test FBDCompare.hypergraphsize(FBDCompare.new_hyperpa()) > 10_000
    @test FBDCompare.hypergraphsize(FBDCompare.old_hyperpa()) > 10_000
    @test FBDCompare.hypergraphsize(FBDCompare.new_hyperpa_python()) > 10_000
end

@testset "hypergraphsize" begin
    @test FBDCompare.hypergraphsize((Dict{Int64, Dict}(4 => Dict{Vector{Int64}, Int64}(), 2 => Dict([2, 4] => 1, [2, 6] => 1, [7, 7] => 1), 3 => Dict([5, 6, 6] => 1, [6, 6, 6] => 1), 1 => Dict([3] => 1, [7] => 1)), 1:7)) == 14
end

@testset "end to end" begin
    FBDCompare.SCALE[] = 0
    FBDCompare.make_figure_0()
    FBDCompare.save_figures() # figures 1-6
end

@testset "mock tests" begin
    @eval function FBDCompare.datapoint(_, target_size)
        size = round(Int, target_size*(rand() + .5))
        time = size * (rand() + .5) * 1e-8
        size, time, :banana
    end
    @eval function FBDCompare.datapoint(_, target_size, target_density)
        size = round(Int, target_size*(rand() + .5))
        time = size * (rand() + .5) * 1e-8
        density = target_density + randn()
        size, time, density
    end

    # Note: missing figure 0 at scales 1 and 2.
    FBDCompare.SCALE[] = 0
    FBDCompare.save_figures()
    FBDCompare.SCALE[] = 1
    FBDCompare.save_figures()
    FBDCompare.SCALE[] = 2
    FBDCompare.save_figures()
end
