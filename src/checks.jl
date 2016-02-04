"""
Check that a matrix is correctly formatted. This means, square, with only
0 and 1, and two dimensions.
"""
function check_food_web(A)
    @assert size(A)[1] == size(A)[2]
    @assert length(size(A)) == 2
    @assert sum(map(x -> x ∉ [0 1], A)) == 0
end
