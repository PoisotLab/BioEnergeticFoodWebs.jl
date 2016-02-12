"""
**Distance to a primary producer**

This function measures, for every species, its shortest path to a primary
producer using matrix exponentiation. A primary producer has a value of 1,
a primary consumer a value of 2, and so forth.

"""
function distance_to_producer(L::Array{Int64, 2})

    # We identify producers
    is_producer = vec(sum(L, 2) .== 0)

    # Producers have a distance of 1
    d = zeros(Int64, length(is_producer))
    d[is_producer] = 1
    
    # We work on a copy of the matrix with no self-loops
    K = copy(L)
    for i in eachindex(d)
        K[i ,i] = 0
    end

    # We loop as long as there are species with unknown distance
    i = 1
    while prod(d) == 0
        connected_at_length = (K^i * is_producer) .> 0
        d[(d .== 0) .* (connected_at_length)] = i+1
        i = i+1
    end
    return d
end

"""
**Trophic rank**

Based on the average distance of preys to primary producers.

"""
function trophic_rank(L::Array{Int64, 2})
    # Average of positve elements, 0 otherwise
    nonzeromean = (x) -> maximum(x) == 0 ? 0 : mean(x[x.>0])
    return vec(mapslices(nonzeromean, L .* distance_to_producer(L)', 2) .+ 1)
end

"""
**Alternate trophic rank
"""
function trophic_rank_alt(L::Array{Int64, 2})

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

