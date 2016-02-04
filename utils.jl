function trophic_rank(L)

    A = copy(L)
    
    # 2d matrix
    @assert length(size(A)) == 2
    # Square matrix
    @assert size(A)[1] == size(A)[2]
    
    richness = size(A)[1]

    # Determine basal species
    generality = vec(sum(A, 2)) # Sum on columns
    is_basal = map(x -> x == 0, generality)

    # Remove cannibalism
    for species in 1:richness
        A[species, species] = 0
    end
    

    B = A'
    B = B./vec(sum(B, 1))

    Q = B[!is_basal, !is_basal]
    Q = Q'

    # Inverse
    N = inv(eye(Q)-Q)

    non_prod_TL = (N * ones(size(N)[1])) .+ 1
    TL = ones(richness)
    TL[!is_basal] = non_prod_TL

    #=return TL[end:-1:1]=#
    return TL

end

## TESTS TODO move to a test suite
food_chain = [0 1 0; 0 0 1; 0 0 0]
@assert trophic_rank(food_chain) == vec([3.0 2.0 1.0])

omnivory = [0 1 1; 0 0 1; 0 0 0]
@assert trophic_rank(omnivory) == vec([3.0 2.0 1.0])

diamond = [0 1 1 0; 0 0 0 1; 0 0 0 1; 0 0 0 0]
@assert trophic_rank(diamond) == vec([4.0 2.0 2.0 1.0])

chain_four = [0 1 0 0; 0 0 1 0; 0 0 0 1; 0 0 0 0]
@assert trophic_rank(chain_four) == vec([4.0 3.0 2.0 1.0])

@assert trophic_rank(zeros((3, 3))) == ones(3)
