module TestCheckFoodWeb
    using BioEnergeticFoodWebs
    using Test

    # A correct network will return nothing
    correct_network = [0 0 1 1; 1 1 0 0; 0 1 0 1; 1 1 0 0]
    @test BioEnergeticFoodWebs.check_food_web(correct_network) == nothing

    # A non-square network will fail
    non_square = [0 0 1; 0 1 1; 0 1 0; 1 0 0]
    @test_throws AssertionError BioEnergeticFoodWebs.check_food_web(non_square)

    # A network with antyhing else than 0/1 will fail
    non_binary = [0 0 1 1; 1 1 0 0; 0 1 0 1; 1 1 2 0]
    @test_throws AssertionError BioEnergeticFoodWebs.check_food_web(non_binary)

end
