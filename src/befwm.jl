module befwm

    using Sundials
    using Distributions
    using ODE
    using JLD

    export trophic_rank,
        make_parameters,
        make_initial_parameters,
        simulate,
        nichemodel,
        population_stability,
        total_biomass,
        population_biomass

    # Includes
    include(joinpath(".", "trophic_rank.jl"))
    include(joinpath(".", "checks.jl"))
    include(joinpath(".", "dBdt.jl"))
    include(joinpath(".", "make_parameters.jl"))
    include(joinpath(".", "simulate.jl"))
    include(joinpath(".", "random.jl"))
    include(joinpath(".", "measures.jl"))

end
