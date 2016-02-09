"""
**Niche model of food webs**

Takes a number of species `S` and a number of interactions `L`, and returns
a food web with predators in rows, and preys in columns.

"""
function nichemodel(S::Int64, L::Int64)
    @assert S > 1
    C = L/S^2
    @assert C < 1.0
    @assert C > 0.0

    # Beta distribution parameter
    β = 1/(2*C)-1.0

    # Pre-allocate the network
    A = zeros(Int64, (S, S))

    # Generate body size
    n = rand(S)
    
    # Pre-allocate centroids
    c = zeros(S)

    # Generate random ranges
    r = n .* rand(Beta(1.0, β), S)

    # Generate random centroids
    for s in 1:S
        c[i] = rand(Uniform(r[i]/2, n[i]), 1)
    end

    # The smallest species has a body size and range of 0
    n[n.==minimum(n)] = 0.0
    r[n.==minimum(n)] = 0.0

    for consumer in 1:S
        for resource in 1:S
            if n[resource] < c[consumer] + r[consumer]
                if n[resource] > c[consumer] - r[consumer]
                    A[consumer, resource] = 1
                end
            end
        end
    end

    return A

end
