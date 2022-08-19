# FBDCompare

[![Build Status](https://github.com/LilithHafner/FBDCompare.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/LilithHafner/FBDCompare.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/LilithHafner/FBDCompare.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/LilithHafner/FBDCompare.jl)

This package contains the code used to generate the data and figures for a forthcoming publication on FunctionalBallDropping. If you would like to verify or reproduce our work, you have come to the right place. If you would like to use our system in future work, please use [FunctionalBallDropping.jl](https://github.com/LilithHafner/FunctionalBallDropping.jl) instead.

To reproduce our results, run the following at a Julia REPL:

```jl
;pip3 install numpy scipy argparse
]add https://github.com/LilithHafner/FunctionalBallDropping.jl
]add https://github.com/LilithHafner/FBDCompare.jl

using FBDCompare

save_figures()
```

If that doesn't make sense or doesn't work for you, follow these more detailed instructions:

- Install Julia 1.7.3. Newer versions of Julia should work but may have different performance charactaristics.

- [Optional] Install Python 3.9.5, numpy, scipy, and argparse to compare with models implemented in python. Newer versions of python should also work. To install the packages, run `pip3 install numpy scipy argparse`.

- Launch julia. You should now see something like this:

```
               _
   _       _ _(_)_     |  Documentation: https://docs.julialang.org
  (_)     | (_) (_)    |
   _ _   _| |_  __ _   |  Type "?" for help, "]?" for Pkg help.
  | | | | | | |/ _` |  |
  | | |_| | | | (_| |  |  Version 1.7.3 (2022-05-06)
 _/ |\__'_|_|_|\__'_|  |  Official https://julialang.org/ release
|__/                   |

julia> 
```

- Press `]` to enter `Pkg` mode. Your prompt should now look like this: `(@v1.7) pkg> `

- [Optional] activate a new environment by typing `activate @reproduce_fbd`

- Add the FunctionalBallDropping package with `add https://github.com/LilithHafner/FunctionalBallDropping.jl`

- Add this package with `add https://github.com/LilithHafner/FBDCompare.jl`

- Exit `Pkg` mode by pressing backspace. Your prompt should now look like this: `julia> `

- Load this package by typing `using FBDCompare`

- Type `save_figures()` and press enter to reproduce a small version of the main figures and save them. This should take a few minutes.

- You should see a message "Saved figures to /Users/x/.julia/packages/FBDCompare/XgjIN/figures". Go there and find the figures! You can also call `FBDCompare.make_figure_1()` directly to make and display just figure 1 (same for make_figure_2..6()). The figure at the beginning of the paper is figure 0. Make it with `FBDCompare.make_figure_0()`.

- To get the full versions of the figures, run `save_figures(2)`. This will take many hours on most computers.
