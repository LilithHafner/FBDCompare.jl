using Random: GLOBAL_RNG
using Distributions

function coin_flip_er(n, k, m, rng=GLOBAL_RNG)
    size = n^k
    p = m/size
    out = NTuple{k, Int}[]
    sizehint!(out, m+ceil(Integer,sqrt(m)))
    coin_flip_er_kernal(Iterators.product([1:n for _ in 1:k]...), rng, p, out)
    out
end
function coin_flip_er_kernal(iter, rng, p, out)
    for i in iter
        if rand(rng) < p
            push!(out, i)
        end
    end
    out
end

function grass_hop_er(n, k, m, rng=GLOBAL_RNG)
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
