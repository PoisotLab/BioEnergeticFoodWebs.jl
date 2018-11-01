module BioEnergeticFoodWebs

using Distributions
using OrdinaryDiffEq, DiffEqCallbacks
using JSON
using JLD
using StatsBase
using NamedTuples

export trophic_rank,
  model_parameters,
  #rewire_parameters,
  simulate,
  nichemodel,
  population_stability,
  total_biomass,
  population_biomass,
  foodweb_evenness,
  species_richness,
  species_persistence,
  producer_growth,
  nutrient_intake,
  consumer_intake,
  metabolism,
  adbm_model,
  no_effect_x,
  no_effect_r,
  no_effect_handlingt,
  no_effect_attackr,
  extended_eppley,
  exponential_BA,
  extended_BA,
  gaussian,
  temperature_size_rule


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
#include(joinpath(".", "rewiring/parameters/makeParameters.jl"))
include(joinpath(".", "rewiring/parameters/updateParameters.jl"))

include(joinpath(".", "temperature_dependence_functions.jl"))
include(joinpath(".", "temperature_size_rule.jl"))

end
