module befwm

    using Sundials

    export trophic_rank,
        check_food_web,
        check_initial_parameters,
        check_parameters,
        dBdt,
        make_parameters,
        make_initial_parameters,
        simulate

    # Includes
    include(joinpath(".", "trophic_rank.jl"))
    include(joinpath(".", "checks.jl"))
    include(joinpath(".", "dBdt.jl"))
    include(joinpath(".", "make_parameters.jl"))
    include(joinpath(".", "simulate.jl"))

end
