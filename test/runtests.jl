using Pkg
Pkg.add(url="https://github.com/LilithHafner/FBD")

using FBDCompare
using Test

ci = ("CI"=>"true") ∈ ENV

@testset "Kronecker" begin
    if ci
        Kronecker.generate_data()
        @test_broken false #=
https://github.com/LilithHafner/FBDCompare.jl/runs/4220893477?check_suite_focus=true
qt.qpa.xcb: could not connect to display
qt.qpa.plugin: Could not load the Qt platform plugin "xcb" in "" even though it was found.
This application failed to start because no Qt platform plugin could be initialized. Reinstalling the application may fix this problem.

Available platform plugins are: linuxfb, minimal, offscreen, vnc, xcb.

Aborted (core dumped)
connect: Connection refused
GKS: can't connect to GKS socket application


signal (11): Segmentation fault
=#  else
        Kronecker.plot()
    end
    @test true
end

@testset "HyperPA" begin
    HyperPA.jl_benchmark()
    HyperPA.jl_profile()
    HyperPA.jl_with_io()
    if ci
        @test_broken false #=
https://github.com/LilithHafner/FBDCompare.jl/runs/4221035425?check_suite_focus=true
Traceback (most recent call last):
  File "hyper_preferential_attachment.py", line 8, in <module>
    import numpy as np
ModuleNotFoundError: No module named 'numpy'
=#  else
        HyperPA.external()
    end
    @test true
end
