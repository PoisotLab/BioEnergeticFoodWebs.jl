module BioEnergeticFoodWebs

using Distributions
using OrdinaryDiffEq, DiffEqCallbacks
using JSON
using JLD
using StatsBase
using Statistics
using LinearAlgebra

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
  temperature_size_rule,
  NoEffectTemperature,
  ExtendedEppley,
  ExponentialBA,
  ExtendedBA,
  Gaussian


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
include(joinpath(".", "rewiring/parameters/updateParameters.jl"))

include(joinpath(".", "temperature_dependence_functions.jl"))
include(joinpath(".", "temperature_size_rule_function.jl"))
include(joinpath(".", "biological_rates.jl"))

end
