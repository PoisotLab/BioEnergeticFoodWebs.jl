module TestMakeParameters
    using BioEnergeticFoodWeb
    using Base.Test

    # Test the keyword interface
    correct_network = [0 1 0 0; 0 0 1 1; 0 0 0 0; 0 0 0 0]
    p = model_parameters(correct_network, Z=2.0)
    @test p[:Z] == 2.0

    # Test that producers, etc, are identified
    @test p[:is_producer][4] == true
    @test p[:is_producer][3] == true
    @test p[:is_producer][2] == false
    @test p[:is_producer][1] == false

    @test p[:is_herbivore][4] == false
    @test p[:is_herbivore][3] == false
    @test p[:is_herbivore][2] == true
    @test p[:is_herbivore][1] == false

    # Test the direct interface
    correct_network = [0 1 0 0; 0 0 1 1; 0 0 0 0; 0 0 0 0]
    p = BioEnergeticFoodWeb.model_parameters(correct_network, Z=2.0)
    @test p[:Z] == 2.0

    # Test that there is an exception if the vertebrates is of the wrong size
    wrong_vert = vec([true true true false false true true true false false])
    @test_throws ErrorException model_parameters(correct_network, vertebrates=wrong_vert)

    # Test that there the vertebrates can be passed
    right_vert = vec([true false true false])
    p = model_parameters(correct_network, vertebrates=right_vert)
    @test right_vert == p[:vertebrates]

end
