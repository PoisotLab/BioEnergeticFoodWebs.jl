module TestMeasures
    using Base.Test
    using befwm

    i = ones(10)
    @test_approx_eq befwm.shannon(i) 1.0

    i = zeros(100).+0.001
    i[1] = 1.0
    @test_approx_eq_eps befwm.shannon(i) 0.0 0.2


    i = ones(5)
    @test befwm.coefficient_of_variation(i) == 0.0

    i = collect(linspace(0.0, 1.0, 3))
    @test_approx_eq befwm.coefficient_of_variation(i) 1+1/(4*length(i))

end
