module TestMakeParameters
    using befwm
    using Base.Test

    # Test the keyword interface
    correct_network = [0 0 1 1; 1 1 0 0; 0 1 0 1; 1 1 0 0]
    p = make_initial_parameters(A, Z=2.0)
    @test p[:Z] == 2.0
    

end
