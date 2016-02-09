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
