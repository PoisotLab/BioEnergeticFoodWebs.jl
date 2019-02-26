module TestSimulate
  using Test
  using BioEnergeticFoodWebs

  food_chain = [0 0 0;0 0 1; 1 0 0]
  p = model_parameters(food_chain)
  # Fail if the biomass vector has bad length
  @test_throws AssertionError simulate(p, rand(5))
  # Fail if stop < start
  @test_throws AssertionError simulate(p, rand(3), start=0, stop=-1)
end

module TestSimulateHandChecked
  using Test
  using BioEnergeticFoodWebs

  A = [0 1 0; 0 0 0; 0 1 0]
  p = model_parameters(A)
  b0 = vec([0.2 0.4 0.1])
  der = similar(b0)
  BioEnergeticFoodWebs.dBdt(der, b0, p, 0.0)
  # 0.1604888888888889,-0.504296,0.08024444444444445
  @test der[1] ≈ 0.160 atol = 0.01
  @test der[2] ≈ -0.5 atol = 0.01
  @test der[3] ≈ 0.080 atol = 0.01
end

module TestSimulateSanityCheck
  using Test
  using BioEnergeticFoodWebs
  using Statistics

  # A producer with no predation reaches K
  free_producers = [0 1 0 0; 0 0 1 0; 0 0 0 0; 0 0 0 0]
  parameters = free_producers |> model_parameters
  n = rand(4)

  s = simulate(parameters, n, start=0, stop=25)
  @test s[:B][end,4] ≈ parameters[:K] atol=0.002

  # Using system-wide regulation, producers with no consumption reach K / n
  A = zeros(Int64, (4, 4))
  parameters = model_parameters(A, productivity=:system)
  n = rand(4)
  s = simulate(parameters, n, start=0, stop=15)
  @test s[:B][end,4] ≈ parameters[:K]/4 atol=0.001

  # A consumer with a resource with 0 biomass goes extinct
  A = [0 1; 0 0]
  parameters = A |> model_parameters
  n = vec([1.0, 0.0])

  # s = simulate(p, n, start=0, stop=50, use=:stiff)
  # @test_approx_eq_eps s[:B][end,1] 0.0 0.001
  # @test_approx_eq_eps s[:B][end,2] 0.0 0.001

  s = simulate(parameters, n, start=0, stop=50)
  @test s[:B][end,1] ≈ .0 atol=0.001
  @test s[:B][end,2] ≈ 0.0 atol=0.001

  #test that stiff and nonstiff methods yield similar results
  A = [0 0 1 ; 0 0 1 ; 0 0 0]
  parameters = model_parameters(A)
  b = [.5, .5, .5]
  s_stiff = simulate(parameters, b, use = :stiff)
  meanB_stiff = mean(s_stiff[:B], dims = 1)
  s_nonstiff = simulate(parameters, b, use = :nonstiff)
  meanB_nonstiff = mean(s_stiff[:B], dims = 1)
  @test meanB_stiff == meanB_nonstiff
end


module TestSimulateProductivity
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

  # Using nutrient intake
  # parameters = model_parameters(A, productivity=:nutrients)
  # G = BioEnergeticFoodWebs.growthrate(parameters, ones(4), 1 ; c = parameters[:supply])
  # g = BioEnergeticFoodWebs.get_growth(ones(4), parameters ; c = parameters[:supply])[:growth]
  # @test G[1] ≈ 0.964 atol=0.001
  # @test g[1] == g[2] == g[3] == g[4]
end

module TestSimulateRewiring
  using Test
  using BioEnergeticFoodWebs


  #print info message when extinction occurs
  A = [0 0 0; 0 1 0; 0 0 0]
  A_after = Int.(zero(A))
  b = rand(3)

  # p = model_parameters(A, rewire_method = :Gilljam)
  # @test_warn "INFO: extinction of species 2" simulate(p, b)
  # @test parameters[:A] == A_after
  # p = model_parameters(A, rewire_method = :stan)
  # @test_warn "INFO: extinction of species 2" simulate(p, b)
  # @test_warn "INFO: extinction of species 2" simulate(p, b)
  # @test parameters[:A] == A_after
  # p = model_parameters(A, rewire_method = :ADBM)
  # @test_warn "INFO: extinction of species 2" simulate(p, b)
  # @test_warn "INFO: extinction of species 2" simulate(p, b)
  # @test parameters[:A] == A_after

  #don't print info message when rewire_method = :none, even when an extinction occurs
  # p = model_parameters(A)
  # @test_nowarn simulate(p, b)
  #don't print info message when rewire_method != :none but no extinction occurs
  # A = [0 0 0 ; 0 0 0 ; 0 0 0] #free producers
  # p = model_parameters(A, rewire_method = :stan)
  # b = rand(3)
  # @test_nowarn simulate(p, b)

end

module TestSimulateNP
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
