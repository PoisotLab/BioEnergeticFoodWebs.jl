module TestExtendedEppley
    using BioEnergeticFoodWebs
    using Base.Test

    A = [0 1 0 ; 0 0 0 ; 0 1 0]
    p = model_parameters(A)
    eppleyfunction = extended_eppley(@NT(maxrate_0=0.81, eppley_exponent=0.0631,T_opt=298.15, range = 35, β = -0.25))
    body_size_relative = p[:bodymass]
    testvalues = eppleyfunction(body_size_relative, 273.15, p)
    @test testvalues[1] ≈ -0.843 atol = 0.001
    @test testvalues[2] ≈ -0.843 atol = 0.001
    @test testvalues[3] ≈ -0.843 atol = 0.001
    @test length(testvalues) == size(A,1)

    body_size_relative = [10.0, 1.0, 10.0]
    testvalues = eppleyfunction(body_size_relative, 273.15, p)
    @test testvalues[1] ≈ -0.474 atol = 0.001
    @test testvalues[2] ≈ -0.843 atol = 0.001
    @test testvalues[3] == testvalues[1]
end
