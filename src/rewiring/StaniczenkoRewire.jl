"""
**Rewiring graph**

(Based on Staniczenko et al., 2010)
This function calculate the rewiring graph R from the adjacency matrix A.
The rewiring graph indicates overlap species:
R[i,j] = 1 if i and j share at least one predator AND i has at least one predator
that does not prey on j (i is in that case an overlap species).
Used internally by rewire().
"""
function rewiring_graph(parameters)
  S = size(parameters[:A], 1)
  R = convert(Array{Int64,2}, zeros(S, S)) #pre-allocate
  Atmp = deepcopy(parameters[:A])
  links = findall(!iszero, Atmp)
  consumers = [links[x][1] for x = 1:length(links)]
  unique_consumers = unique(consumers)
  resources = [links[x][2] for x = 1:length(links)]
  unique_resources = unique(resources)
  for r1 in unique_resources #for each unique resource
    c1 = consumers[resources .== r1]
    if length(c1) > 1
      for r2 in unique_resources
        c2 = consumers[resources .== r2]
        shared_cons = [x ∈ c2 for x = c1]
        (sum(shared_cons) > 0) & (sum(.!shared_cons) > 0) ? R[r1,r2] = 1 : nothing
      end
    end
  end
  return R
end

"""
**Potential predators**

(Based on Staniczenko et al., 2010)
This function identify the potential predators from the rewiring graph R.
Used internally by rewire().
"""
function potential_newlinks(A, R, parameters)
  S = size(A, 1)
  R_slices = [R[:, i] for i in 1:S]
  #identify "overlap species" = species that share at least one
  #consumer but also have 1 unshared consumer (results in consumers competition)
  overlap_species = map(x -> findall(x .== 1), R_slices)
  sp = convert(BitArray{1}, [overlap_species[x] != Int64[] for x in 1:size(overlap_species,1)])
  #identify overlap species consumers
  potential_predators = map(x -> A[:,x], overlap_species)[sp]
  is_link = map(x -> unique(findall(!iszero, x)), potential_predators)
  id_predators = map(x -> (i->i[1]).(x), is_link)
  #identify species consumers
  predators = map(x -> unique(findall(!iszero, x)), [A[:, i] for i in 1:S])[sp]
  #new consumers are those who consume the overlap species but not the species under focus
  new_pred = map((x,y) -> filter(x -> x ∉ y, x), id_predators, predators)
  #pre-allocate empty array
  P = convert(Array{Int64,2}, zeros(S, S))
  #return the identified new potential consumers
  map((x,y) -> P[x,y] .= 1, new_pred, findall(sp))
  TR = parameters[:trophic_rank]
  idx = findall(!iszero, P)
  idx_c = (i->i[1]).(idx)
  idx_r = (i->i[2]).(idx)
  map((x,y) -> if TR[x] <= TR[y]
                 P[x,y]=0
               end,
       idx_c, idx_r
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
function Staniczenko_rewire(parameters)
  S = size(parameters[:A], 1)
  A = parameters[:A]
  #identify extinct species
  Ɛ = parameters[:extinctions]
  #identify potential new links
  R = rewiring_graph(parameters)
  P = potential_newlinks(A, R, parameters)
  #keep those that contain one of the released preys
  released_links = findall(!iszero, A[Ɛ,:])
  released_preys = unique((i->i[2]).(released_links))
  [filter!(x -> x .!= i, released_preys) for i in Ɛ]
  all_possible_predators = map(x -> findall(!iszero, x), [P[:,i] for i in released_preys])
  trm = findall(x -> x != Int64[], all_possible_predators)
  filter!(x -> x != Int64[], all_possible_predators)
  released_preys = released_preys[trm]
  #draw a new predator for each released preys
  new_predator = map(sample, all_possible_predators)
  A_rewired = deepcopy(A)
  A_rewired[Ɛ, :] .= 0
  A_rewired[:, Ɛ] .= 0
  map((x,y) -> A_rewired[x,y] = 1, new_predator, released_preys)
  return A_rewired
end
