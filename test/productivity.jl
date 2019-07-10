module TestProductivity
  using Test
  using BioEnergeticFoodWebs

  A = zeros(Int64, (4, 4))
  n = rand(4)

  # Using system-wide regulation, producers with no consumption reach K / n
  parameters = model_parameters(A, productivity=:system)
  s = simulate(parameters, n, start=0, stop=15)
  @test s[:B][end,4] ≈ parameters[:K]/4 atol=0.001

  # Using species-wide regulation, producers with no consumption reach K
  parameters = model_parameters(A, productivity=:species)
  s = simulate(parameters, n, start=0, stop=15)
  @test s[:B][end,4] ≈ parameters[:K] atol=0.001

  # NOTE The following tests start with n = [1 1 1 1]

  # Using competitive regulation with α = 1 is neutral
  parameters = model_parameters(A, productivity=:competitive, α=1.0)
  s = simulate(parameters, ones(4), start=0, stop=15)
  @test s[:B][end,4] ≈ parameters[:K]/4 atol=0.001

  # Using competitive regulation with α > 1 is exclusive
  parameters = model_parameters(A, productivity=:competitive, α=1.05)
  s = simulate(parameters, ones(4), start=0, stop=15)
  @test s[:B][end,4] < parameters[:K]/4

  # Using competitive regulation with α < 1 is overyielding
  parameters = model_parameters(A, productivity=:competitive, α=0.95)
  s = simulate(parameters, ones(4), start=0, stop=15)
  @test s[:B][end,4] > parameters[:K]/4

  # Using competitive regulation with α = 0 is species-level regulation
  parameters = model_parameters(A, productivity=:competitive, α=0.0)
  s = simulate(parameters, ones(4), start=0, stop=15)
  @test s[:B][end,4] ≈ parameters[:K] atol=0.001

end

module TestNutrientIntake
  using Test
  using BioEnergeticFoodWebs

  A = [0 1 ; 0 0]
  b0 = [0.5, 0.5]
  c0 = [2.0, 2.0]
  k1 = [0.2]
  k2 = [0.4]

  p = model_parameters(A, productivity = :nutrients, K1 = k1, K2 = k2)

  @test BioEnergeticFoodWebs.growthrate(p, b0, 2, c = c0)[1] ≈ 2/2.4 atol=0.001
  netgrowth, G = BioEnergeticFoodWebs.get_growth(p, b0, c = c0)
  @test G[2] ≈ 0.41667 atol=0.001
  @test netgrowth[2] ≈ 0.3477 atol=0.001
  dN1dt, dN2dt = BioEnergeticFoodWebs.nutrientuptake(p, b0, c0, G)
  @test dN1dt ≈ 0.0833 atol=0.001
  @test dN2dt ≈ 0.2917 atol=0.001

  # When nutrient supply or turnover is 0, then producers growth is 0 and nutrient growth is 1

  p = model_parameters(A, productivity = :nutrients, K1 = k1, K2 = k2, supply = [0.0])
  s = simulate(p, b0, concentration = c0, stop = 1000)
  @test s[:B][end,1] ≈ .0 atol=1e-6
  @test s[:B][end,2] ≈ .0 atol=1e-6

  p = model_parameters(A, productivity = :nutrients, K1 = k1, K2 = k2, D = 0.0)
  s = simulate(p, b0, concentration = c0, stop = 1000)
  @test s[:B][end,1] ≈ .0 atol=1e-6
  @test s[:B][end,2] ≈ .0 atol=1e-6
  
end
