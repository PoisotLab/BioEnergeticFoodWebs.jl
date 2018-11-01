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

module TestExponentialBA
    using BioEnergeticFoodWebs
    using Base.Test

    A = [0 1 0 ; 0 0 0 ; 0 1 0]
    p = model_parameters(A)
    BAfunction = exponential_BA(@NT(norm_constant = -16.54, activation_energy = -0.69, T0 = 293.15, β = -0.31))
    body_size_relative = p[:bodymass]
    testvalues = BAfunction(body_size_relative, 273.15, p)
    @test testvalues[1] ≈ -122.216 atol = 0.001
    @test testvalues[2] ≈ -122.216 atol = 0.001
    @test testvalues[3] ≈ -122.216 atol = 0.001
    @test length(testvalues) == size(A,1)

    body_size_relative = [10.0, 1.0, 10.0]
    testvalues = BAfunction(body_size_relative, 273.15, p)
    @test testvalues[1] ≈ -59.859 atol = 0.001
    @test testvalues[2] ≈ -122.216 atol = 0.001
    @test testvalues[3] == testvalues[1]
end

module TestExtendedBA
    using BioEnergeticFoodWebs
    using Base.Test

    A = [0 1 0 ; 0 0 0 ; 0 1 0]
    p = model_parameters(A)
    BAfunction = extended_BA(@NT(norm_constant = 3e8, activation_energy = 0.53, deactivation_energy = 1.15, T_opt = 298.15, β = -0.25))
    body_size_relative = p[:bodymass]
    testvalues = BAfunction(body_size_relative, 273.15, p)
    @test testvalues[1] ≈ 0.049 atol = 0.001
    @test testvalues[2] ≈ 0.049 atol = 0.001
    @test testvalues[3] ≈ 0.049 atol = 0.001
    @test length(testvalues) == size(A,1)

    body_size_relative = [10.0, 1.0, 10.0]
    testvalues = BAfunction(body_size_relative, 273.15, p)
    @test testvalues[1] ≈ 0.028 atol = 0.001
    @test testvalues[2] ≈ 0.049 atol = 0.001
    @test testvalues[3] == testvalues[1]
end

module TestGaussian
    using BioEnergeticFoodWebs
    using Base.Test

    A = [0 1 0 ; 0 0 0 ; 0 1 0]
    p = model_parameters(A)
    gaussianFunction = gaussian(@NT(shape = :hump, norm_constant = 0.5, range = 20, T_opt = 295, β = -0.25))
    body_size_relative = p[:bodymass]
    testvalues = gaussianFunction(body_size_relative, 273.15, p)
    @test testvalues[1] ≈ 0.276 atol = 0.001
    @test testvalues[2] ≈ 0.276 atol = 0.001
    @test testvalues[3] ≈ 0.276 atol = 0.001
    @test length(testvalues) == size(A,1)

    body_size_relative = [10.0, 1.0, 10.0]
    testvalues = gaussianFunction(body_size_relative, 273.15, p)
    @test testvalues[1] ≈ 0.155 atol = 0.001
    @test testvalues[2] ≈ 0.276 atol = 0.001
    @test testvalues[3] == testvalues[1]
end
