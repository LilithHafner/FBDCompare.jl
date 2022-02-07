using Plots
using Unzip
using Random: shuffle!

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
first_row_x = (
    xaxis = :log,
    xlims = (10^.9, 10^6.1),
    xticks = 10.0 .^ (0:6),
)
first_row = (
    yaxis = :log10,
    xlabel = "size",
    ylabel = "runtime (s)",
    guidefontsize = 14,
    ylims = (10^-6.1, 10^-.9),
    #yticks = [1e-6, 1e-5],
    yticks = 10.0 .^ ((-6.0):3.0),
    fontfamily = "times",
    tickfontsize = 12,
    legendfontsize = 12,
    legend =:topleft,
    labels = ["FBD" "CVB"],
    #grid = false,
    #markerstrokewidth = 0,
    markersize = 7,
    first_row_x...
    )

function make_figure_1()
    fs, target = unzip(shuffle!(repeat(vcat(
        [(new_dchsbm, t) for t in 10 .^ (0:.5:6)],
        [(old_dchsbm, t) for t in 10 .^ (0:.5:3)]), 3)))

    @time sizes, times, densities = unzip(datapoint.(fs, target))

    #display(scatter(sizes, densities, group=string.(fs) .* " density"; first_row_x...))

    I = middles(times, target, fs)
    scatter(sizes[I], times[I], group=string.(fs[I]); first_row...)
end
function make_figure_2()
    fs, target = unzip(shuffle!(repeat(vcat(
        [(new_kronecker, t) for t in 10 .^ (0:.5:5.5)],
        [(old_kronecker, t) for t in 10 .^ (0:.5:4)]), 3)))

    @time sizes, times, densities = unzip(datapoint.(fs, target))

    #display(scatter(sizes, densities, group=string.(fs) .* " density"; first_row_x...))

    I = middles(times, target, fs)
    scatter(sizes[I], times[I], group=string.(fs[I]); first_row...)
    xlabel!("size", fontsize = 16, fontweight = :bold)
end
function make_figure_3()
    fs, target = unzip(shuffle!(repeat(vcat(
        [(new_hyperpa, t) for t in 10 .^ (0:.5:5.5)],
        [(old_hyperpa, t) for t in []#=45000=#]), 1)))

    @time sizes, times, densities = unzip(datapoint.(fs, target))

    #display(scatter(sizes, densities, group=string.(fs) .* " density"; first_row_x...))

    I = middles(times, target, fs)
    scatter(sizes[I], times[I], group=string.(fs[I]); first_row...)
end

function make_figure_4()
    fs, target = unzip(shuffle!(repeat(vcat(
        [((x,y) -> new_dchsbm(x,y,kmax=10), t) for t in 10 .^ ((-20:1:3).+3 .- LinRange(-√3,√3,24).^2)],
        [((x,y) -> old_dchsbm(x,y,kmax=10), t) for t in 10 .^ (1:.25:2.5)]), 3)))

    @time sizes, times, densities = unzip(datapoint.(fs, 10^5, target))

    #display(scatter(sizes, densities, group=string.(fs) .* " density"; first_row_x...))

    I = middles(times, target, fs)
    scatter(densities[I], times[I]./sizes[I], group=string.(fs[I]);
        yaxis = :log, yticks = 10.0 .^(-9:-2),
        fontfamily = "times",
        guidefontsize = 14,
        tickfontsize = 12,
        legendfontsize = 12,
        legend=:topleft,
        ylabel = "runtime (s) / size",
        xlabel = "log(edges) / log(nodes)",
        xlims = (1,7),
        labels = ["FBD" "CVB"],
        grid = false,
        #markerstrokewidth = 0,
        markersize = 7)
end
function make_figure_5()
    fs, target = unzip(shuffle!(repeat(vcat(
        [(new_dchsbm, t) for t in 10 .^ ((-6:.5:1).+2 .- LinRange(-√2,√2,15).^2)],
        [(old_dchsbm, t) for t in 10 .^ (-1:.25:1)]), 3)))

    @time sizes, times, densities = unzip(datapoint.(fs, 10^4, target))

    #display(scatter(sizes, densities, group=string.(fs) .* " density"; first_row_x...))

    I = middles(times, target, fs)
    scatter(densities[I], times[I]./sizes[I], group=string.(fs[I]);
        yaxis = :log, yticks = 10.0 .^((-9):(-2)),
        fontfamily = "times",
        guidefontsize = 14,
        tickfontsize = 12,
        legendfontsize = 12,
        legend=:topleft,
        ylabel = "runtime (s) / size",
        xlabel = "log(edges) / log(nodes)",
        labels = ["FBD" "CVB"],
        grid = false,
        #markerstrokewidth = 0,
        markersize = 7)
end

function make_figure_6()
    fs, target = unzip(shuffle!(repeat(vcat(
        [(new_kronecker, t) for t in 10 .^ (-6.5:.5:1)],
        [(old_kronecker, t) for t in 10 .^ (-5.5:.5:1)]), 3)))

    @time sizes, times, densities = unzip(datapoint.(fs, 10^4, target))

    #display(scatter(sizes, densities, group=string.(fs) .* " density"; first_row_x...))

    I = middles(times, target, fs)
    scatter(densities[I], times[I]./sizes[I], group=string.(fs[I]);
        yaxis = :log,
        yticks = 10.0 .^(-9:-2),
        guidefontsize = 14,
        tickfontsize = 12,
        legendfontsize = 12,
        legend=:topleft,
        fontfamily = "times",
        ylabel = "runtime (s) / size",
        xlabel = "log(edges) / log(nodes)",
        labels = ["FBD" "ERG"],
        grid = false,
        #markerstrokewidth = 0,
        markersize = 7)
end


function figure2(;points=30,trials=3,min_size=1,max_size=3e6,old_max_sizes=[5e3,1e5,0],
    names = string.(first.(test_functions)))
    for ((old, new), old_max_size, name) in zip(test_functions, old_max_sizes, names)
        sizes = exp.(LinRange(log(min_size),log(max_size),points))
        independant = vec(repeat(collect(Iterators.product((new,old), sizes)), outer=trials))
        filter!(independant) do x
            generator, target_size = x
            # the old algorithms are substantially slower, so we can't go as large
            generator === new || target_size <= old_max_size
        end
        shuffle!(independant)
        dependant = map(independant) do x
            generator, target_size = x
            t = @elapsed g = generator(round(Integer, target_size))
            size = hypergraphsize(g)
            t, size
        end
        data = collect(zip(independant, dependant))
        sort!(data, by=x->((x[1][1]==new),x[1][2:end],x[2:end]))
        data = data[trials÷2+1:trials:end]
        p = plot(title = "$new/$old\nmedian of $trials trials", xaxis=:log, xlabel="hpergraph size", yaxis=:log, ylabel="time (s)")
        for target in (new,old)
            target_data = last.(filter(x -> x[1][1] === target, data))
            scatter!(p, max.(1,last.(target_data)), first.(target_data), label=string(target))
        end
        display(p)
    end
end

function figure3(;points=30,trials=3,size=5e3,old_min_densities=[1, 1e-3,0],
    names = ["kmax=10", string.(first.(test_functions[1:2]))...])
    for ((old, new), old_min_density, name) in zip([[(x,y)->f(x,y,kmax=10) for f in test_functions[1]], test_functions[1:2]...], old_min_densities, names)
        densities = exp.(LinRange(log(1e-12),log(1e1),points))
        independant = vec(repeat(collect(Iterators.product((new,old), densities)), outer=trials))

        filter!(independant) do x
            generator, target_density = x
            # the old algorithms are substantially slower, so we can't go as large
            generator === new || target_density >= old_min_density
        end

        shuffle!(independant)
        dependant = map(independant) do x
            generator, target_density = x
            t = @elapsed g = generator(round(Integer, size), target_density)
            d = log_density(g)
            hypergraphsize(g), t/hypergraphsize(g), d
        end
        data = collect(zip(independant, dependant))
        sort!(data, by=x->((x[1][1]==new),x[1][2:end],x[2:end]))
        data = data[trials÷2+1:trials:end]
        p = plot(title = "$new/$old\nmedian of $trials trials", xlabel="log(edges)/log(nodes)", yaxis=:log, ylabel="time per edge (s)")
        for target in (new,old)
            target_data = last.(filter(x -> x[1][1] === target, data))
            scatter!(p, last.(target_data), [x[2] for x in target_data], label=string(target))
            #scatter!(p, last.(target_data), first.(target_data)/1e11, label=string(target)*"edges")
        end
        display(p)
    end
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
