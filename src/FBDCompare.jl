module FBDCompare

using FBD

export ER, Kronecker, DCHSBM, HyperPA

include("er.jl")

module Kronecker
    include("hyperkron.jl")
end

module DCHSBM
    include("DCHSBM/utils.jl")
    include("DCHSBM/omega.jl")
    include("DCHSBM/HSBM.jl")
end

include("hyper_pa.jl")

include("evaluation/test_functions.jl")
include("evaluation/statistics.jl")

include("figures.jl")

end
