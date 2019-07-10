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
  bm = rand(4)

  s = simulate(parameters, bm, start=0, stop=25)
  @test s[:B][end,4] ≈ parameters[:K] atol=0.002

  # Using system-wide regulation, producers with no consumption reach K / n
  A = zeros(Int64, (4, 4))
  parameters = model_parameters(A, productivity=:system)
  bm = rand(4)
  s = simulate(parameters, bm, start=0, stop=15)
  @test s[:B][end,4] ≈ parameters[:K]/4 atol=0.001

  # A consumer with a resource with 0 biomass goes extinct
  A = [0 1; 0 0]
  parameters = A |> model_parameters
  bm = vec([1.0, 0.0])

  # s = simulate(p, n, start=0, stop=50, use=:stiff)
  # @test_approx_eq_eps s[:B][end,1] 0.0 0.001
  # @test_approx_eq_eps s[:B][end,2] 0.0 0.001

  s = simulate(parameters, bm, start=0, stop=50)
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
