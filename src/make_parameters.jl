"""
**Create default parameters**

This function creates model parameters, based on a food web
matrix A. Specifically, the default values of the keyword parameters are:

| Parameter         | Default Value | Meaning                                                                                     |
|:------------------|:--------------|:--------------------------------------------------------------------------------------------|
| K                 | 1.0           | carrying capacity of producers                                                              |
| Z                 | 1.0           | consumer-resource body mass ratio                                                           |
| r                 | 1.0           | growth rate of producers                                                                    |
| c                 | 0             | quantifies the predator interference                                                        |
| h                 | 1             | Hill coefficient                                                                            |
| e_carnivore       | 0.85          | assimilation efficiency of carnivores                                                       |
| e_herbivore       | 0.45          | assimilation efficiency of herbivores                                                       |
| y_invertebrate    | 8             | maximum consumption rate of invertebrate predators relative to their metabolic rate         |
| y_vertebrate      | 4             | maximum consumption rate of vertebrate predators relative to their metabolic rate           |
| Γ                 | 0.5           | half-saturation density                                                                     |
| α                 | 1.0           | interspecific competition relatively to intraspecific competition                           |
| productivity      | :species      | type of productivity regulation                                                             |
| rewire_method     | :none         | method for rewiring the foodweb following extinction events                                 |
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
| D                 | 0.25          | global turnover rate                                                                        |

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
`bodymass` -- please do pay attention to the fact that the model assumes that
primary producers have a bodymass equal to unity, since all biological rates are
expressed relatively. We do not perform any check on whether or not the
user-supplied body-mass vector is correct (mostly because there is no way of
defining correctness for vectors where body-mass of producers are not equal to
unity).

The keyword `vertebrates` is an array of `true` or `false`
for every species in the matrix. By default, all species are invertebrates.

A rewiring method can pe passed to specified if the foodweb should be rewired
following extinctions events, and the method that should be used to perform the
rewiring. This `rewire_method` keyword can be eighter `:none` (no rewiring),
`:ADBM` (allometric diet breadth model as described in Petchey
et al., 2008), `:Gilljam` (rewiring mechanism used by Gilljam et al., 2015, based on diet
similarity) or `:stan` (rewiring mechanism used by Staniczenko et al, 2010, based
on diet overlap).

If `rewire_method`is `:ADBM` or `:Gilljam`, additional keywords can be passed.
See the online documentation and the original references for more details.

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
        vertebrates::Array{Bool, 1}=[false],
        rewire_method = :none,
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
        dry_mass_293::Array{Float64, 1}=[0.0],
        TSR_type::Symbol = :no_response)

  check_food_web(A)

  # Step 1 -- create a dictionnary to store the parameters
  parameters = Dict{Symbol,Any}(
  :K              => K,
  :Z              => Z,
  #:a_invertebrate => a_invertebrate,
  #:a_producer     => a_producer,
  #:a_vertebrate   => a_vertebrate,
  :c              => c,
  :e_carnivore    => e_carnivore,
  :e_herbivore    => e_herbivore,
  :h              => h,
  #:r              => r,
  :vertebrates    => falses(size(A)[1]),
  #:y_invertebrate => y_invertebrate,
  #:y_vertebrate   => y_vertebrate,
  #:Γ              => Γ,
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

 if rewire_method ∈ [:stan, :none, :ADBM, :Gilljam]
    parameters[:rewire_method] = rewire_method
 else
    error("Invalid method for rewiring -- must be :stan, :ADBM, :Gilljam or :none")
 end

 if rewire_method == :ADBM
     adbm_parameters(parameters, e, a_adbm, ai, aj, b, h_adbm, hi, hj, n, ni, Hmethod, Nmethod)
 elseif rewire_method == :Gilljam
     gilljam_parameters(parameters, cost, specialistPrefMag, preferenceMethod)
 elseif rewire_method == :stan
     parameters[:extinctions] = Array{Int,1}()
 end
 check_rewiring_parameters(parameters, parameters[:rewire_method])

  # Setup some objects
  S = size(A)[1]
  parameters[:S] = S
  F = zeros(Float64, size(A))
  efficiency = zeros(Float64, size(A))
  M = zeros(Float64, S)
  #a = zeros(Float64, S)
  x = zeros(Float64, S) # metabolic rate
  #y = zeros(Float64, S)
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
  #if length(parameters[:bodymass]) == 1
    #M = parameters[:Z].^(TR.-1)
    #parameters[:bodymass] = M
  #end

  # Step 11 -- Scaling constraints based on organism type
  # a[parameters[:vertebrates]] = parameters[:a_vertebrate]
  # a[.!parameters[:vertebrates]] = parameters[:a_invertebrate]
  # a[is_producer] = parameters[:a_producer]

  # Step 12 -- Metabolic rate
  m_producer = minimum(parameters[:bodymass][is_producer])
  parameters[:m_producer] = m_producer
  body_size_relative = parameters[:bodymass] ./ parameters[:m_producer]
  # body_size_scaled = body_size_relative.^-0.25
  x = metabolicrate(body_size_relative, T, parameters)

  # Step 13 -- Growth rate
  r = growthrate(body_size_relative, T, parameters)

  # Step 14 -- Handling time
  handling_t = handlingtime(body_size_relative, T, parameters)
  parameters[:ht] = handling_t

  # Step 16 -- Maximum relative consumption rate
  y = 1 ./ handling_t

  # Step 15 -- Attack rate
  attack_r = attackrate(body_size_relative, T, parameters)

  # Step 17 -- Half-saturation constant
  Γ = 1 ./ (attack_r .* handling_t)
  Γ[isnan.(Γ)] .= 0.0
  parameters[:Γ] = Γ

  # Step 18 -- Efficiency matrix
  get_efficiency(parameters)

  # Final Step -- store the parameters in the dict. p
  #parameters[:efficiency] = efficiency
  parameters[:y] = y
  parameters[:x] = x
  #parameters[:a] = a
  #parameters[:is_herbivore] = is_herbivore
  parameters[:Γh] = parameters[:Γ] .^ parameters[:h]
  parameters[:np] = sum(parameters[:is_producer])
  parameters[:ar] = attack_r
  parameters[:r] = r


  check_parameters(parameters)

  return parameters
end

function adbm_parameters(parameters, e, a_adbm, ai, aj, b, h_adbm, hi, hj, n, ni, Hmethod, Nmethod)
    parameters[:e] = e
    parameters[:a_adbm] = a_adbm
    parameters[:ai] = ai
    parameters[:aj] = aj
    parameters[:b] = b
    parameters[:h_adbm] = h_adbm
    parameters[:hi] = hi
    parameters[:hj] = hj
    parameters[:n] = n
    parameters[:ni] = ni
    #check Hmethod
    if Hmethod ∈ [:ratio, :power]
      parameters[:Hmethod] = Hmethod
    else
      error("Invalid value for Hmethod -- must be :ratio or :power")
    end
    # check Nmethod
    if Nmethod ∈ [:original, :biomass]
      parameters[:Nmethod] = Nmethod
    else
      error("Invalid value for Nmethod -- must be :original or :biomass")
    end
    # add empty cost matrix
    S = size(parameters[:A],2)
    parameters[:costMat] = ones(Float64,(S,S))
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
                                          :extinctions => Array{Int,1}(),
                                          :costMat => ones(Float64,(S,S)),
                                          :preferenceMethod => preferenceMethod)
  return(preference_parameters)
end

function gilljam_parameters(parameters, cost, specialistPrefMag, preferenceMethod)
  #preference parameters
  rewireP = preference_parameters(cost, specialistPrefMag, parameters[:A], preferenceMethod)
  #check preferenceMethod
  if preferenceMethod ∈ [:generalist, :specialist]
    rewireP[:preferenceMethod] = preferenceMethod
    rewireP[:specialistPref] = get_specialist_preferences(rewireP,parameters[:A])
  else
    error("Invalid value for preferenceMethod -- must be :generalist or :specialist")
  end
  parameters[:similarity] = rewireP[:similarity]
  parameters[:specialistPrefMag] = rewireP[:specialistPrefMag]
  parameters[:extinctions] = rewireP[:extinctions]
  parameters[:preferenceMethod] = rewireP[:preferenceMethod]
  parameters[:cost] = rewireP[:cost]
  parameters[:costMat] = rewireP[:costMat]
  parameters[:specialistPref] = rewireP[:specialistPref]
end
