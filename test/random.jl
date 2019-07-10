module TestRandom
    using Test
    using BioEnergeticFoodWebs

    @test_throws AssertionError nichemodel(10, 150)

    A = nichemodel(10, 20)
    @test size(A, 1) == 10
    @test size(A, 2) == 10

    A = nichemodel(10, 0.12)
    @test size(A, 1) == 10
    @test size(A, 2) == 10

    A = nichemodel(10, 0.12, toltype=:rel)
    A = nichemodel(10, 0.12, toltype=:abs)

    A = [0 1; 1 0]
    @test BioEnergeticFoodWebs.connectance(A) == 0.5

end
