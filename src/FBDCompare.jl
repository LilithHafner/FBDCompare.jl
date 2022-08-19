module FBDCompare

using FunctionalBallDropping

export ER, Kronecker, DCHSBM, HyperPA, save_figures

include("er.jl")

module Kronecker
    include("hyperkron.jl")
end

module DCHSBM
    include("DCHSBM/utils.jl")
    include("DCHSBM/omega.jl")
    include("DCHSBM/HSBM.jl")
end

include("evaluation/test_functions.jl")
include("evaluation/statistics.jl")

include("figures.jl")

end
