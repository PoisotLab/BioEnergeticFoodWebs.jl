module BioEnergeticFoodWebs

using Distributions
using DifferentialEquations
using JSON
using JLD
using StatsBase

export trophic_rank,
  model_parameters,
  rewire_parameters,
  simulate,
  nichemodel,
  population_stability,
  total_biomass,
  population_biomass,
  foodweb_evenness,
  species_richness,
  species_persistence

# Includes
include(joinpath(".", "trophic_rank.jl"))
include(joinpath(".", "checks.jl"))
include(joinpath(".", "dBdt.jl"))
include(joinpath(".", "make_parameters.jl"))
include(joinpath(".", "simulate.jl"))
include(joinpath(".", "random.jl"))
include(joinpath(".", "measures.jl"))

include(joinpath(".", "rewiring/ADBM.jl"))
include(joinpath(".", "rewiring/GilljamRewire.jl"))
include(joinpath(".", "rewiring/StaniczenkoRewire.jl"))
include(joinpath(".", "rewiring/parameters/checkParameters.jl"))
include(joinpath(".", "rewiring/parameters/makeParameters.jl"))
include(joinpath(".", "rewiring/parameters/updateParameters.jl"))



end
