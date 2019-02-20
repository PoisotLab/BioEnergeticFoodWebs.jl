"""
**Distance to a primary producer**

This function measures, for every species, its shortest path to a primary
producer using matrix exponentiation. A primary producer has a value of 1,
a primary consumer a value of 2, and so forth.

"""
function distance_to_producer(L::Array{Int64, 2})

    # We identify producers
    is_producer = vec(sum(L, dims = 2) .== 0)

    # Producers have a distance of 1
    d = zeros(Int64, length(is_producer))
    d[is_producer] .= 1

    # We work on a copy of the matrix with no self-loops
    K = copy(L)
    for i in eachindex(d)
        K[i ,i] = 0
    end

    # We loop as long as there are species with unknown distance
    i = 1
    while (i < length(d))|(sum(d) == 0)
        connected_at_length = (K^i * is_producer) .> 0
        d[(d .== 0) .* (connected_at_length)] .= i+1
        i = i+1
    end
    return d
end

"""
**Trophic rank**

Based on the average distance of preys to primary producers. Specifically, the
rank is defined as the average of the distance of preys to primary producers
(recursively). Primary producers always have a trophic rank of 1.

"""
function trophic_rank(L::Array{Int64, 2})
    # Average of positve elements, 0 otherwise
    nonzeromean = (x) -> maximum(x) == 0 ? 0 : mean(x[x.>0])
    d = distance_to_producer(L)
    dL = L .* d'
    TL = zeros(length(d))
    for i in eachindex(d)
        TL[i] = nonzeromean(dL[i,:]) + 1
    end
    return TL
end
