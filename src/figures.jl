using Plots
using Unzip
using Random: shuffle!
using LaTeXStrings

## util
function datapoint(f, target_size, target_density=nothing)
    time = @elapsed g = if target_density === nothing
        f(round(Integer, target_size))
    else
        f(round(Integer, target_size), target_density)
    end
    size = hypergraphsize(g)
    density = log_density(g)
    size, time, density
end

exp_range(start, stop, points) = exp.(LinRange(log(start), log(stop), points))

function middles(y, x...)
    buckets = Dict()
    for (i, (yi, xi)) in enumerate(zip(y, zip(x...)))
        xi ∈ keys(buckets) || (buckets[xi] = [])
        push!(buckets[xi], (yi, i))
    end
    sort!([sort!(v)[Int((length(v)+1)/2)][2] for v in values(buckets)])
end

# Plotting functions
const DATA = [[] for _ in 1:6]
const COMPUTE = Ref(true)
const SCALE = Ref(0)
first_row_x = (
    xaxis = :log,
    #xlims = (10^.9, 10^8.6),
    xticks = (10.0 .^ (1:10), [L"\large\bf 10^{%$i}" for i in 1:10]),
)
first_row = (
    yaxis = :log10,
    xlabel = L"\textrm{\large\bf hypergraph size}",
    #ylabel = L"\textrm{\large\bf runtime (s)}",
    bottom_margin = 10Plots.px,
    guidefontsize = 14,
    #ylims = (10^-6.1, 10^-.9),
    fontfamily = "times",
    tickfontsize = 15,
    legendfontsize = 12,
    legend =:topleft,
    #grid = false,
    #markerstrokewidth = 0,
    markersize = 7,
    first_row_x...
    )

function make_figure_1()
    # 9s at SCALE[] = 0
    # 500s at SCALE[] = 2
    fs, target = unzip(shuffle!(vcat(
        [(new_dchsbm, t) for t in 10 .^ (1:.5:7.5+SCALE[])],
        [(old_dchsbm, t) for t in 10 .^ (1:.5:4.5+SCALE[])],
        repeat(vcat(
        [(new_dchsbm, t) for t in 10 .^ (1:.5:6.5+SCALE[])],
        [(old_dchsbm, t) for t in 10 .^ (1:.5:3.5+SCALE[])]), 10),
        repeat(
        [(new_dchsbm, t) for t in 10 .^ (1:.5:4+SCALE[]/2)], 1000))))

    if COMPUTE[]
        @time sizes, times, densities = unzip(datapoint.(fs, target))
        push!(DATA[1], (fs, target, sizes, times, densities))
    else
        fs, target, sizes, times, densities = last(DATA[1])
    end

    #display(scatter(sizes, densities, group=string.(fs) .* " density"; first_row_x...))

    I = middles(times, target, fs)
    scatter(sizes[I], times[I], group=string.(fs[I]); first_row...,
        labels = [L"\textrm{\large\bf FBD}" L"\textrm{\large\bf CVB}"],
        yticks = (10.0 .^ ((-5.0):5.0), [L"\large\bf 10^{%$i}" for i in -5:5]),)
end
function make_figure_2()
    # 15s at SCALE[] = 0
    fs, target = unzip(shuffle!(vcat(
        [(new_kronecker, t) for t in 10 .^ (1:.5:7.5+SCALE[])],
        [(old_kronecker, t) for t in 10 .^ (1:.5:6+SCALE[])],
        repeat(vcat(
        [(new_kronecker, t) for t in 10 .^ (1:.5:6.5+SCALE[])],
        [(old_kronecker, t) for t in 10 .^ (1:.5:5+SCALE[])]), 10),
        repeat(vcat(
        [(new_kronecker, t) for t in 10 .^ (1:.5:3.5+SCALE[]/2)],
        [(old_kronecker, t) for t in 10 .^ (1:.5:2+SCALE[]/2)]), 1000))))

    if COMPUTE[]
        @time sizes, times, densities = unzip(datapoint.(fs, target))
        push!(DATA[2], (fs, target, sizes, times, densities))
    else
        fs, target, sizes, times, densities = last(DATA[2])
    end

    #display(scatter(sizes, densities, group=string.(fs) .* " density"; first_row_x...))

    I = middles(times, target, fs)
    scatter(sizes[I], times[I], group=string.(fs[I]); first_row...,
        labels = [L"\textrm{\large\bf FBD}" L"\textrm{\large\bf ERG}"],
        yticks = (10.0 .^ ((-6.0):5.0), [L"\large\bf 10^{%$i}" for i in -6:5]),)
end

function make_figure_3()
    # 20s at SCALE[] = 0 (no old_hyperpa data points)
    # 32,000s at SCALE[] = 2
    fs, target = unzip(shuffle!(vcat(
        (SCALE[] >= 2 ? [(new_hyperpa, 8.25)] : []),
        (SCALE[] >= 2 ? [(new_hyperpa_python, 8.25)] : []),
        [(new_hyperpa, t) for t in 10 .^ (2:.5:6.5+SCALE[])],
        [(new_hyperpa_python, t) for t in 10 .^ (2:.5:5.5+1.5SCALE[])],
        (SCALE[] >= 2 ? [(old_hyperpa, t) for t in 45000*10 .^ (.75:.25:1)] : []),
        (SCALE[] >= 1 ? [(old_hyperpa, t) for t in 45000*10 .^ (0:.25:.5)] : []),
        repeat(vcat(
        (SCALE[] >= 2 ? [(old_hyperpa, t) for t in 45000*10 .^ (0:.25:.5)] : []),
        [(new_hyperpa, t) for t in 10 .^ (2:.5:5.5+SCALE[])],
        [(new_hyperpa_python, t) for t in 10 .^ (2:.5:3.5+2SCALE[])]), 10),
        repeat(
        [(new_hyperpa, t) for t in 10 .^ (2:.5:3+SCALE[]/2)], 1000))))

    any_old = any(fs .== old_hyperpa)

    if COMPUTE[]
        @time sizes, times, densities = unzip(datapoint.(fs, target))
        push!(DATA[3], (fs, target, sizes, times, densities))
    else
        fs, target, sizes, times, densities = last(DATA[3])
    end

    #display(scatter(sizes, densities, group=string.(fs) .* " density"; first_row_x...))

    I = middles(times, target, fs)

    scatter(sizes[I], times[I], group=[x == new_hyperpa ? 1 : x == old_hyperpa ? 2 : 3 for x in fs[I]];
        first_row...,
        ylabel = L"\textrm{\large\bf runtime (s)}",
        labels = any_old ? [L"\textrm{\bf FBD}" L"\textrm{\bf TYHS}" L"\textrm{\bf FBD (Python)}"] : [L"\textrm{\bf FBD}" L"\textrm{\bf FBD (Python)}"],
        xticks = (10.0 .^ (2:8), [L"\large\bf 10^{%$i}" for i in 2:8]),
        yticks = (10.0 .^ ((-4.0):5.0), [L"\large\bf 10^{%$i}" for i in -4:5]),)
end

function make_figure_4()
    # 17s at SCALE[] = 0
    # 225 seconds at SCALE[] = 2
    trials = min(15, 5^SCALE[])
    fs, target = unzip(shuffle!(repeat(vcat(
        [((x,y) -> new_dchsbm(x,y,kmax=10), t) for t in LinRange(1.2, 6, 20)],
        [((x,y) -> old_dchsbm(x,y,kmax=10), t) for t in 9:.5:15]), trials)))

    if COMPUTE[]
        @time sizes, times, densities = unzip(datapoint.(fs, 10^7, target))
        push!(DATA[4], (fs, target, sizes, times, densities))
    else
        fs, target, sizes, times, densities = last(DATA[4])
    end

    #display(scatter(densities, sizes, group=string.(fs) .* " density"; yaxis = :log))

    I = middles(times, target, fs)
    scatter(densities[I], times[I]./sizes[I], group=string.(fs[I]);
        yaxis = :log,
        yticks = (10.0 .^ (-8:-4), [L"\large\bf 10^{%$i}" for i in -8:-4]),
        xticks = (1:6, [L"\large\bf %$x" for x in 1:6]),
        bottom_margin = 10Plots.px,
        fontfamily = "times",
        guidefontsize = 14,
        tickfontsize = 15,
        legendfontsize = 12,
        legend=:topleft,
        ylabel = L"\textrm{\large\bf runtime (s) / hypergraph size      ..}",
        xlabel = L"\textrm{\large\bf log(hypergraph size) / log(nodes)}",
        xlims = (1,6.02),
        labels = [L"\textrm{\large\bf FBD}" L"\textrm{\large\bf CVB}"],
        #grid = false,
        #markerstrokewidth = 0,
        markersize = 7)
end
function make_figure_5()
    # 32s at SCALE[] = 0
    # 1 hour at SCALE[] = 2
    trials = min(11, 5^SCALE[])
    fs, target = unzip(shuffle!(repeat(vcat(
        [(new_dchsbm, t) for t in LinRange(1.1, 3, 20)],
        [(old_dchsbm, t) for t in 10 .^ (-.2-.6SCALE[]:.2:.2)]), trials)))

    if COMPUTE[]
        @time sizes, times, densities = unzip(datapoint.(fs, 10^7, target))
        push!(DATA[5], (fs, target, sizes, times, densities))
    else
        fs, target, sizes, times, densities = last(DATA[5])
    end

    #display(scatter(densities, sizes, group=string.(fs) .* " density"; yaxis = :log))

    I = middles(times, target, fs)
    scatter(densities[I], times[I]./sizes[I], group=string.(fs[I]);
        yaxis = :log,
        yticks = (10.0 .^ (-7:-5), [L"\large\bf 10^{%$i}" for i in -7:-5]),
        xticks = (1:.5:3, [L"\large\bf %$x" for x in 1:.5:3]),
        xlims = (1,3.025),
        bottom_margin=10Plots.px,
        right_margin=10Plots.px,
        fontfamily = "times",
        guidefontsize = 14,
        tickfontsize = 15,
        legendfontsize = 12,
        legend=:topleft,
        #ylabel = L"\textrm{\large\bf runtime (s) / hypergraph size      ..}",
        xlabel = L"\textrm{\large\bf log(hypergraph size) / log(nodes)}",
        labels = [L"\textrm{\large\bf FBD}" L"\textrm{\large\bf CVB}"],
        #grid = false,
        #markerstrokewidth = 0,
        markersize = 7)
end

function make_figure_6()
    # 15s at SCALE[] = 0
    # 16m at SCALE[] = 2
    trials = min(15, 5^SCALE[])
    fs, target = unzip(shuffle!(repeat(vcat(
        [(new_kronecker, t) for t in [1e-49, 1e-45, 1e-40, 1e-37, 1e-30, 1e-24, 1e-20, 1e-14, 1e-13, 1e-9, 1e-7, 3e-4, 3e-2, 3e3] * 1e-4],
        [(old_kronecker, t) for t in [1e-13, 1e-11, 1e-9, 5e-8, 2e-6, 4e-5, 1e-3, 1e-2, 1e-1, .5, 1, 10, 100][begin+6-3SCALE[]:end]]), trials)))

    if COMPUTE[]
        @time sizes, times, densities = unzip(datapoint.(fs, 10^7, target))
        push!(DATA[6], (fs, target, sizes, times, densities))
    else
        fs, target, sizes, times, densities = last(DATA[6])
    end

    #display(scatter(densities, sizes, group=string.(fs) .* " density"; yaxis = :log))

    I = middles(times, target, fs)
    scatter(densities[I], times[I]./sizes[I], group=string.(fs[I]);
        yaxis = :log,
        yticks = (10.0 .^ (-7:-2), [L"\large\bf 10^{%$i}" for i in -7:-2]),
        xticks = (1:.5:3, [L"\large\bf %$x" for x in 1:.5:3]),
        xlims = (1,3),
        bottom_margin=10Plots.px,
        right_margin=10Plots.px,
        guidefontsize = 14,
        tickfontsize = 15,
        legendfontsize = 12,
        legend=:topright,
        fontfamily = "times",
        #ylabel = L"\textrm{\large\bf runtime (s) / hypergraph size      ..}",
        xlabel = L"\textrm{\large\bf log(hypergraph size) / log(nodes)}",
        labels = [L"\textrm{\large\bf FBD}" L"\textrm{\large\bf ERG}"],
        #grid = false,
        #markerstrokewidth = 0,
        markersize = 7)
end

## Post processing
"""
    save_figures(scale = 0)

Generate figures for the paper and save them in the figures directory.

Runtime is about 2 minutes for scale = 0 and many hours for scale = 2.
The figures for the paper were generated at scale = 2.
Larger scale corresponds to more replicates and higher maximum runtimes.

See also `make_figure_0` to make the figure at the start of the paper.
"""
function save_figures(scale::Integer=0)

    SCALE[] = scale

    path = joinpath(dirname(@__DIR__), "figures")
    mkpath(path)

    COMPUTE[] && println("Saved: $(save_data())")
    savefig(make_figure_1(), joinpath(path,"dchsbm_size.pdf"))
    COMPUTE[] && println("Saved: $(save_data())")
    savefig(make_figure_2(), joinpath(path,"kronecker_size.pdf"))
    COMPUTE[] && println("Saved: $(save_data())")
    savefig(make_figure_3(), joinpath(path,"hyperpa_size.pdf"))
    COMPUTE[] && println("Saved: $(save_data())")
    savefig(make_figure_4(), joinpath(path,"dchsbm_density_k10.pdf"))
    COMPUTE[] && println("Saved: $(save_data())")
    savefig(make_figure_5(), joinpath(path,"dchsbm_density_k3.pdf"))
    COMPUTE[] && println("Saved: $(save_data())")
    savefig(make_figure_6(), joinpath(path,"kronecker_density_k3.pdf"))
    COMPUTE[] && println("Saved: $(save_data())")

    println("Saved figures to $path")
end

function save_data(n=round(Integer, time())%(60*60*24*365))
    open("data_$n.txt", "w") do io
        write(io, string(DATA))
    end
    n
end
function load_data(n)
    v = read("data_$n.txt")
    s = String(v)
    s2 = replace(s,
        "FBDCompare.var" => "",
        "\"()" => "\"",
        "Function[" => "Union{String, Function}[")
    e = Meta.parse(s2)
    d = eval(e)
    DATA .= d
    COMPUTE[] || nothing
end



## The figure at the beginning of the paper
fbd_with_duplicate_removal(n, m, k) = fbd_with_duplicate_removal(n, m, Val(k))
function fbd_with_duplicate_removal(n, m, k::Val{K}) where K
    g = Set{NTuple{K, Int}}()
    sizehint!(g, m)
    while length(g) < m
        push!(g, ntuple(_ -> rand(1:n), k))
    end
    g
end

function make_figure_0()
    # 3s at SCALE[] = 0
    # 170s at SCALE[] = 2
    n = 35
    k = 3
    pts = [20, 35, 50][SCALE[]+1]
    trials = [11, 51, 301][SCALE[]+1]
    fs, target = unzip(shuffle!(repeat(vec(collect(Iterators.product(1:6,
        round.(Integer, LinRange(0,n^k-1,pts+1)[2:end]#=10 .^ LinRange(1, log10(n^k-1), pts)=#)))), trials)))
    function F(f, m)
        f == 4 && m / n^k > .97 && return NaN
        if f == 1
            @elapsed er(n, m, k)
        elseif f == 2
            @elapsed fbd_with_duplicate_removal(n, m, k)
        elseif f == 3
            @elapsed ER.coin_flip_with_duplicates(n, k, m)
        elseif f == 4
            @elapsed ER.coin_flip(n, k, m)
        elseif f == 5
            @elapsed ER.grass_hop_with_duplicates(n, k, m)
        elseif f == 6
            @elapsed ER.grass_hop(n, k, m)
        end
    end

    @time times = F.(fs, target)

    I = middles(times, target, fs)
    sort!(I, by=i->target[i])
    p = plot(target[I]./n^k, times[I]./target[I]./k, group=string.(fs[I]);
        ylims = (0,5e-8),
        yformatter = t -> L"\large\bf%$(round(Integer,t*1e9))",
        xticks = (0:.2:1, [L"\large\bf %$t" for t in 0:.2:1]),
        bottom_margin=10Plots.px,
        right_margin=10Plots.px,
        legend=(.46,.96),
        fontfamily = "times",
        tickfontsize = 12,
        legendfontsize = 10,
        ylabel = L"\textrm{\large\bf runtime (ns) / hypergraph size}",
        xlabel = L"\textrm{\large\bf edges / possible edges}",
        labels = [L"\textrm{\bf FBD}" nothing L"\textrm{\bf Coin Flipping}" nothing L"\textrm{\bf Grass Hopping}" nothing],
        color = [1 1 2 2 3 3],
        linestyle = [:solid :dash :solid :dash :solid :dash]
        )
    path = joinpath(dirname(@__DIR__), "figures")
    mkpath(path)
    file = joinpath(path, "er.pdf")
    savefig(file)
    println("Saved figure to $file")
    p
end
