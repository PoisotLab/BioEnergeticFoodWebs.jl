"""
**Is the matrix correctly formatted?**

A *correct* matrix has only 0 and 1, two dimensions, and is square.

This function returns nothing, but raises an `AssertionError` if one of the
conditions is not met.
"""
function check_food_web(A)
    @assert size(A)[1] == size(A)[2]
    @assert length(size(A)) == 2
    @assert sum(map(x -> x ∉ [0 1], A)) == 0
end

function check_initial_parameters(p)
    required_keys = [
        :Z,
        :vertebrates,
        :a_vertebrate,
        :a_invertebrate,
        :a_producer,
        :m_producer,
        :y_vertebrate,
        :y_invertebrate,
        :e_herbivore,
        :e_carnivore,
        :h,
        :Γ,
        :c,
        :r,
        :K
    ]
    for k in required_keys
        @assert get(p, k, nothing) != nothing
    end
end

"""
**Are the simulation parameters present?**

This function will make sure that all the required parameters are here,
and that the arrays and matrices have matching dimensions.
"""
function check_parameters(p)
    check_initial_parameters(p)

    required_keys = [
        :w,
        :efficiency,
        :y,
        :x,
        :a,
        :is_herbivore,
        :is_producer
    ]
    for k in required_keys
        @assert get(p, k, nothing) != nothing
    end
    @assert length(p[:is_producer]) == length(p[:is_herbivore])
    @assert size(p[:A]) == size(p[:efficiency])
    @assert length(p[:is_producer]) == size(p[:A], 1)
end
