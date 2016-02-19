module TestMeasures
    using Base.Test
    using befwm

    # Internal functions

    i = ones(10)
    @test_approx_eq befwm.shannon(i) 1.0

    i = zeros(100).+0.001
    i[1] = 1.0
    @test_approx_eq_eps befwm.shannon(i) 0.0 0.2

    @test isnan(befwm.shannon(vec([1.0])))
    @test isnan(befwm.shannon(vec([-1.0])))


    i = ones(5)
    @test befwm.coefficient_of_variation(i) == 0.0

    i = collect(linspace(0.0, 1.0, 3))
    @test_approx_eq befwm.coefficient_of_variation(i) 1+1/(4*length(i))


    # Test the total biomass thing
    B = eye(10)
    p = Dict{Symbol, Any}(:B => B)
    @test total_biomass(p, last=10) == 1.0
    @test_throws AssertionError total_biomass(p, last=1000)
    @test population_biomass(p, last=10)[1] == 0.1

end


