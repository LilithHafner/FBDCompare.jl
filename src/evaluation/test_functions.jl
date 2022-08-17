using Statistics
using .DCHSBM: sumOfExteriorDegreesIntensityFunction, sampleEdges
using .Kronecker: hyperkron_graph, kron_params

## DCHSBM

function old_dchsbm(size::Real, density=1/40; kmax::Int64=3)
    density_modifier = density*40
    n = round(Integer, 4*(size/density_modifier)^(1/kmax)) # modified to change n from 20
    #begin copied from https://github.com/nveldt/HyperModularity.jl/blob/0478acb5e209550cbaf7572f4151c4569f64faf6/test/runtests.jl#L20
    Z = rand(1:5, n)
    Z = Int64.(Z)
    ϑ = dropdims(ones(1,n) + rand(1,n), dims = 1)
    μ = mean(ϑ)

    ω(x, α) = density_modifier*(x[1]+1)^(-α[x[2]]*x[2]) # modified to add density_modifier

    α = repeat([2.0], kmax)

    Ω = sumOfExteriorDegreesIntensityFunction(ω, kmax)
    sampleEdges(Z, ϑ, Ω;α=α, kmax=kmax, kmin = 1) # modified to skip computing degrees
    #end copied from https://github.com/nveldt/HyperModularity.jl/blob/0478acb5e209550cbaf7572f4151c4569f64faf6/test/runtests.jl#L20
end
new_dchsbm(size::Real; kmax::Int64=3) = _new_dchsbm(size, 4*size^(1/kmax), kmax)
new_dchsbm(size::Real, density; kmax::Int64=3) = _new_dchsbm(size, size^(1/density), kmax)
function _new_dchsbm(size, nf, kmax)
    n = round(Integer, nf)

    #modeled after old_dchsbm
    Z = rand(1:5, n)
    ϑ = rand(n) .+ 1

    Ω = FBD.inverse_power_intensity_function(8)

    sampler = DCHSBM_sampler(Ω, Z, ϑ, kmax)

    rand(sampler, round(Integer, size/kmax))
end


## Kronecker

# parameters copied from https://www.cs.purdue.edu/homes/dgleich/codes/hyperkron/
const KRON_PARAMS = kron_params(0.99, 0.2, 0.3, 0.05)
# With a little math, density can be turned into an optional argument with a default value
# dependent on size
function old_kronecker(size)
    power = max(1, round(Integer, log(2*size)/log(sum(KRON_PARAMS))))

    A,hedges = hyperkron_graph(KRON_PARAMS, power)
    hedges
end
function old_kronecker(size, density)
    power = max(1, round(Integer, log(2*size/density)/log(8)))
    density_modifier = density^(1/power)/mean(KRON_PARAMS)

    A,hedges = hyperkron_graph(min.(.99, density_modifier*KRON_PARAMS), power)
    hedges
end
function new_kronecker(size)
    power = max(1, round(Integer, log(2*size)/log(sum(KRON_PARAMS))))

    sampler = Kronecker_sampler(KRON_PARAMS, power, space=min(size÷10,30000))

    rand(sampler, round(Integer, size/3))
end
function new_kronecker(size, density)
    power = max(1, round(Integer, log(2*size/density)/log(8)))

    sampler = Kronecker_sampler(KRON_PARAMS, power, space=min(size÷10,30000))

    rand(sampler, round(Integer, size/3))
end


## HyperPA

function old_hyperpa(size::Integer=45000; name = "DAWN")
    output_directory = joinpath(@__DIR__, "..", "data", "hyper_pa")
    output_file = joinpath(output_directory, "$name.txt")
    mkpath(output_directory)
    rm(output_file, force=true)

    nodes::Integer = size ÷ 222 + 18
    nodes ≥ 200 && @warn "expected runtime on the order of $(round(Integer, (nodes/200)^2)) minute(s)\n"

    dir = dirname(@__DIR__)
    run(`python3 $dir/hyper_pa/hyper_preferential_attachment.py --name=$name --file_name=$name --num_nodes=$nodes --simplex_per_node_directory=$dir/hyper_pa/simplex\ per\ node --size_distribution_directory=$dir/hyper_pa/size\ distribution --output_directory=$output_directory`)
    isfile(output_file) ? [parse.(Int, split(line)) for line in readlines(output_file)] : Vector{Int}[]
end
function new_hyperpa_python(size::Integer=45000; name = "DAWN")
    output_directory = joinpath(@__DIR__, "..", "data", "hyper_pa")
    output_file = joinpath(output_directory, "$name.txt")
    mkpath(output_directory)
    rm(output_file, force=true)

    nodes::Integer = size ÷ 222 + 18

    dir = dirname(@__DIR__)
    run(`python3 $dir/FBD_hyper_pa/hyper_preferential_attachment.py --name=$name --file_name=$name --num_nodes=$nodes --simplex_per_node_directory=$dir/hyper_pa/simplex\ per\ node --size_distribution_directory=$dir/hyper_pa/size\ distribution --output_directory=$output_directory`)
    isfile(output_file) ? [parse.(Int, split(line)) for line in readlines(output_file)] : Vector{Int}[]
end
function new_hyperpa(size::Integer=45000)
    example(hyper_pa, size)
end
