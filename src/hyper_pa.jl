module HyperPA

using FBD
using BenchmarkTools

function data()
    joinpath(@__DIR__, "..", "data", "hyper_pa")
end

function params(name, nodes)
    edgesize_distribution = FBD.read_probabilities(joinpath(source(), "size distribution", name * " size distribution.txt"))
    degree_distribution = FBD.read_probabilities(joinpath(source(), "simplex per node", name * "-simplices-per-node-distribution.txt"))
    max_edgesize = findlast(edgesize_distribution.accept .> 0)
    degree_distribution, edgesize_distribution, max_edgesize, nodes
end

"""
    jl_with_io(name="DAWN", nodes=3029)

Load probabilities from disk, generate a graph via FBD, save the graph to disk,
and return it.
"""
function jl_with_io(name="DAWN", nodes=3029)
    ps = params(name, nodes)
    graph = hyper_pa(ps...)
    FBD.write_graph(joinpath(data(), "julia", name * ".txt"), graph)
    graph
end

"""
    jl_benchmark(name="DAWN", nodes=3029)

Benchmark the FBD implementation (skip disk IO) and return runtime in seconds
"""
function jl_benchmark(name="DAWN", nodes=3029)
    ps = params(name, nodes)
    m = @benchmark graph = hyper_pa($ps...)
    display(m)
    time(median(m))/1e9
end

"""
    jl_profile(name="DAWN", nodes=3029, runs=20)

Repeatedly run the FBD implementation (skip disk IO). Good for profiling.
"""
function jl_profile(name="DAWN", nodes=3029, runs=20)
    ps = params(name, nodes)
    for i in 1:runs; graph = hyper_pa(ps...); end
end

"""
    external(name="DAWN", nodes=200)

Run the external implementation.
"""
function external(name="DAWN", nodes=200)
    printstyled("expected runtime on the order of $(round(Integer, (nodes/200)^2)) minute(s)\n", color=Base.warn_color())
    output_directory = joinpath(data(), "external")
    @elapsed cd(source()) do
        run(`python3 hyper_preferential_attachment.py --name=$name --file_name=$name --num_nodes=$nodes --simplex_per_node_directory='simplex per node' --size_distribution_directory='size distribution' --output_directory=$output_directory`)
    end
end

#= at default size:
x@X Generator % time python3 hyper_preferential_attachment.py --name=DAWN --file_name=DAWN --num_nodes=3029 --simplex_per_node_directory='simplex per node' --size_distribution_directory='size distribution' --output_directory=output_directory
done with DAWN
python3 hyper_preferential_attachment.py --name=DAWN --file_name=DAWN      22469.39s user 1842.45s system 93% cpu 7:14:08.42 total
x@X Generator %
=#

end
