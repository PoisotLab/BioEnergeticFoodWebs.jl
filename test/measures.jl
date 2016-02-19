module TestTrophicRank
    using Base.Test
    using befwm

    i = ones(10)
    @test_approx_eq befwm.shannon(i) 1.0

    i = zeros(100).+0,001
    i[1] = 1.0
    @test_approx_eq_eps befwm.shannon(i) 0.0 0.11

end
