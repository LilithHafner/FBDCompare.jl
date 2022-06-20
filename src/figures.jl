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
scale=2
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
    #500s at scale = 2
    fs, target = unzip(shuffle!(vcat(
        [(new_dchsbm, t) for t in 10 .^ (1:.5:7.5+scale)],
        [(old_dchsbm, t) for t in 10 .^ (1:.5:4.5+scale)],
        repeat(vcat(
        [(new_dchsbm, t) for t in 10 .^ (1:.5:6.5+scale)],
        [(old_dchsbm, t) for t in 10 .^ (1:.5:3.5+scale)]), 10),
        repeat(
        [(new_dchsbm, t) for t in 10 .^ (1:.5:4+scale/2)], 1000))))

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
    fs, target = unzip(shuffle!(vcat(
        [(new_kronecker, t) for t in 10 .^ (1:.5:7.5+scale)],
        [(old_kronecker, t) for t in 10 .^ (1:.5:6+scale)],
        repeat(vcat(
        [(new_kronecker, t) for t in 10 .^ (1:.5:6.5+scale)],
        [(old_kronecker, t) for t in 10 .^ (1:.5:5+scale)]), 10),
        repeat(vcat(
        [(new_kronecker, t) for t in 10 .^ (1:.5:3.5+scale/2)],
        [(old_kronecker, t) for t in 10 .^ (1:.5:2+scale/2)]), 1000))))

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
    fs, target = unzip(shuffle!(vcat(
        (scale >= 2 ? [(new_hyperpa, 8.25)] : []),
        [(new_hyperpa, t) for t in 10 .^ (2:.5:6.5+scale)],
        (scale >= 2 ? [(old_hyperpa, t) for t in 45000*10 .^ (0:.25:1)] : []),
        repeat(vcat(
        (scale >= 2 ? [(old_hyperpa, t) for t in 45000*10 .^ (0:.25:.5)] : []),
        [(new_hyperpa, t) for t in 10 .^ (2:.5:5.5+scale)]), 10),
        repeat(
        [(new_hyperpa, t) for t in 10 .^ (2:.5:3+scale/2)], 1000))))

    if COMPUTE[]
        @time sizes, times, densities = unzip(datapoint.(fs, target))
        push!(DATA[3], (fs, target, sizes, times, densities))
    else
        fs, target, sizes, times, densities = last(DATA[3])
    end

    #display(scatter(sizes, densities, group=string.(fs) .* " density"; first_row_x...))

    I = middles(times, target, fs)

    scatter(sizes[I], times[I], group=string.(fs[I]); first_row...,
        ylabel = L"\textrm{\large\bf runtime (s)}",
        labels = [L"\textrm{\large\bf FBD}" L"\textrm{\large\bf TYHS}"],
        xticks = (10.0 .^ (2:8), [L"\large\bf 10^{%$i}" for i in 2:8]),
        yticks = (10.0 .^ ((-4.0):5.0), [L"\large\bf 10^{%$i}" for i in -4:5]),)
end

function make_figure_4()
    #12 seconds at trials=1
    trials = min(15, 5^scale)
    fs, target = unzip(shuffle!(repeat(vcat(
        [((x,y) -> new_dchsbm(x,y,kmax=10), t) for t in vcat([6e-21, 3e-18], 10 .^ ((-17:1:1).+4 .- LinRange(-√4,√4,19).^2)[2:end])],
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
        xticks = (2:6, [L"\large\bf %$x" for x in 2:6]),
        bottom_margin = 10Plots.px,
        fontfamily = "times",
        guidefontsize = 14,
        tickfontsize = 15,
        legendfontsize = 12,
        legend=:topleft,
        ylabel = L"\textrm{\large\bf runtime (s) / hypergraph size      ..}",
        xlabel = L"\textrm{\large\bf log(hypergraph size) / log(nodes)}",
        xlims = (2,6),
        labels = [L"\textrm{\large\bf FBD}" L"\textrm{\large\bf CVB}"],
        #grid = false,
        #markerstrokewidth = 0,
        markersize = 7)
end
function make_figure_5()
    # 1 hour? at trials=11
    fs, target = unzip(shuffle!(repeat(vcat(
        [(new_dchsbm, t) for t in vcat([1e-11], 10 .^ ((-10:.5:1).+2 .- LinRange(-√2,√2,23).^2))],
        [(old_dchsbm, t) for t in 10 .^ (-1.4:.2:1)]), 11)))

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
        xlims = (1,3),
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
    # 16m at trials = 15
    fs, target = unzip(shuffle!(repeat(vcat(
        [(new_kronecker, t) for t in [1e-49, 1e-45, 1e-40, 1e-37, 1e-30, 1e-24, 1e-20, 1e-14, 1e-13, 1e-9, 1e-7, 3e-4, 3e-2, 3e3] * 1e-4],
        [(old_kronecker, t) for t in [1e-13, 1e-11, 1e-9, 5e-8, 2e-6, 4e-5, 1e-3, 1e-2, 1e-1, .5, 1, 10, 100]]), 15)))

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
function save_figures()

    path = joinpath(dirname(@__DIR__), "figures", "")
    mkpath(path)

    #COMPUTE[] && display("Saved: $(save_data())")
    #savefig(make_figure_1(), path*"dchsbm_size.pdf")
    #COMPUTE[] && display("Saved: $(save_data())")
    #savefig(make_figure_2(), path*"kronecker_size.pdf")
    #COMPUTE[] && display("Saved: $(save_data())")
    #savefig(make_figure_3(), path*"hyperpa_size.pdf")
    COMPUTE[] && display("Saved: $(save_data())")
    savefig(make_figure_4(), path*"dchsbm_density_k10.pdf")
    #COMPUTE[] && display("Saved: $(save_data())")
    #savefig(make_figure_5(), path*"dchsbm_density_k3.pdf")
    #COMPUTE[] && display("Saved: $(save_data())")
    #savefig(make_figure_6(), path*"kronecker_density_k3.pdf")
    COMPUTE[] && display("Saved: $(save_data())")
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
function fbd_with_duplicate_removal(s::FBD.ER_sampler{N, K}, m) where {N, K}
    g = Set{NTuple{K, Int}}()
    sizehint!(g, m)
    while length(g) < m
        push!(g, rand(s))
    end
    g
end

function make_figure_0()
    # 40s at trials = 101
    n = 35
    k = 3
    pts = 50
    trials = 301
    fs, target = unzip(shuffle!(repeat(vec(collect(Iterators.product(1:4,
        round.(Integer, LinRange(0,n^k-1,pts+1)[2:end]#=10 .^ LinRange(1, log10(n^k-1), pts)=#)))), trials)))
    function F(f, m)
        f > 3 && m / n^k > .95 && return NaN
        if f == 1
            @elapsed ER.coin_flip(n, k, m)
        elseif f == 2
            @elapsed ER.grass_hop(n, k, m)
        elseif f == 3
            @elapsed rand(ER_sampler(n, k), m)
        elseif f == 4
            @elapsed fbd_with_duplicate_removal(ER_sampler(n, k), m)
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
        legend=(.2,.93),
        fontfamily = "times",
        tickfontsize = 12,
        legendfontsize = 10,
        ylabel = L"\textrm{\large\bf runtime (ns) / hypergraph size}",
        xlabel = L"\textrm{\large\bf hyperedges / possible hyperedges}",
        labels = [L"\textrm{\bf Coin Flipping}" L"\textrm{\bf Grass Hopping}" L"\textrm{\bf FBD}" L"\textrm{\bf FBD with duplicate removal}"],
        )
    savefig(joinpath(dirname(@__DIR__), "figures", "er.pdf"))
    p
end
