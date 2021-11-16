@testset "hyperkron" begin
    A, hedges = hyperkron_graph(kron_params(0.99, 0.2, 0.3, 0.05), 5)
    @test true
end
