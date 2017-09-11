"""

**Rewiring graph**

(Based on Staniczenko et al., 2010)
This function calculate the rewiring graph R from the adjacency matrix A.
The rewiring graph indicates biologically plausible trophic rewiring.
R[i,j] = 1 if i and j share at least one predator AND i has at least one predator
that does not prey on j (i is in that case an overlap species).
Used internally by rewire().
"""
function rewiring_graph(A)
  S = size(A, 1)
  R = convert(Array{Int64,2}, zeros(S, S)) #pre-allocate
  Abis = copy(A)
  [Abis[i,i] = 0 for i in 1:S]
  A_slices = map(x -> Abis[:,x], collect(1:S))
  for i in 1:S
    shared_predators = map(x -> sum(A_slices[i] .== x .== 1) >= 1, A_slices)
    unshared_predators = map(x -> sum((A_slices[i] .== 1) & (x .== 0)) >= 1, A_slices)
    is_overlap = map((x,y) -> x .== y .== true, shared_predators, unshared_predators)
    idx = find(is_overlap .== true)
    R[i, idx] = 1
  end
  return R
end

"""

**Potential predators**

(Based on Staniczenko et al., 2010)
This function identify the potential predators from the rewiring graph R.
Used internally by rewire().
"""

function potential_newlinks(A, R, p)
  S = size(A, 1)
  R_slices = [R[:, i] for i in 1:S]
  #identify "overlap species" = species that share at least one
  #consumer but also have 1 unshared consumer (results in consumers competition)
  overlap_species = map(x -> find(x .== 1), R_slices)
  sp = convert(BitArray{1}, [overlap_species[x] != Int64[] for x in 1:size(overlap_species,1)])
  #identify overlap species consumers
  potential_predators = map(x -> A[:,x], overlap_species)[sp]
  id_predators = map(x -> unique(findn(x .== 1)[1]), potential_predators)
  #identify species consumers
  predators = map(x -> unique(find(x .== 1)), [A[:, i] for i in 1:S])[sp]
  #new consumers are those who consume the overlap species but not the species under focus
  new_pred = map((x,y) -> filter(x -> x ∉ y, x), id_predators, predators)
  #pre-allocate empty array
  P = convert(Array{Int64,2}, zeros(S, S))
  #return the identified new potential consumers
  map((x,y) -> P[x,y] = 1, new_pred, find(sp .== true))
  TR = p[:trophic_rank]
  idx = findn(P .== 1)
  map((x,y) -> if TR[x] <= TR[y]
                 P[x,y]=0
               else
                 P[x,y]=P[x,y]
               end,
       idx[1], idx[2]
  )
  return P
end

"""

**Rewire**

(Based on Staniczenko et al., 2010)
This function identify the resources that are released following an extinction event
and sample a new predator for each of them (when possible) from the matrix of
potential predators (from `potential_predators()`).
"""

function Staniczenko_rewire(p)
  S = size(p[:A], 1)
  A = p[:A]
  #identify extinct species
  Ɛ = p[:extinctions]
  #identify potential new links
  R = rewiring_graph(A)
  P = potential_newlinks(A, R, p)
  #keep those that contain one of the released preys
  released_preys = unique(findn(A[Ɛ,:])[2])
  [filter!(x -> x .!= i, released_preys) for i in Ɛ]
  all_possible_predators = map(x -> find(x .== 1), [P[:,i] for i in released_preys])
  trm = find(x -> x != Int64[], all_possible_predators)
  filter!(x -> x != Int64[], all_possible_predators)
  released_preys = released_preys[trm]
  #draw a new predator for each released preys
  new_predator = map(sample, all_possible_predators)
  A_rewired = deepcopy(A)
  A_rewired[Ɛ, :] = A_rewired[:, Ɛ] = 0
  map((x,y) -> A_rewired[x,y] = 1, new_predator, released_preys)
  return A_rewired
end
