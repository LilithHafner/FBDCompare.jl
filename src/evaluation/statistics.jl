# for the DCHSBM representation
function linear_density(d_n::Tuple{AbstractDict{<:Integer, <:AbstractDict}, UnitRange{<:Integer}})
    d = d_n[1]
    edge_count = sum([sum(values(x)) for (k,x) in d])
    n = length(d_n[2])
    kmax = maximum(keys(d))
    possible_edges = sum([binomial(n,k) for k in 1:kmax])
    edge_count/possible_edges
end
function log_density(d_n::Tuple{AbstractDict{<:Integer, <:AbstractDict}, UnitRange{<:Integer}})
    size = hypergraphsize(d_n)
    size == 0 && return NaN
    n = length(d_n[2])
    log(size)/log(n)
end
function FBD.hypergraphsize(d_n::Tuple{AbstractDict{<:Integer, <:AbstractDict}, UnitRange{<:Integer}})
    sum([k*sum(values(x)) for (k,x) in d_n[1]])
end

# for the Kronecker representation
function linear_density(hedges::NTuple{3, <:AbstractVector{<:Integer}})
    edge_count = length(hedges[1])
    edge_count == 0 && return NaN
    n = maximum(maximum.(hedges))
    kmax = 3
    possible_edges = sum([binomial(n,k) for k in 1:kmax])
    edge_count/possible_edges
end
function log_density(hedges::NTuple{3, <:AbstractVector{<:Integer}})
    size = hypergraphsize(hedges)
    size == 0 && return NaN
    n = maximum(maximum.(hedges))
    log(size)/log(n)
end

# for the FBD representation
function linear_density(g::AbstractVector)
    edge_count = length(g)
    edge_count == 0 && return NaN
    n = maximum(maximum.(g))
    kmax = maximum(length.(g))
    possible_edges = sum([binomial(n,k) for k in 1:kmax])
    edge_count/possible_edges
end
function log_density(g::AbstractVector)
    size = hypergraphsize(g)
    size == 0 && return NaN
    n = maximum(maximum.(g))
    log(size)/log(n)
end
