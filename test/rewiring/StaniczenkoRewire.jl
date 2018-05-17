module TestStaniczenkoRewire
    using BioEnergeticFoodWebs
    using Base.Test

    A = [0 0 1 1 ; 0 0 0 1 ; 0 0 0 0 ; 0 0 0 0]
    expected_rg = [0 0 0 0 ; 0 0 0 0 ; 0 0 0 0 ; 0 0 1 0]
    p = model_parameters(A, rewire_method = :stan)
    @test BioEnergeticFoodWebs.rewiring_graph(A) == expected_rg
    expected_pl = [0 0 0 0 ; 0 0 1 0 ; 0 0 0 0 ; 0 0 0 0]
    @test BioEnergeticFoodWebs.potential_newlinks(A, expected_rg, p) == expected_pl
    expected_newA = [0 0 0 0 ; 0 0 1 1 ; 0 0 0 0 ; 0 0 0 0]
    p[:extinctions] = [1]
    @test BioEnergeticFoodWebs.Staniczenko_rewire(p) == expected_newA
end
