# FBDCompare

[![Build Status](https://github.com/LilithHafner/FBDCompare.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/LilithHafner/FBDCompare.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/LilithHafner/FBDCompare.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/LilithHafner/FBDCompare.jl)

This package contains the code used to generate the data and figures for a forthcoming publication on [FunctionalBallDropping](https://github.com/LilithHafner/FunctionalBallDropping.jl). If you would like to verify or reproduce our work, you have come to the right place. If you would like to use our system in future work, please use FunctionalBallDropping.jl instead.

Exmple usage
```jl
]add https://github.com/LilithHafner/FunctionalBallDropping.jl
]add https://github.com/LilithHafner/FBDCompare.jl

using FunctionalBallDropping, FBDCompare

save_figures()
```
