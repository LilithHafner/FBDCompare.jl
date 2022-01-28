using Statistics
using FBDCompare: sumOfExteriorDegreesIntensityFunction, sampleSBM, sampleEdges

Ω = sumOfExteriorDegreesIntensityFunction((x, α)->(x[1]+1)^(-α[x[2]]*x[2]), 3)

t = @elapsed d,r = sampleEdges([1,1,2,2], Float64[1,1,1,1], Ω, α=Float64[.1, .3, .9], kmin=2, kmax=3)
hypergraphsize = sum([k*sum(values(x)) for (k,x) in d])
println("","A: $(hypergraphsize/t), $t")

t = @elapsed d,r = sampleEdges(repeat(1:5, inner=10), ones(5*10), Ω, α=Float64[.1, .3, .9], kmin=2, kmax=3)
hypergraphsize = sum([k*sum(values(x)) for (k,x) in d])
println("","B: $(hypergraphsize/t), $t")

t = @elapsed d,r = sampleEdges(repeat(1:5, inner=30), ones(5*30), Ω, α=Float64[.01, .03, .09], kmin=2, kmax=3)
hypergraphsize = sum([k*sum(values(x)) for (k,x) in d])
println("","C: $(hypergraphsize/t), $t")

Z = vcat([fill(i, ceil(Integer, 100*proportion)) for (i,proportion) in enumerate([.4,.1,.03,.2,.2,.07])]...)
γ = 1.63
θ = ((γ+1) .* rand(length(Z))) .^ (-γ-1)
Ω = FBDCompare.allOrNothingIntensityFunction((x, α) -> x[1] ? α[1] : α[2], 3)
t = @elapsed d,r = sampleEdges(Z, θ, Ω, α=[.0001,.00001], kmin=2, kmax=3)
hypergraphsize = sum([k*sum(values(x)) for (k,x) in d])
println("","D: $(hypergraphsize/t), $t")

#begin coppied from https://github.com/nveldt/HyperModularity.jl/blob/0478acb5e209550cbaf7572f4151c4569f64faf6/test/runtests.jl#L20
n = 40 # modified to change n from 20
Z = rand(1:5, n)
Z = Int64.(Z)
ϑ = dropdims(ones(1,n) + rand(1,n), dims = 1)
μ = mean(ϑ)
kmax = Int64(4)

scaling_factor = .01 # modified to add scaling factor
ω(x, α) = scaling_factor*(x[1]+1)^(-α[x[2]]*x[2]) # modified to add scaling factor

α = repeat([2.0], kmax)

Ω = sumOfExteriorDegreesIntensityFunction(ω, kmax)
t = @elapsed d, nodes = sampleEdges(Z, ϑ, Ω;α=α, kmax=kmax, kmin = 1) # modified
#end coppied from https://github.com/nveldt/HyperModularity.jl/blob/0478acb5e209550cbaf7572f4151c4569f64faf6/test/runtests.jl#L20
hypergraphsize = sum([k*sum(values(x)) for (k,x) in d])
edges = sum([sum(values(x)) for (k,x) in d])
possible_edges = sum([binomial(n,k) for k in 1:kmax])
density = edges/possible_edges
println("","E: $(hypergraphsize/t), $t, density=$density")
