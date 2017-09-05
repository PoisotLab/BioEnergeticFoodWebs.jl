function update_params(p::Dict{Symbol,Any},S::Int64,p_r::Dict{Symbol,Any},biomass)
  if p_r[:rewireMethod] == :ADBM
    #assign new array
    p[:A] = BioEnergeticFoodWebs.ADBM(S,p,biomass,p_r)

    #update the parameters
    p = getHerbivores(p,S) #
    p = getW_ADBM(p,S) #
    p = getEfficency(p,S)

  elseif p_r[:rewireMethod] == :Gilljam
    #add extinction
    workingBiomass = deepcopy(biomass)
    deleteat!(workingBiomass,p_r[:extinctions])
    append!(p_r[:extinctions],findin(biomass,findmin(workingBiomass)[1]))
    sort!(p_r[:extinctions])

    #assign new array and update costs
    p[:A] , p_r = BioEnergeticFoodWebs.Gilljam(S,p,biomass,p_r)

    #update rewiring parameters
    if p_r[:preferenceMethod] == :specialist
      p_r = BioEnergeticFoodWebs.updateSpecialistPref(p,p_r,S)
    end

    #update parameters
    p = getHerbivores(p,S)
    p = getW_preference(p,p_r,S)
    p[:w][find(p[:w] .== Inf)] = 1
    p = getEfficency(p,S)

  end
return((p,p_r))
end

function getHerbivores(p::Dict{Symbol,Any},S::Int64)
  # Identify herbivores
  # Herbivores consume producers
  for consumer in 1:S
    if !p[:is_producer][consumer]
      for resource in 1:S
        if p[:is_producer][resource]
          if p[:A][consumer, resource] == 1
            p[:is_herbivore][consumer] = true
          end
        end
      end
    end
  end
  return(p)
end

function getEfficency(p::Dict{Symbol,Any},S::Int64)
  # Efficiency matrix
  for consumer in 1:S
    for resource in 1:S
      if p[:A][consumer, resource] == 1
        if p[:is_producer][resource]
          p[:efficiency][consumer, resource] = p[:e_herbivore]
        else
          p[:efficiency][consumer, resource] = p[:e_carnivore]
        end
      else
        p[:efficiency][consumer, resource] = 0.0
      end
    end
  end
  return(p)
end

function getW_ADBM(p::Dict{Symbol,Any},S::Int64)
  generality = float(vec(sum(p[:A], 2)))
  for i in eachindex(generality)
    if generality[i] > 0.0
      for j = 1:S
        if p[:A][i,j] == 1
          p[:w][i,j] = 1.0 / generality[i]
        end
      end
    end
  end
  return(p)
end

function getW_preference(p::Dict{Symbol,Any},p_r::Dict{Symbol,Any},S::Int64)
  p[:w] = zeros(Float64,(S,S))
  generality = float(vec(sum(p[:A], 2)))
  if p_r[:preferenceMethod] == :generalist
    for i in eachindex(generality)
      if generality[i] > 0.0
        for j = 1:S
          if p[:A][i,j] == 1
            p[:w][i,j] = 1.0 / generality[i]
          end
        end
      end
    end
  elseif p_r[:preferenceMethod] == :specialist
    for i in eachindex(generality)
      if generality[i] > 0.0
        for j = 1:S
          if p[:A][i,j] == 1
            if p_r[:specialistPref][i] == j
              if generality[i] > 1
                p[:w][i,j] = p_r[:specialistPrefMag]
              else
                p[:w][i,j] = 1.0
              end
            else
              p[:w][i,j] = (1 - p_r[:specialistPrefMag])/(generality[i]-1)
            end
          end
        end
      end
    end
  end
  return(p)
end

function updateSpecialistPref(p::Dict{Symbol,Any},p_r::Dict{Symbol,Any},S::Int64)
  #find those that have lost thier specialistPref and are not extinct
  lost = falses(S)
  for i = 1:S
    if !p[:is_producer][i] && !in(i,p_r[:extinctions])
      if p[:A][i,p_r[:specialistPref][i]] == 0
        #assign new random species from diet
        p_r[:specialistPref][i] = sample(find(p[:A][i,:]))
      end
    else
      p_r[:specialistPref][i] = 0
    end
  end
  return(p_r)
end

function updateCost(p::Dict{Symbol,Any},p_r::Dict{Symbol,Any},S::Int64)

end
