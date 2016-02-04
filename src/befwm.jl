module befwm

    using Sundials

    export trophic_rank, check_food_web, dBdt

    # Includes
    include(joinpath(".", "trophic_rank.jl"))
    include(joinpath(".", "checks.jl"))
    include(joinpath(".", "dBdt.jl"))

end
