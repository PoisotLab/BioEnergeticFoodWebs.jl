"""
**Create default parameters**

This function creates initial parameters, based on a food web
matrix. Specifically, the default values are:


| Parameter | Value |
| ----      | ----- |
| K         | 1.0   |

There are two ways to modify the default values. First, by calling the
function and changing its output. For example

    A = [0 1 1; 0 0 0; 0 0 0]
    p = make_initial_parameters(A)
    p[:Z] = 100.0

Alternatively, every parameter can be used as a *keyword* argument when calling the function. For example

    A = [0 1 1; 0 0 0; 0 0 0]
    p = make_initial_parameters(A, Z=100.0)

The only exception is `vertebrates`, which has to be modified after this
function is called. By default, all of the species will be invertebrates.

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
    # TODO comment
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
        :A => A
        )
    check_initial_parameters(p)
    return p
end

function make_parameters(p)
    A = p[:A]
    # Better safe than sorry
    check_initial_parameters(p)
    check_food_web(A)

    # Setup some objects
    S = size(A)[1]
    F = zeros(Float64, size(A))
    efficiency = zeros(Float64, size(A))
    w = zeros(S)
    M = zeros(S)
    a = zeros(S)
    x = zeros(S)
    y = zeros(S)

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
    generality = vec(sum(A, 2))
    w = map(x -> x > 0 ? 1/x : 0, generality)

    # Get the body mass
    M = p[:Z].^(trophic_rank(A).-1)

    # Scaling constraints based on organism type
    a[p[:vertebrates]] = p[:a_vertebrate]
    a[!p[:vertebrates]] = p[:a_invertebrate]
    a[is_producer] = p[:a_producer]

    # Metabolic rate
    body_size_relative = M ./ p[:m_producer]
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
    p[:a]= a
    p[:is_herbivore] = is_herbivore
    p[:is_producer] = is_producer

    check_parameters(p)
    return p

end
