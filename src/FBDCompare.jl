module FBDCompare

using FBD

export Kronecker, HyperPA

#include("hyper_pa.jl")

#include("kronecker.jl")

#include("er.jl")

#include("figure1.jl")

include("DCHSBM/utils.jl")
include("DCHSBM/omega.jl")
include("DCHSBM/HSBM.jl")

end
