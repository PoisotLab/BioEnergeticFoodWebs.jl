"""
** Connectance of a network**

Returns the connectance of a square matrix, defined as ``S/L^2``.

"""
function connectance(S::Int64, L::Int64)
    @assert S > 1
    C = L/S^2
    @assert C < 1.0
    @assert C > 0.0
    return C
end

function connectance(A::Array{Int64, 2})
    return connectance(size(A, 1), sum(A))
end

"""
**Niche model of food webs**

Takes a number of species `S` and a number of interactions `L`, and returns
a food web with predators in rows, and preys in columns. This function is
used internally by `nichemodel` called with a connectance.

"""
function nichemodel(S::Int64, L::Int64)

    C = connectance(S, L)

    # Beta distribution parameter
    β = 1/(2*C)-1.0

    # Pre-allocate the network
    A = zeros(Int64, (S, S))

    # Generate body size
    n = sort(rand(Uniform(0.0, 1.0), S))

    # Pre-allocate centroids
    c = zeros(Float64, S)

    # Generate random ranges
    r = n .* rand(Beta(1.0, β), S)

    # Generate random centroids
    for s in 1:S
        c[s] = rand(Uniform(r[s]/2, n[s]))
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

"""
**Niche model of food webs**

Takes a number of species `S` and a connectance `C`, and returns a food web
with predators in rows, and preys in columns. Note that the connectance is
first transformed into an integer number of interactions.

This function has two keyword arguments:

1. `tolerance` is the allowed error on tolerance (see below)

2. `toltype` is the type or error, and can be `:abs` (absolute) and `:rel`
(relative). Relative tolerance is the amount of error allowed, relative to the
desired connectance value. If the simulated network has a tolerance x, the
target connectance is c, then the relative error is |1-x/c|.

"""
function nichemodel(S::Int64, C::Float64; tolerance::Float64=0.05, toltype::Symbol=:abs)
    @assert C < 1.0
    @assert C > 0.0
    @assert tolerance > 0.0
    @assert toltype ∈ [:abs, :rel]
    L = round(Int64, C * S^2)
    A = nichemodel(S, L)
    if toltype == :abs
      tolfunc = (x) -> abs(x-C) < tolerance
    else
      tolfunc = (x) -> abs(1-x/C) < tolerance
    end
    while !(tolfunc(BioEnergeticFoodWebs.connectance(A)))
      A = nichemodel(S, L)
    end
    return A
end

"""
**Allometric Diet Breadth Model**

Take a number of producers (P) and a number of consumers (C) and return a food
web's adjacency matrix -- with predators in rows and preys in columns --
containing all the potential links that can be realised.

This function has one keyword arguments:

1. `bodymasses` is a vector of species bodymasses, if not provided,
the bodymasses will be drawn randomly from uniform distributions
[10e0, 10e6] for producers and [10e2, 10e12] for consumers.

"""

function adbm_internal(P::Int64, C::Int64; bm::Array{Float64,1} = Array{Float64,1}(0))
    if bm == Array{Float64,1}(0)
        bm_c = rand(Uniform(10e2, 10e12), C)
        bm_p = rand(Uniform(10e0, 10e6), P)
        bm = vcat(bm_p, bm_c)
    end
    @assert size(bm, 1) == P+C
    S = P + C
    E = bm
    N = bm .^ -0.75
    A = 0.0189 * (bm .^ -0.465) * (bm .^ -0.491)'
    for i = 1:S #for each prey
      A[:,i] = A[:,i] .* N[i]
    end
    λ = A
    H = zeros(Float64,(S,S))
    ratios = (bm ./ bm')'
    for i = 1:S , j = 1:S
        if ratios[j,i] < 0.401
            H[j,i] =  1 / (0.401 - ratios[j,i])
        else
            H[j,i] = Inf
        end
    end
    feeding = map(x -> get_feeding_links(S, E, λ, H, x), 1:S)
    adbmMAT = zeros(Int64,(S,S))
    map((x,y) -> adbmMAT[x,y] = 1, 1:S, feeding)

    return adbmMAT
end

"""
**Allometric Diet Breadth Model**

Take a number of producers (P), a number of consumers (C) and return a food
web's adjacency matrix with predators in rows, and preys in columns.

This function has one keyword arguments:

1. `bodymasses` is a vector of species bodymasses, if not provided,
the bodymasses will be drawn randomly from uniform distributions
[10e0, 10e6] for producers and [10e2, 10e12] for consumers.

"""
function adbm_model(P::Int64, C::Int64; bodymasses::Array{Float64,1} = Array{Float64,1}(0))
    potential_links = adbm_internal(P, C, bm = bodymasses)
    link_pos = hcat(findn(potential_links .== 1)...)
    link_pos = link_pos[link_pos[:,1] .> P,:]
    min_L = max(P, C)
    max_L = size(link_pos,1)
    L = Int(round(rand(Uniform(min_L, max_L))))
    new_links = link_pos[sample(1:size(link_pos,1), L, replace = false),:]
    A = zeros(potential_links)
    map((x,y) -> A[x,y] = 1, new_links[:,1], new_links[:,2])
    new_p = sum(sum(A,2).==0)
    unconnected = sum((sum(A,2).==0) .& (sum(A,1).==0)')
    while (new_p != P) .| (unconnected != 0)
        potential_links = adbm_internal(P, C, bm = bodymasses)
        link_pos = hcat(findn(potential_links .== 1)...)
        link_pos = link_pos[link_pos[:,1] .> P,:]
        min_L = max(P, C)
        max_L = size(link_pos,1)
        L = Int(round(rand(Uniform(min_L, max_L))))
        new_links = link_pos[sample(1:size(link_pos,1), L, replace = false),:]
        A = zeros(potential_links)
        map((x,y) -> A[x,y] = 1, new_links[:,1], new_links[:,2])
        new_p = sum(sum(A,2).==0)
        unconnected = sum((sum(A,2).==0) .& (sum(A,1).==0)')
    end

    return A
end
