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
scale=0
first_row_x = (
    xaxis = :log,
    #xlims = (10^.9, 10^8.6),
    xticks = (10.0 .^ (0:9), [L"\large\bf 10^{%$i}" for i in 0:9]),
)
first_row = (
    yaxis = :log10,
    xlabel = L"\textrm{\large\bf hypergraph size   .}",
    ylabel = L"\textrm{\large\bf runtime (s)}",
    guidefontsize = 4,
    #ylims = (10^-6.1, 10^-.9),
    #yticks = [1e-6, 1e-5],
    yticks = (10.0 .^ ((-6.0):3.0), [L"\large\bf 10^{%$i}" for i in -6:3]),
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
        [(new_dchsbm, t) for t in 10 .^ (1:.5:6+scale/2)],
        [(old_dchsbm, t) for t in 10 .^ (1:.5:3+scale/2)]), 10),
        repeat(
        [(new_dchsbm, t) for t in 10 .^ (1:.5:3.5+scale/2)], 1000))))

    if COMPUTE[]
        @time sizes, times, densities = unzip(datapoint.(fs, target))
        push!(DATA[1], (fs, target, sizes, times, densities))
    else
        fs, target, sizes, times, densities = last(DATA[1])
    end

    #display(scatter(sizes, densities, group=string.(fs) .* " density"; first_row_x...))

    I = middles(times, target, fs)
    scatter(sizes[I], times[I], group=string.(fs[I]); labels = [L"\textrm{\large\bf FBD}" L"\textrm{\large\bf CVB}"], first_row...)
end
function make_figure_2()
    fs, target = unzip(shuffle!(vcat(
        [(new_kronecker, t) for t in 10 .^ (1:.5:6.5+scale)],
        [(old_kronecker, t) for t in 10 .^ (1:.5:5.5+scale)],
        repeat(vcat(
        [(new_kronecker, t) for t in 10 .^ (1:.5:6+scale/2)],
        [(old_kronecker, t) for t in 10 .^ (1:.5:5+scale/2)]), 10),
        repeat(vcat(
        [(new_kronecker, t) for t in 10 .^ (1:.5:3+scale/2)],
        [(old_kronecker, t) for t in 10 .^ (1:.5:2+scale/2)]), 1000))))

    if COMPUTE[]
        @time sizes, times, densities = unzip(datapoint.(fs, target))
        push!(DATA[2], (fs, target, sizes, times, densities))
    else
        fs, target, sizes, times, densities = last(DATA[2])
    end

    #display(scatter(sizes, densities, group=string.(fs) .* " density"; first_row_x...))

    I = middles(times, target, fs)
    scatter(sizes[I], times[I], group=string.(fs[I]); labels = [L"\textrm{\large\bf FBD}" L"\textrm{\large\bf ERG}"], first_row...)
end

function make_figure_3()
    fs, target = unzip(shuffle!(vcat(
        [(new_hyperpa, t) for t in 10 .^ (2:.5:6.5+scale)],
        (scale >= 2 ? [(old_hyperpa, t) for t in 45000*10 .^ (0:.25:1)] : []),
        repeat(
        [(new_hyperpa, t) for t in 10 .^ (2:.5:6+scale/2)], 10),
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

    scatter(sizes[I], times[I], group=string.(fs[I]); labels = [L"\textrm{\large\bf FBD}" L"\textrm{\large\bf TYHS}"], first_row...)
end

trials = 1
function make_figure_4()
    #12 seconds at trials=1
    fs, target = unzip(shuffle!(repeat(vcat(
        [((x,y) -> new_dchsbm(x,y,kmax=10), t) for t in 10 .^ ((-17:1:1).+4 .- LinRange(-√4,√4,19).^2)],
        [((x,y) -> old_dchsbm(x,y,kmax=10), t) for t in 10 .^ (1:.05:1.8).+.3 .- LinRange(-√.3,√.3,17).^2]), trials)))

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
        yticks = (10.0 .^ (-8:-6), [L"\large\bf 10^{%$i}" for i in -8:-6]),
        xticks = (2:6, [L"\large\bf %$x" for x in 2:6]),
        fontfamily = "times",
        guidefontsize = 14,
        tickfontsize = 15,
        legendfontsize = 12,
        legend=:topleft,
        ylabel = L"\textrm{\large\bf runtime (s) / hypergraph size   .}",
        xlabel = L"\textrm{\large\bf log(edges) / log(nodes)}",
        xlims = (2,6),
        labels = [L"\textrm{\large\bf FBD}" L"\textrm{\large\bf CVB}"],
        #grid = false,
        #markerstrokewidth = 0,
        markersize = 7)
end
function make_figure_5()
    # 200?s at trials=1
    fs, target = unzip(shuffle!(repeat(vcat(
        [(new_dchsbm, t) for t in 10 .^ ((-10:.5:1).+2 .- LinRange(-√2,√2,23).^2)],
        [(old_dchsbm, t) for t in 10 .^ (-1:.15:1)]), trials)))

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
        yticks = (10.0 .^ (-7:-2), [L"\large\bf 10^{%$i}" for i in -7:-2]),
        xticks = (1:.5:3, [L"\large\bf %$x" for x in 1:.5:3]),
        xlims = (1,3),
        fontfamily = "times",
        guidefontsize = 14,
        tickfontsize = 15,
        legendfontsize = 12,
        legend=:topleft,
        ylabel = L"\textrm{\large\bf runtime (s) / hypergraph size   .}",
        xlabel = L"\textrm{\large\bf log(edges) / log(nodes)}",
        labels = [L"\textrm{\large\bf FBD}" L"\textrm{\large\bf CVB}"],
        #grid = false,
        #markerstrokewidth = 0,
        markersize = 7)
end

function make_figure_6()
    # 65s at trials = 1
    fs, target = unzip(shuffle!(repeat(vcat(
        [(new_kronecker, t) for t in [1e-13, 1e-11, 2e-9, 1e-7, 2e-6, 4e-5, 3e-4, 1e-3, 1e-2, 1e-1, 1, 10]],
        [(old_kronecker, t) for t in [1e-13, 1e-11, 1e-9, 5e-8, 2e-6, 4e-5, 1e-3, 1e-2, 1e-1, .5, 1, 10, 100]]), trials)))

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
        guidefontsize = 14,
        tickfontsize = 15,
        legendfontsize = 12,
        legend=:topright,
        fontfamily = "times",
        ylabel = L"\textrm{\large\bf runtime (s) / hypergraph size   .}",
        xlabel = L"\textrm{\large\bf log(edges) / log(nodes)}",
        labels = [L"\textrm{\large\bf FBD}" L"\textrm{\large\bf ERG}"],
        #grid = false,
        #markerstrokewidth = 0,
        markersize = 7)
end

## Post processing
function save_figures()

    path = joinpath(dirname(@__DIR__), "figures", "")
    mkpath(path)

    savefig(make_figure_1(), path*"dchsbm_size.pdf")
    savefig(make_figure_2(), path*"kronecker_size.pdf")
    savefig(make_figure_3(), path*"hyperpa_size.pdf")
    savefig(make_figure_4(), path*"dchsbm_density_k10.pdf")
    savefig(make_figure_5(), path*"dchsbm_density_k3.pdf")
    savefig(make_figure_6(), path*"kronecker_density_k3.pdf")
end
