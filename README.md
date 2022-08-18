# FBDCompare

[![Build Status](https://github.com/LilithHafner/FBDCompare.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/LilithHafner/FBDCompare.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/LilithHafner/FBDCompare.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/LilithHafner/FBDCompare.jl)

Exmple usage
```jl
]add https://github.com/LilithHafner/FBD.jl
]add https://github.com/LilithHafner/FBDCompare.jl

using FBD, FBDCompare

FBDCompare.SCALE[] = 0 # Use fewer, smaller trials for faster results

FBDCompare.save_figures()
```
