module befwm

    using Sundials
    using Distributions
    using ODE

    export trophic_rank,
        distance_to_producer,
        check_food_web,
        check_initial_parameters,
        check_parameters,
        dBdt,
        make_parameters,
        make_initial_parameters,
        simulate,
        nichemodel,
        population_stability

    # Includes
    include(joinpath(".", "trophic_rank.jl"))
    include(joinpath(".", "checks.jl"))
    include(joinpath(".", "dBdt.jl"))
    include(joinpath(".", "make_parameters.jl"))
    include(joinpath(".", "simulate.jl"))
    include(joinpath(".", "random.jl"))
    include(joinpath(".", "measures.jl"))

end
