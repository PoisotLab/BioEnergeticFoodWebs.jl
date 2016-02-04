"""
Check that a matrix is correctly formatted. This means, square, with only
0 and 1, and two dimensions.
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
        :y_vertberate,
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
        println(get(p, symbol(eval(k)), nothing))
        @assert get(p, symbol(eval(k)), nothing) != nothing
    end
end

function check_parameters(p)
    # Users need only call this function
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
end
