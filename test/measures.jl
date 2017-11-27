module TestMeasures
    using Base.Test
    using BioEnergeticFoodWebs

    # Internal functions
    i = ones(10)
    @test BioEnergeticFoodWebs.shannon(i) ≈ 1.0

    i = zeros(100).+0.001
    i[1] = 1.0
    @test BioEnergeticFoodWebs.shannon(i) ≈ 0.0 atol=0.2

    @test isnan(BioEnergeticFoodWebs.shannon(vec([1.0])))
    @test isnan(BioEnergeticFoodWebs.shannon(vec([-1.0])))


    i = ones(5)
    @test BioEnergeticFoodWebs.coefficient_of_variation(i) == 0.0

    i = collect(linspace(0.0, 1.0, 3))
    @test BioEnergeticFoodWebs.coefficient_of_variation(i) ≈ 1+1/(4*length(i))

    # Test the total biomass thing
    B = eye(10)
    A = eye(10)
    fake_params = Dict{Symbol, Any}(:A => A)
    s = Dict{Symbol, Any}(:B => B, :p => fake_params)
    @test total_biomass(s, last=10) == 1.0
    @test_throws AssertionError total_biomass(s, last=1000)
    @test population_biomass(s, last=10)[1] == 0.1

    # Population stability
    @test isnan(population_stability(s, last=1))
    @test population_stability(s, last=2) ≈ -1.59099  atol=0.01
    @test species_richness(s, last=1) == 1.0
    @test species_persistence(s, last=1) == 0.1

    # Foodweb evenness
    B = repmat([0 .5 0 .5], 5)
    s = Dict{Symbol, Any}(:B => B)
    @test foodweb_evenness(s, last = 2) == 1.00

    # Test when the total biomass is 0
    empty_p = Dict{Symbol, Any}(:B => zeros(10, 10))
    @test isnan(population_biomass(empty_p, last=2))
    @test isnan(population_stability(empty_p, last=2))
    @test isnan(total_biomass(empty_p, last=2))
    @test isnan(foodweb_evenness(empty_p, last=2))
    @test isnan(species_richness(empty_p, last = 2))

end
