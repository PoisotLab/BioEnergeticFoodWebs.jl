module TestTrophicRank
    using Base.Test
    using befwm

    A = nichemodel(10, 150)
    @assert size(A) == (10, 10)

end
