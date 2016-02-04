function check_food_web(A)
    @assert size(A)[1] == size(A)[2]
    @assert length(size(A)) == 2
    @assert sum(map(x -> x ∉ [0 1], A)) == 0
end
