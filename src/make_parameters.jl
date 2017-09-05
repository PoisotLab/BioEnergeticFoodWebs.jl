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
        a_invertebrate::Float64=0.314, a_producer::Float64=1.0, a_vertebrate::Float64=0.88,
        c::Float64=0.0, h::Number=1.0,
        e_carnivore::Float64=0.85, e_herbivore::Float64=0.45,
        m_producer::Float64=1.0,
        y_invertebrate::Float64=8.0, y_vertebrate::Float64=4.0,
        Γ::Float64=0.5, α::Float64=1.0,
        productivity::Symbol=:species,
        bodymass::Array{Float64, 1}=[0.0],
        vertebrates::Array{Bool, 1}=[false]
        )
    # Step 1 -- initial parameters
    p = make_initial_parameters(A,K=K,Z=Z,r=r,
                                a_invertebrate=a_invertebrate,a_producer=a_producer,a_vertebrate=a_vertebrate,
                                c=c, h=h, e_carnivore=e_carnivore, e_herbivore=e_herbivore,
                                m_producer=m_producer, y_invertebrate=y_invertebrate, y_vertebrate=y_vertebrate,
                                Γ=Γ
                                )
    p[:α] = α
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

    # Step 5 -- final parameters
    p = make_parameters(p)
    return p
end

"""
**Make initial parameters**

Used internally by `model_parameters`.
"""
function make_initial_parameters(A; K::Float64=1.0, Z::Float64=1.0, r::Float64=1.0,
                                  a_invertebrate::Float64=0.314, a_producer::Float64=1.0, a_vertebrate::Float64=0.88,
                                  c::Float64=0.0, h::Number=1.0,
                                  e_carnivore::Float64=0.85, e_herbivore::Float64=0.45,
                                  m_producer::Float64=1.0,
                                  y_invertebrate::Float64=8.0, y_vertebrate::Float64=4.0,
                                  Γ::Float64=0.5
                                  )
  check_food_web(A)
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
  :A              => A
  )
  check_initial_parameters(p)
  return p
end

"""
**Make the complete set of parameters**

This function will add simulation parameters, based on the output of
`make_initial_parameters`. Used internally by `model_parameters`.

"""
function make_parameters(p::Dict{Symbol,Any})
  A = p[:A]
  # Better safe than sorry, as the user can modify both of these values
  check_initial_parameters(p)
  check_food_web(A)

  # Setup some objects
  S = size(A)[1]
  F = zeros(Float64, size(A))
  efficiency = zeros(Float64, size(A))
  w = zeros(Float64, size(A))
  M = zeros(Float64, S)
  a = zeros(Float64, S)
  x = zeros(Float64, S)
  y = zeros(Float64, S)

  # Identify producers
  is_producer = vec(sum(A, 2) .== 0)
  producers_richness = sum(is_producer)
  is_herbivore = falses(S)

  # Identify herbivores
  # Herbivores consume producers
  for consumer in 1:S
    if ! is_producer[consumer]
      for resource in 1:S
        if is_producer[resource]
          if A[consumer, resource] == 1
            is_herbivore[consumer] = true
          end
        end
      end
    end
  end

  # Measure generality and extract the vector of 1/n
  generality = float(vec(sum(A, 2)))
  for i in 1:size(w,1), j in 1:size(w,2)
    if A[i,j] == 1
      w[i,j] = 1.0 / generality[i]
    end
  end

  # Get the body mass
  if length(p[:bodymass]) == 1
    M = p[:Z].^(trophic_rank(A).-1)
    p[:bodymass] = M
  end

  # Scaling constraints based on organism type
  a[p[:vertebrates]] = p[:a_vertebrate]
  a[!p[:vertebrates]] = p[:a_invertebrate]
  a[is_producer] = p[:a_producer]

  # Metabolic rate
  body_size_relative = p[:bodymass] ./ p[:m_producer]
  body_size_scaled = body_size_relative.^-0.25
  x = (a ./ p[:a_producer]) .* body_size_scaled

  # Assimilation efficiency
  y = zeros(S)
  y[p[:vertebrates]] = p[:y_vertebrate]
  y[!p[:vertebrates]] = p[:y_invertebrate]

  # Efficiency matrix
  for consumer in 1:S
    for resource in 1:S
      if A[consumer, resource] == 1
        if is_producer[resource]
          efficiency[consumer, resource] = p[:e_herbivore]
        else
          efficiency[consumer, resource] = p[:e_carnivore]
        end
      end
    end
  end


  p[:w] = w
  p[:efficiency] = efficiency
  p[:efficiency] = efficiency
  p[:y] = y
  p[:x] = x
  p[:a] = a
  p[:is_herbivore] = is_herbivore
  p[:is_producer] = is_producer
  p[:Γh] = p[:Γ]^p[:h]
  p[:np] = sum(p[:is_producer])

  check_parameters(p)
  return p

end
