using FBD
using Plots
using Random: shuffle

function n_unique(f, n)
    s = Set([f() for _ in 1:n])
    while length(s) < n
        push!(s, f())
    end
    s
end

function approx_n_unique(f, n, domain)
    samples = log(1-n/domain)/log(1-1/domain)
    Set([f() for _ in 1:samples])
end

function trial(n, k, m)
    ((@elapsed ER.coin_flip(n, k, m)),
    (@elapsed ER.grass_hop(n, k, m)),
    (@elapsed rand(ER_sampler(n, k), m)),
    #(@elapsed (s = ER_sampler(n, k); approx_n_unique(()->rand(s), m, n^k))),
    (@elapsed (s = ER_sampler(n, k); n_unique(()->rand(s), m))))
end

function datapoint(n, k, m, trials)
    median.(zip([trial(n, k, m) for _ in 1:trials]...))./m.*1e9
end

function data(n, k, points, trials)
    out = []
    for m in round.(Integer, LinRange(1, n^k-1, points))
        push!(out, (m/n^k, datapoint(n, k, m, trials)))
    end
    out
end

function data2(n, k, points, trials)
    ms = round.(Integer, exp.(LinRange(log(10), log(n^k-1), points)))
    data = []
    for _ in 1:trials
        for m in shuffle(ms)
            push!(data, (m, trial(n, k, m)./m.*1e9))
        end
    end
    sort!(data)
    sdata = last.(reshape(data, trials, points))
    ms, [vec(median(getindex.(sdata, i), dims=1)) for i in 1:4]
end

function plt(n, k, points, trials)
    #d = data(n, k, points, trials)
    x, ys = data2(n, k, points, trials)#zip(d...)
    p = plot(title = "runtime of various methods at various densities of\nER model with $n nodes, k*=$k\nmedian time of $trials trials",
        ylabel = "Runtime (ns) per edge",
        xlabel = "edges (% of possible edges)",
        legend=:top,
        xaxis=:log,
        xformatter = xi -> "10^$(Int(log10(xi))) ($(100*xi/n^k))%",
        xticks=10 .^ (1:log10(n^k)))
    labels = ["Coin Flip", "Grasshop", "Functional Ball Drop",
    #"FBD with duplicate removal",
    "FBD with duplicate removal"]# and exact edge count"]
    for (y,label) in zip(ys, labels)
        plot!(x, y, label=label)
    end
    y = sort!(vcat(vec.(ys)...))
    ylims!(p, 0, 400)
    p
end
