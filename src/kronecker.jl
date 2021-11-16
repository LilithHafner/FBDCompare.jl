module Kronecker

export hyperkron_graph, kron_params

include("hyperkron.jl")

using FBD, DataFrames
using Plots: Plots, plot!

function datapoint(power)
    #external
    a = @elapsed A,hedges = hyperkron_graph(kron_params(0.99, 0.2, 0.3, 0.05), power)

    edge_count = length(hedges[1])#Int(floor(sum(kron_params(0.99, 0.2, 0.3, 0.05))^power))

    #internal non-allocating
    b = @elapsed sampler = Kronecker_sampler(kron_params(0.99, 0.2, 0.3, 0.05), power)
    c = @elapsed edges = rand(sampler, edge_count)

    @assert length(edges) == edge_count

    #internal allocating
    d = @elapsed sampler = Kronecker_sampler(kron_params(0.99, 0.2, 0.3, 0.05), power; space=edge_count÷100)
    e = @elapsed edges = rand(sampler, edge_count)

    @assert length(edges) == edge_count

    (power, edge_count, a,b+c,b,c,d+e,d,e)
end

function generate_data()
    df = DataFrame(:power=>Int[], :edge_count=>Int[],
        (name => Float64[] for name in [
            :ext,
            :int_na, :int_na_create, :int_na_sample,
            :int_a, :int_a_create, :int_a_sample])...)

    for power in 1:15
        push!(df, min.([datapoint(power) for trial in 1:3]...))
    end
    df
end

function plot(df=generate_data())
    #collect(zip([(power, min.([time_both(power) for trial in 1:3]...)...) for power in 1:15]...))
    Plots.plot(df.power, log10.(df.edge_count), label="edges (log10)", legend=(.15,.95), style=:dash, color=:black, title="runtime vs k")
    plot!(df.power, df.ext ./ df.edge_count * 1e6, label="external (μs per edge)")
    plot!(df.power, df.int_na ./ df.edge_count * 1e6, label="internal (μs per edge)")
    plot!(df.power, df.int_na_create ./ df.edge_count * 1e6, label="create sampler (μs per edge)")
    plot!(df.power, df.int_na_sample ./ df.edge_count * 1e6, label="sample (μs per edge)")
    plot!(df.power, df.int_a ./ df.edge_count * 1e6, label="allocating internal (μs per edge)")
    plot!(df.power, df.int_a_create ./ df.edge_count * 1e6, label="allocating create sampler (μs per edge)")
    plot!(df.power, df.int_a_sample ./ df.edge_count * 1e6, label="allocating sample (μs per edge)")
    #display(plot!(df.power, df[6] ./ df[6+3], style=:dot, color=:grey, label="ratio: small/allocating"))
    display(plot!(df.power, df.ext ./ df.int_na, style=:dot, color=:grey, label="ratio: external/internal"))

    Plots.plot(df.edge_count, df.ext, label="external", marker=:cirlce, legend=(.15,.95), title="runtime vs edges")
    plot!(df.edge_count, df.int_na, label="internal", marker=:cirlce)
    display(plot!(df.edge_count, df.int_a, label="allocating internal", marker=:cirlce))
    df
end

end
