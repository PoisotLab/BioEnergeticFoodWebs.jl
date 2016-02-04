module TestCheckFoodWeb
    using befwm
    using Base.Test

    # A correct network will return nothing
    correct_network = [0 0 1 1; 1 1 0 0; 0 1 0 1; 1 1 0 0]
    @test check_food_web(correct_network) == nothing

    # A non-square network will fail
    non_square = [0 0 1; 0 1 1; 0 1 0; 1 0 0]
    @test_throws AssertionError check_food_web(non_square)

end
