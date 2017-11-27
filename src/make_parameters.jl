"""
**Create default parameters**

This function creates model parameters, based on a food web
matrix. Specifically, the default values are:

| Parameter      | Default Value | Meaning                                                                             |
|:---------------|:--------------|:------------------------------------------------------------------------------------|
| K              | 1.0           | carrying capacity of producers                                                      |
| Z              | 1.0           | consumer-resource body mass ratio                                                   |
| r              | 1.0           | growth rate of producers                                                            |
| a_invertebrate | 0.314         | allometric constant for invertebrate consumers                                      |
| a_producers    | 1.0           | allometric constant of producers                                                    |
| a_vertebrate   | 0.88          | allometric constant for vertebrate consumers                                        |
| c              | 0             | quantifies the predator interference                                                |
| h              | 1             | Hill coefficient                                                                    |
| e_carnivore    | 0.85          | assimilation efficiency of carnivores                                               |
| e_herbivore    | 0.45          | assimilation efficiency of herbivores                                               |
| m_producers    | 1             | body-mass of producers                                                              |
| y_invertebrate | 8             | maximum consumption rate of invertebrate predators relative to their metabolic rate |
| y_vertebrate   | 4             | maximum consumption rate of vertebrate predators relative to their metabolic rate   |
| Γ              | 0.5           | half-saturation density                                                             |
| α              | 1.0           | interspecific competition                                                           |
| productivity   | :species      | type of productivity regulation                                                     |

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

The final keyword is `vertebrates`, which is an array of `true` or `false`
for every species in the matrix. By default, all species are invertebrates.
"""

function model_parameters(A; K::Float64=1.0, Z::Float64=1.0, r::Float64=1.0,
        a_invertebrate::Float64=0.314, a_producer::Float64=1.0,
        a_vertebrate::Float64=0.88, c::Float64=0.0, h::Number=1.0,
        e_carnivore::Float64=0.85, e_herbivore::Float64=0.45,
        m_producer::Float64=1.0,
        y_invertebrate::Float64=8.0, y_vertebrate::Float64=4.0,
        Γ::Float64=0.5, α::Float64=1.0,
        productivity::Symbol=:species,
        bodymass::Array{Float64, 1}=[0.0],
        vertebrates::Array{Bool, 1}=[false], rewire_method = :none,
        e::Float64 = 1.0, a_adbm::Float64 = 0.0189, ai::Float64 = -0.491,
        aj::Float64 = -0.465, b::Float64 = 0.401, h_adbm::Float64 = 1.0,
        hi::Float64 = 1.0, hj::Float64 = 1.0, n::Float64 = 1.0,
        ni::Float64= -0.75, Hmethod::Symbol = :ratio,
        Nmethod::Symbol = :original, cost::Float64 = 0.0,
        specialistPrefMag::Float64 = 0.9,
        preferenceMethod::Symbol = :generalist)

  BioEnergeticFoodWebs.check_food_web(A)

  # Step 1 -- create a dictionnary to store the parameters
  p = Dict{Symbol,Any}(
  :K              => K,
  :Z              => Z,
  :a_invertebrate => a_invertebrate,
  :a_producer     => a_producer,
  :a_vertebrate   => a_vertebrate,
  :c              => c,
  :e_carnivore    => e_carnivore,
  :e_herbivore    => e_herbivore,
  :h              => h,
  :m_producer     => m_producer,
  :r              => r,
  :vertebrates    => falses(size(A)[1]),
  :y_invertebrate => y_invertebrate,
  :y_vertebrate   => y_vertebrate,
  :Γ              => Γ,
  :A              => A,
  :α              => α
  )
  BioEnergeticFoodWebs.check_initial_parameters(p)

  # Step 2 -- vertebrates ?
  if length(vertebrates) > 1
    if length(vertebrates) == size(A, 1)
      p[:vertebrates] = vertebrates
    else
      error("when calling `model_parameters` with an array of values for `vertebrates`, there must be as many elements as rows/columns in the matrix")
    end
  end

  # Step 3 -- body mass
  p[:bodymass] = bodymass
  if length(p[:bodymass]) > 1
    if length(p[:bodymass]) != size(A, 1)
      error("when calling `model_parameters` with an array of values for `bodymass`, there must be as many elements as rows/columns in the matrix")
    end
  end

  # Step 4 -- productivity type
  if productivity ∈ [:species, :system, :competitive]
    p[:productivity] = productivity
  else
    error("Invalid value for productivity -- must be :system, :species, or :competitive")
  end

  # Step 5 -- rewire method

 if rewire_method ∈ [:stan, :none, :ADBM, :Gilljam]
    p[:rewire_method] = rewire_method
 else
    error("Invalid method for rewiring -- must be :stan, :ADBM, :Gilljam or :none")
 end

 if rewire_method == :ADBM
     adbm_par(p, e, a_adbm, ai, aj, b, h_adbm, hi, hj, n, ni, Hmethod, Nmethod)
 elseif rewire_method == :Gilljam
     gilljam_par(p, cost, specialistPrefMag, preferenceMethod)
 elseif rewire_method == :stan
     p[:extinctions] = Array{Int,1}()
 end
 check_rewiring_parameters(p, p[:rewire_method])

  # Setup some objects
  S = size(A)[1]
  F = zeros(Float64, size(A))
  efficiency = zeros(Float64, size(A))
  w = zeros(Float64, S)
  M = zeros(Float64, S)
  a = zeros(Float64, S)
  x = zeros(Float64, S)
  y = zeros(Float64, S)
  TR = trophic_rank(A)
  p[:trophic_rank] = TR

  # Step 6 -- Identify producers
  is_producer = vec(sum(A, 2) .== 0)
  p[:is_producer] = is_producer
  producers_richness = sum(is_producer)
  is_herbivore = falses(S)

  # Step 7 -- Identify herbivores (Herbivores consume producers)
  getHerbivores(p)

  # Step 8 -- Measure generality and extract the vector of 1/n
  getW_preference(p)

  # Step 9 -- Get the body mass
  if length(p[:bodymass]) == 1
    M = p[:Z].^(TR.-1)
    p[:bodymass] = M
  end

  # Step 10 -- Scaling constraints based on organism type
  a[p[:vertebrates]] = p[:a_vertebrate]
  a[.!p[:vertebrates]] = p[:a_invertebrate]
  a[is_producer] = p[:a_producer]

  # Step 11 -- Metabolic rate
  body_size_relative = p[:bodymass] ./ p[:m_producer]
  body_size_scaled = body_size_relative.^-0.25
  x = (a ./ p[:a_producer]) .* body_size_scaled

  # Step 12 -- Assimilation efficiency
  y = zeros(S)
  y[p[:vertebrates]] = p[:y_vertebrate]
  y[.!p[:vertebrates]] = p[:y_invertebrate]

  # Step 13 -- Efficiency matrix
  getEfficiency(p)

  # Final Step -- store the parameters in the dict. p
  #p[:w] = w
  #p[:efficiency] = efficiency
  p[:y] = y
  p[:x] = x
  p[:a] = a
  #p[:is_herbivore] = is_herbivore
  p[:Γh] = p[:Γ]^p[:h]
  p[:np] = sum(p[:is_producer])

  BioEnergeticFoodWebs.check_parameters(p)

  return p
end

function adbm_par(p, e, a_adbm, ai, aj, b, h_adbm, hi, hj, n, ni, Hmethod, Nmethod)
    p[:e] = e
    p[:a_adbm] = a_adbm
    p[:ai] = ai
    p[:aj] = aj
    p[:b] = b
    p[:h_adbm] = h_adbm
    p[:hi] = hi
    p[:hj] = hj
    p[:n] = n
    p[:ni] = ni
    #check Hmethod
    if Hmethod ∈ [:ratio, :power]
      p[:Hmethod] = Hmethod
    else
      error("Invalid value for Hmethod -- must be :ratio or :power")
    end
    # check Nmethod
    if Nmethod ∈ [:original, :biomass]
      p[:Nmethod] = Nmethod
    else
      error("Invalid value for Nmethod -- must be :original or :biomass")
    end
    #add empty cost matrix
    S = size(p[:A],2)
    p[:costMat] = ones(Float64,(S,S))
end

function getSpeciaistPref(pr, A)
  specials = zeros(Int64,size(A,1))
  if pr[:preferenceMethod] == :specialist
    for pred = 1:size(A,2)
        prey = find(A[pred,:])
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
      X = find(A[i,:])
      Y = find(A[j,:])
      if length(X) == 0 && length(Y) == 0
        similarity[i,j] = 0
      else
        similarity[i,j] = size(intersect(X,Y),1) / size(union(X,Y),1)
      end
    end
  end

  similarityIndexes = Vector{Vector{Int}}(S)
  #convert to indexes
  for i = 1:S
    similarityIndexes[i] = sortperm(similarity[i,:])
  end

  preferenceParameters = Dict{Symbol,Any}(:similarity => similarityIndexes,
                                          :cost       => cost,
                                          :specialistPrefMag => specialistPrefMag,
                                          :extinctions => Array{Int,1}(),
                                          :costMat => ones(Float64,(S,S)),
                                          :preferenceMethod => preferenceMethod)
  return(preferenceParameters)
end

function gilljam_par(p, cost, specialistPrefMag, preferenceMethod)
  #preference parameters
  rewireP = preference_parameters(cost, specialistPrefMag, p[:A], preferenceMethod)
  #check preferenceMethod
  if preferenceMethod ∈ [:generalist, :specialist]
    rewireP[:preferenceMethod] = preferenceMethod
    rewireP[:specialistPref] = getSpeciaistPref(rewireP,p[:A])
  else
    error("Invalid value for preferenceMethod -- must be :generalist or :specialist")
  end
  p[:similarity] = rewireP[:similarity]
  p[:specialistPrefMag] = rewireP[:specialistPrefMag]
  p[:extinctions] = rewireP[:extinctions]
  p[:preferenceMethod] = rewireP[:preferenceMethod]
  p[:cost] = rewireP[:cost]
  p[:costMat] = rewireP[:costMat]
  p[:specialistPref] = rewireP[:specialistPref]
end
