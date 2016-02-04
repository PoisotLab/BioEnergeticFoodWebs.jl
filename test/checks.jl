module TestChecks
    using befwm
    using Base.Test

    correct_network = [0 0 1 1; 1 1 0 0; 0 1 0 1; 1 1 0 0]
    check_food_web(correct_network)

end
