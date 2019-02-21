module TestMeasures
    using Test
    using BioEnergeticFoodWebs
    using LinearAlgebra

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

    i = collect(range(0.0, stop = 1.0, length = 3))
    @test BioEnergeticFoodWebs.coefficient_of_variation(i) ≈ 1+1/(4*length(i))

    # Test the total biomass thing
    B = Matrix{Float64}(I, 10, 10)
    A = Matrix{Float64}(I, 10, 10)
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
    B = repeat([0 .5 0 .5], 5)
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

# module TestSave
#     using Test
#     using BioEnergeticFoodWebs
#     using LinearAlgebra
#     using JLD
#     using JSON
#
#     A = [0 0 0 ; 0 0 0 ; 0 0 0]
#     b = rand(3)
#     p = model_parameters(A)
#     #default variable name and extension
#     def_vname = "befwm_simul"
#     def_ext = :jld
#     #test default arguments
#     cd(tempdir())
#     s = simulate(p,b)
#     # default file name
#     def_fname = "befwm_" * string(hash(s)) * ".jld"
#     BioEnergeticFoodWebs.save(s, as = def_ext)
#
#     # Test if the file is saved (under the default name)
#     @test isfile(def_fname)
#     # Test if the content is the same
#     sbis = load(def_fname, def_vname)
#     @test sbis == s
#
#     rm(def_fname)
#     # Test is it works with as = :JLD
#     ext = :JLD
#     BioEnergeticFoodWebs.save(s, as = ext)
#     @test isfile(def_fname)
#     sbis = load(def_fname, def_vname)
#     @test sbis == s
#     rm(def_fname)
#
#     # Test with .json
#     ext = :json
#     BioEnergeticFoodWebs.save(s, as = ext)
#     fname = "befwm_" * string(hash(s)) * ".json"
#     @test isfile(fname)
#     rm(fname)
#
#     # Test with .JSON
#     ext = :JSON
#     BioEnergeticFoodWebs.save(s, as = ext)
#     fname = "befwm_" * string(hash(s)) * ".json"
#     @test isfile(fname)
#     rm(fname)
#
# end
