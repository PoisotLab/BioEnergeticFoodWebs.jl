module befwm

    using Sundials

    export trophic_rank, check_food_web

    # Includes
    include(joinpath(".", "trophic_rank.jl"))
    include(joinpath(".", "checks.jl"))

end
