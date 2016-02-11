module TestSimulate
    using Base.Test
    using befwm

    food_chain = [0 0 0;0 0 1; 1 0 0]
    p = make_initial_parameters(food_chain)
    p = make_parameters(p)
    # Fail if the biomass vector has bad length
    @test_throws AssertionError simulate(p, rand(5))
    # Fail if stop < start
    @test_throws AssertionError simulate(p, rand(3), start=0, stop=-1)
    # Fail if step <= 1
    @test_throws AssertionError simulate(p, rand(3), start=0, stop=1, steps=1)

end

module TestSimulateSanityCheck
    using Base.Test
    using befwm

    # A producer with no predation reaches K
    free_producers = [0 1 0 0; 0 0 1 0; 0 0 0 0; 0 0 0 0]
    p = free_producers |> make_initial_parameters |> make_parameters
    n = rand(4)

    s = simulate(p, n, start=0, stop=15, steps=500)
    @test_approx_eq_eps s[:B][16,4] p[:K] 0.001

    s = simulate(p, n, start=0, stop=15, steps=500, use=:Euler)
    @test_approx_eq_eps s[:B][16,4] p[:K] 0.001
    
    s = simulate(p, n, start=0, stop=10, steps=50, use=:ode23)
    @test_approx_eq_eps s[:B][16,4] p[:K] 0.001

    # A consumer with a resource with 0 biomass goes extinct
    A = [0 1; 0 0]
    p = A |> make_initial_parameters |> make_parameters
    n = vec([1.0, 0.0])
    s = simulate(p, n, start=0, stop=50, steps=500)
    @test_approx_eq_eps s[:B][end,1] 0.0 0.001
    @test_approx_eq_eps s[:B][end,2] 0.0 0.001
    s = simulate(p, n, start=0, stop=50, steps=500, use=:Euler)
    @test_approx_eq_eps s[:B][end,1] 0.0 0.001
    @test_approx_eq_eps s[:B][end,2] 0.0 0.001


end
