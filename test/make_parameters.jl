module TestMakeParameters
    using befwm
    using Base.Test

    # Test the keyword interface
    correct_network = [0 0 1 1; 1 1 0 0; 0 1 0 1; 1 1 0 0]
    p = make_initial_parameters(correct_network, Z=2.0)
    @test p[:Z] == 2.0

    # Test if only a network is passed
    p2 = make_parameters(correct_network)
    @test p[:Z] == 1.0
    

end
