"""
**Create default parameters**

This function creates model parameters, based on a food web
matrix A. See documentation for more information. Specifically, the default values of the keyword parameters are:

| Parameter         | Default Value | Meaning                                                                                     |
|:------------------|:--------------|:--------------------------------------------------------------------------------------------|
| K                 | 1.0           | carrying capacity of producers                                                              |
| Z                 | 1.0           | consumer-resource body mass ratio                                                           |
| bodymass          | [0.0]         | default is to calculates masses from Z unless a vector of bodymass is passed                |
| dry_mass_293      | [0.0]         | dry masses at 20 degrees celsius                                                            |
| TSR_type          | :no_response  | temperature size rule: set the function for masses dependence to temperature, see docs      |
| vertebrates       | [false]       | metabolic status of species (invertebrates or ectotherm vertebrates)                        |
| r                 | 1.0           | growth rate of producers                                                                    |
| c                 | 0             | quantifies the predator interference                                                        |
| h                 | 1             | Hill coefficient                                                                            |
| e_carnivore       | 0.85          | assimilation efficiency of carnivores                                                       |
| e_herbivore       | 0.45          | assimilation efficiency of herbivores                                                       |
| y_invertebrate    | 8             | maximum consumption rate of invertebrate predators relative to their metabolic rate         |
| y_vertebrate      | 4             | maximum consumption rate of vertebrate predators relative to their metabolic rate           |
| Γ                 | 0.5           | half-saturation density                                                                     |
| α                 | 1.0           | interspecific competition relatively to intraspecific competition                           |
| scale_bodymass    | true          | whether to normalize body masses by the mass of the smallest producer                       |
| scale_growth      | false         | whether to normalize growth rates by the growth rate of the smallest producer               |
| scale_metabolism  | false         | whether to normalize metabolic rates by the growth rate of the smallest producer            |
| scale_maxcons     | false         | whether to normalize max. consumption rates by metabolic rates                              |
| productivity      | :species      | type of productivity regulation                                                             |
| dc                | x -> x .* 0.0 | density dependent mortality function for consumers                                          |
| dp                | x -> x .* 0.0 | density dependent mortality function for producers                                          |
| rewire_method     | :none         | method for rewiring the foodweb following extinction events                                 |
| adbm_trigger      | :extinction   | (ADBM) trigger for ADBM rewiring (on extinctions or periodic with :interval)                |
| adbm_interval     | 100           | (ADBM) Δt for periodic rewiring                                                             |
| e                 | 1             | (ADBM) Scaling constant for the net energy gain                                             |
| a_adbm            | 0.0189        | (ADBM) Scaling constant for the attack rate                                                 |
| ai                | -0.491        | (ADBM) Consumer specific scaling exponent for the attack rate                               |
| aj                | -0.465        | (ADBM) Resource specific scaling exponent for the attack rate                               |
| b                 | 0.401         | (ADBM) Scaling constant for handling time                                                   |
| h_adbm            | 1.0           | (ADBM) Scaling constant for handling time                                                   |
| hi                | 1.0           | (ADBM) Consumer specific scaling exponent for handling time                                 |
| hj                | 1.0           | (ADBM) Resource specific scaling constant for handling time                                 |
| n                 | 1.0           | (ADBM) Scaling constant for the resource density                                            |
| ni                | 0.75          | (ADBM) Species-specific scaling exponent for the resource density                           |
| Hmethod           | :ratio        | (ADBM) Method used to calculate the handling time                                           |
| Nmethod           | :original     | (ADBM) Method used to calculate the resource density                                        |
| cost              | 0.0           | (Gilljam) Rewiring cost (a consumer decrease in efficiency when exploiting novel resource)  |
| specialistPrefMag | 0.9           | (Gilljam) Strength of the consumer preference for 1 prey if `preferenceMethod = :specialist`|
| preferenceMethod  | :generalist   | (Gilljam) Scenarios with respect to prey preferences of consumers                           |
| D                 | 0.25          | (nutrient intake) global turnover rate                                                      |
| ν                 | [1.0, 0.5]    | (nutrient intake) conversion rates for nutrients                                            |
| K1                | [0.15]        | (nutient intake) species half saturation densities for nutrient 1                           |
| K2                | [0.15]        | (nutient intake) species half saturation densities for nutrient 2                           |
| T                 | 273.15        | (temperature dependence) temperature                                                        |
| growthrate        | NoEffectTemperature(:r) | Function used to calculate growth rate |
| metabolicrate     | NoEffectTemperature(:x) | Function used to calculate metabolic rate |
| handlingtime      | NoEffectTemperature(:handlintime) | Function used to calculate handling time (and max. consumption rate) |
| attackrate        | NoEffectTemperature(:attackrate) | Function used to calculate attack rate (and Γ) |

All of these values are passed as optional keyword arguments to the function.

~~~ julia
A = [0 1 1; 0 0 0; 0 0 0]
p = model_parameters(A, Z=100.0, productivity=:system)
~~~

The `productivity` keyword can be either `:species` (each species has an
independant carrying capacity equal to `K`), `:system` (the carrying capacity is
K divided by the number of primary producers), or `:competitive` (the species
compete with themselves at rate 1.0, and with one another at rate α).

It is possible for the user to specify a vector of species body-mass, called
`bodymass` -- please do pay attention to the fact that the default behavior is
to assume that primary producers have a bodymass equal to unity, since all
biological rates are expressed relatively. We do not perform any check on
whether or not the user-supplied body-mass vector is correct (mostly because
there is no way of defining correctness for vectors where body-mass of producers
are not equal to unity). It is possible to turn off the scaling (`scale_bodymass
= false`), in that case we strongly recommend setting `scale_growth = true` (
and possibly `scale_metabolism = true` and `scale_maxcons = true`).

The keyword `vertebrates` is an array of `true` or `false`
for every species in the matrix. If the vector is of size 1 (e.g. [false]),
all species will take this metabolic status. By default, all species are invertebrates.

A rewiring method can pe passed to specified if the foodweb should be rewired
following extinctions events, and the method that should be used to perform the
rewiring. This `rewire_method` keyword can be eighter `:none` (no rewiring),
`:ADBM` (allometric diet breadth model as described in Petchey
et al., 2008), `:DS` (rewiring mechanism used by Gilljam et al., 2015, based on diet
similarity) or `:DO` (rewiring mechanism used by Staniczenko et al, 2010, based
on diet overlap).

If `rewire_method`is `:ADBM` or `:DS`, additional keywords can be passed.
See the online documentation and the original references for more details.

Temperature dependence for metabolic rates and body masses can be implemented,
please check the documentation for more information.

"""
function model_parameters(A;
        K::Float64=1.0,
        Z::Float64=1.0,
        c::Float64=0.0,
        h::Number=1.0,
        e_carnivore::Float64=0.85,
        e_herbivore::Float64=0.45,
        α::Float64=1.0,
        productivity::Symbol=:species,
        bodymass::Array{Float64, 1}=[0.0],
        scale_bodymass::Bool=true,
        vertebrates::Array{Bool, 1}=[false],
        dc::Function= (x -> x .* 0.0),
        dp::Function= (x -> x .* 0.0),
        rewire_method::Symbol = :none,
        adbm_trigger::Symbol = :extinction,
        adbm_interval::Int64 = 100,
        e::Float64 = 1.0,
        a_adbm::Float64 = 0.0189,
        ai::Float64 = -0.491,
        aj::Float64 = -0.465,
        b::Float64 = 0.401,
        h_adbm::Float64 = 1.0,
        hi::Float64 = 1.0,
        hj::Float64 = 1.0,
        n::Float64 = 1.0,
        ni::Float64= -0.75,
        Hmethod::Symbol = :ratio,
        Nmethod::Symbol = :original,
        cost::Float64 = 0.0,
        specialistPrefMag::Float64 = 0.9,
        preferenceMethod::Symbol = :generalist,
        D::Float64 = 0.25,
        supply::Array{Float64, 1} = [4.0],
        υ::Array{Float64, 1} = [1.0, 0.5],
        K1::Array{Float64, 1} = [0.15],
        K2::Array{Float64, 1} = [0.15],
        T::Float64 = 273.15,
        handlingtime::Function = NoEffectTemperature(:handlingtime),
        attackrate::Function = NoEffectTemperature(:attackrate),
        metabolicrate::Function = NoEffectTemperature(:metabolism),
        growthrate::Function = NoEffectTemperature(:growth),
        scale_growth::Bool = false,
        scale_metabolism::Bool = false,
        scale_maxcons::Bool = false,
        dry_mass_293::Array{Float64, 1}=[0.0],
        TSR_type::Symbol = :no_response)

  check_food_web(A)

  # Step 1 -- create a dictionnary to store the parameters
  parameters = Dict{Symbol,Any}(
  :K              => K,
  :Z              => Z,
  :c              => c,
  :e_carnivore    => e_carnivore,
  :e_herbivore    => e_herbivore,
  :h              => h,
  :vertebrates    => falses(size(A)[1]),
  :A              => A,
  :α              => α,
  :TSR_type       => TSR_type,
  :dry_mass_293   => dry_mass_293,
  :T              => T
  )
  check_initial_parameters(parameters)

  # Step 2 -- vertebrates ?
  if length(vertebrates) > 1
    if length(vertebrates) == size(A, 1)
      parameters[:vertebrates] = vertebrates
    else
      error("when calling `model_parameters` with an array of values for `vertebrates`, there must be as many elements as rows/columns in the matrix")
    end
  end

  # Step 3 -- body mass and dry mass at 293 K
  parameters[:bodymass] = bodymass
  if length(parameters[:bodymass]) > 1
    if length(parameters[:bodymass]) != size(A, 1)
      error("when calling `model_parameters` with an array of values for `bodymass`, there must be as many elements as rows/columns in the matrix")
    end
  end

  parameters[:dry_mass_293] = dry_mass_293
  if length(parameters[:dry_mass_293]) > 1
    parameters[:dry_mass_293] = dry_mass_293
    if length(parameters[:dry_mass_293]) != size(A, 1)
      error("when calling `model_parameters` with an array of values for `dry_mass_293`, there must be as many elements as rows/columns in the matrix")
    end
  end

  # Step 4 -- TSR type
  if TSR_type ∈ [:no_response, :mean_aquatic, :mean_terrestrial, :maximum, :reverse, :no_response]
    parameters[:TSR_type] = TSR_type
  else
    error("Invalid value for TSR_type -- must be :no_response, :mean_aquatic, :mean_terrestrial, :maximum, :reverse, :no_response")
  end

  # Step 5 -- Identify producers
  is_producer = vec(sum(A, dims = 2) .== 0)
  parameters[:is_producer] = is_producer
  producers_richness = sum(is_producer)

  # Step 6 -- productivity type
  if productivity ∈ [:species, :system, :competitive, :nutrients]
    parameters[:productivity] = productivity
  else
    error("Invalid value for productivity -- must be :system, :species, :competitive or :nutrients")
  end

  # step 7 -- productivity parameters for the NP model
  if parameters[:productivity] == :nutrients
    parameters[:D] = D
    parameters[:supply] = supply
    if length(parameters[:supply]) > 1
      if length(parameters[:supply]) != 2
        error("when calling `model_parameters` with an array of values for `S` (nutrient supply), there must be as many elements as nutrients (2)")
      end
    else
      parameters[:supply] = repeat(supply, 2)
    end
    parameters[:υ] = υ
    if length(parameters[:υ]) != 2
        error("when calling `model_parameters` with an array of values for `υ` (conversion rates), there must be as many elements as nutrients (2)")
    end

    parameters[:K1] = K1
    parameters[:K2] = K2
    if length(parameters[:K1]) > 1
      if length(parameters[:K1]) != size(A, 1)
        error("when calling `model_parameters` with an array of values for `K1` (species half-saturation densities for nutrient 1), there must be as many elements as species")
      end
    else
      parameters[:K1] = is_producer .* K1
    end
    if length(parameters[:K2]) > 1
      if length(parameters[:K2]) != size(A, 1)
        error("when calling `model_parameters` with an array of values for `K2` (species half-saturation densities for nutrient 2), there must be as many elements as species")
      end
    else
      parameters[:K2] = is_producer .* repeat(K2, size(A, 1))
    end

  end

  # Step 8 -- rewire method

 if rewire_method ∈ [:DO, :DS, :stan, :none, :ADBM, :Gilljam, :ADBM_interval]
    parameters[:rewire_method] = rewire_method
    parameters[:extinctions] = []
    parameters[:extinctionstime] = []
    parameters[:tmpA] = []
 else
    error("Invalid method for rewiring -- must be :DO (alternatively :stan), :ADBM, :DS (alternatively :Gilljam) or :none")
 end

 if rewire_method == :ADBM
     if adbm_trigger ∈ [:extinction, :interval]
       parameters[:adbm_trigger] = adbm_trigger
       parameters[:adbm_trigger] == :interval ? parameters[:adbm_interval] = adbm_interval : nothing
       adbm_parameters(parameters, e, a_adbm, ai, aj, b, h_adbm, hi, hj, n, ni, Hmethod, Nmethod)
     else
       error("Invalid trigger for ADBM trigger, must be either :interval or :extinction")
     end
 elseif rewire_method ∈ [:Gilljam, :DS]
     gilljam_parameters(parameters, cost, specialistPrefMag, preferenceMethod)
 end
 check_rewiring_parameters(parameters, parameters[:rewire_method])

  # Setup some objects
  S = size(A)[1]
  parameters[:S] = S
  F = zeros(Float64, size(A))
  efficiency = zeros(Float64, size(A))
  M = zeros(Float64, S)
  x = zeros(Float64, S) # metabolic rate
  r = zeros(Float64, S) # producers growth rate
  attack_r = zeros(Float64, S) # attack rates
  handling_t = zeros(Float64, S) # handling times
  Γ = zeros(Float64, S) #B0, half saturation density
  TR = trophic_rank(A)
  parameters[:trophic_rank] = TR
  is_herbivore = falses(S)

  # Step 9 -- Identify herbivores (Herbivores consume producers)
  get_herbivores(parameters)

  # Step 10 -- Measure generality and extract the vector of 1/n
  getW_preference(parameters)

  # Step 11 -- Get the body mass
  temperature_size_rule(parameters)

  # Step 12 -- Growth rate
  m_producer = minimum(parameters[:bodymass][is_producer])
  parameters[:m_producer] = m_producer
  body_size_relative = parameters[:bodymass] ./ parameters[:m_producer]
  m = scale_bodymass ? body_size_relative : bodymass
  r = growthrate(m, T, parameters)
  rspp = r[sortperm(parameters[:bodymass])[1]]
  r_scaled = r ./ rspp
  parameters[:r] = scale_growth ? r_scaled : r

  # Step 13 -- Metabolic rate
  x = metabolicrate(m, T, parameters)
  x_scaled = x ./ rspp
  parameters[:x] = scale_metabolism ? x_scaled : x

  # Step 14 -- Handling time
  handling_t = handlingtime(m, T, parameters)
  parameters[:ht] = handling_t

  # Step 16 -- Maximum relative consumption rate
  y = 1 ./ handling_t
  parameters[:y] = scale_maxcons == true ? y ./ x : y

  # Step 15 -- Attack rate
  attack_r = attackrate(m, T, parameters)

  # Step 17 -- Half-saturation constant
  Γ = 1 ./ (attack_r .* handling_t)
  Γ[isnan.(Γ)] .= 0.0
  parameters[:Γ] = Γ

  # Step 18 -- Efficiency matrix
  get_efficiency(parameters)

  parameters[:Γh] = parameters[:Γ] .^ parameters[:h]
  parameters[:np] = sum(parameters[:is_producer])
  parameters[:ar] = attack_r

  # Step  19 -- Density dependent mortality
  parameters[:dc] = dc
  parameters[:dp] = dp

  check_parameters(parameters)

  return parameters
end

function get_herbivores(parameters::Dict{Symbol,Any})
  #used internally by model_parameters and update_parameters
  S = size(parameters[:A], 1)
  is_herbivore = falses(S)
  # Identify herbivores
  # Herbivores consume producers
  for consumer in 1:S
    if !parameters[:is_producer][consumer]
      for resource in 1:S
        if parameters[:is_producer][resource]
          if parameters[:A][consumer, resource] == 1
            is_herbivore[consumer] = true
          end
        end
      end
    end
  end
  parameters[:is_herbivore] = is_herbivore
  #return(p)
end

function get_efficiency(parameters::Dict{Symbol,Any})
  #used internally by model_parameters and update_parameters
  S = size(parameters[:A], 1)
  # Efficiency matrix
  efficiency = zeros(Float64,(S, S))
  for consumer in 1:S
    for resource in 1:S
      if parameters[:A][consumer, resource] == 1
        if parameters[:is_producer][resource]
          efficiency[consumer, resource] = parameters[:e_herbivore]
        else
          efficiency[consumer, resource] = parameters[:e_carnivore]
        end
      end
    end
  end
  parameters[:efficiency] = efficiency
  #return(p)
end

function getW_preference(parameters::Dict{Symbol,Any})
  #used internally by model_parameters and update_parameters
  S = size(parameters[:A],1)
  generality = float(vec(sum(parameters[:A], dims = 2)))

  if (parameters[:rewire_method] ∈ [:none, :ADBM, :stan, :DO])

    w = zeros(Float64,(S))
    for i in eachindex(generality)
      if generality[i] > 0.0
        w[i] = 1.0 / generality[i]
      end
    end
    w = w .*parameters[:A]

  else

    if parameters[:preferenceMethod] == :generalist
      w = zeros(Float64,(S))
      for i in eachindex(generality)
        if generality[i] > 0.0
          w[i] = 1.0 / generality[i]
        end
      end
      w = w .*parameters[:A]

    elseif parameters[:preferenceMethod] == :specialist
      w = zeros(Float64,(S,S))
      for i in eachindex(generality)
        if generality[i] > 0.0
          for j = 1:S
            if parameters[:A][i,j] == 1
              if parameters[:specialistPref][i] == j
                if generality[i] > 1
                  w[i,j] = parameters[:specialistPrefMag]
                else
                  w[i,j] = 1.0
                end
              else
                if generality[i] > 1
                  w[i,j] = (1 - parameters[:specialistPrefMag])/(generality[i]-1)
                else
                  w[i,j] = 1.0
                end
              end
            end
          end
        end
      end

    end # ifelse parameters[:preferenceMethod]

  end #ifelse parameters[:rewire_method]


  parameters[:w] = w
  #return(p)
end

function get_specialist_preferences(pr, A)
  specials = zeros(Int64,size(A,1))
  if pr[:preferenceMethod] == :specialist
    for pred = 1:size(A,2)
        prey = findall(x -> x!= 0, A[pred,:])
        if length(prey) > 0
          specials[pred] = sample(prey,1)[1]
        end
    end
  end
  return(specials)
end

function preference_parameters(cost, specialistPrefMag, A, preferenceMethod)
  #Work out the jaccard similarity
  S = size(A,1)
  similarity = zeros(Float64,(S,S))
  for i = 1:S, j = 1:S
    if i == j
    similarity[i,j] = 0
    else
      X = findall(x -> x != 0, A[i,:])
      Y = findall(x -> x != 0, A[j,:])
      if length(X) == 0 && length(Y) == 0
        similarity[i,j] = 0
      else
        similarity[i,j] = size(intersect(X,Y),1) / size(union(X,Y),1)
      end
    end
  end

  similarity_indexes = Vector{Vector{Int}}(undef, S)
  #convert to indexes
  for i = 1:S
    similarity_indexes[i] = sortperm(similarity[i,:])
  end

  preference_parameters = Dict{Symbol,Any}(:similarity => similarity_indexes,
                                          :cost       => cost,
                                          :specialistPrefMag => specialistPrefMag,
                                          #:extinctions => Array{Int,1}(),
                                          :costMat => ones(Float64,(S,S)),
                                          :preferenceMethod => preferenceMethod)
  return(preference_parameters)
end
