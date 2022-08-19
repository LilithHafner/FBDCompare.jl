module ER

using Random: GLOBAL_RNG
using Distributions

function coin_flip(n, k, m, rng=GLOBAL_RNG)
    size = n^k
    p = m/size
    out = NTuple{k, Int}[]
    sizehint!(out, m+ceil(Integer,sqrt(m)))
    coin_flip_kernal(Iterators.product([1:n for _ in 1:k]...), rng, p, out)
    out
end
function coin_flip_kernal(iter, rng, p, out)
    for i in iter
        if rand(rng) < p
            push!(out, i)
        end
    end
    out
end

function coin_flip_with_duplicates(n, k, m, rng=GLOBAL_RNG)
    size = n^k
    d = Geometric(1/(1+m/size))
    out = NTuple{k, Int}[]
    sizehint!(out, m+ceil(Integer,sqrt(m)))
    coin_flip_kernal_with_duplicates(Iterators.product([1:n for _ in 1:k]...), rng, d, out)
    out
end
function coin_flip_kernal_with_duplicates(iter, rng, d, out)
    for i in iter
        for _ in 1:rand(rng, d)
            push!(out, i)
        end
    end
    out
end

function grass_hop(n, k, m, rng=GLOBAL_RNG)
    size = n^k
    p = m/size
    out = Vector{Int}[]
    sizehint!(out, m+ceil(Integer,sqrt(m)))
    d = Geometric(p)
    i = ones(Int, k)
    i[1] = 0
    while true
        skip = rand(rng, d)+1
        j = 1
        while skip > 0
            if j > k
                return out
            end
            skip += i[j]
            i[j] = (skip-1)%n+1
            skip = (skip-1)÷n
            j += 1
        end
        push!(out, copy(i))
    end
end

function grass_hop_with_duplicates(n, k, m, rng=GLOBAL_RNG)
    size = n^k
    p = m/(size+m)
    out = Vector{Int}[]
    sizehint!(out, m+ceil(Integer,sqrt(m)))
    d = Geometric(p)
    i = ones(Int, k)
    i[1] = 0
    while true
        skip = rand(rng, d)
        j = 1
        while skip > 0
            if j > k
                return out
            end
            skip += i[j]
            i[j] = (skip-1)%n+1
            skip = (skip-1)÷n
            j += 1
        end
        push!(out, copy(i))
    end
end

end
