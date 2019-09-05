module TestSimulateExtinctions
  using Test
  using BioEnergeticFoodWebs

  # basic model
  A = [1 0 0; 0 1 0; 0 0 0]
  p = model_parameters(A)
  b = rand(3)

  #default extinction threshold
  default_extinction_threshold = 1e-6
  tolerated_values = default_extinction_threshold * 0.1
  s = simulate(p, b)
  @test sum((s[:B][:,2] .< tolerated_values) .& (s[:B][:,2] .> 0.0)) == 0
  @test s[:p][:extinctions] == [1, 2]
  @test length(s[:p][:extinctionstime]) == 2

  #passed extinction threshold
  passed_extinction_threshold = 100*eps()
  tolerated_values = passed_extinction_threshold * 0.1
  s = simulate(p, b, extinction_threshold = passed_extinction_threshold)
  @test sum((s[:B] .< tolerated_values) .& (s[:B] .> 0.0)) == 0
  @test s[:p][:extinctions] == [1, 2]
  @test length(s[:p][:extinctionstime]) == 2

  #with nutrients
  p_nutrients = model_parameters(A, productivity = :nutrients)
  default_extinction_threshold = 1e-6
  tolerated_values = default_extinction_threshold * 0.1
  s_nutrients = simulate(p_nutrients, b)
  @test sum((s_nutrients[:B][:,2] .< tolerated_values) .& (s_nutrients[:B][:,2] .> 0.0)) == 0

  #nutrients and passed extinction threshold
  passed_extinction_threshold = 100*eps()
  tolerated_values = passed_extinction_threshold * 0.1
  s_nutrients = simulate(p_nutrients, b, extinction_threshold = passed_extinction_threshold)
  @test sum((s_nutrients[:B][:,2] .< tolerated_values) .& (s_nutrients[:B][:,2] .> 0.0)) == 0

end
