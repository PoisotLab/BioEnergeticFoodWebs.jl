module TestMakeParameters
    using befwm
    using Base.Test

    # Test the keyword interface
    correct_network = [0 1 0 0; 0 0 1 1; 0 0 0 0; 0 0 0 0]
    p = make_initial_parameters(correct_network, Z=2.0)
    @test p[:Z] == 2.0

    # Test that producers, etc, are identified
    p = make_parameters(p)

    @test p[:is_producer][4] == true
    @test p[:is_producer][3] == true
    @test p[:is_producer][2] == false
    @test p[:is_producer][1] == false
    
    @test p[:is_herbivore][4] == false
    @test p[:is_herbivore][3] == false
    @test p[:is_herbivore][2] == true
    @test p[:is_herbivore][1] == false

end
