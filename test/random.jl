module TestTrophicRank
    using Base.Test
    using befwm

    @test_throws AssertionError nichemodel(10, 150)
    
    A = nichemodel(10, 50)
    @assert size(A) == (10, 10)

end
