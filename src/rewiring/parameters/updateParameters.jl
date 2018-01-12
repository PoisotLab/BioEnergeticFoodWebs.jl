function update_rewiring_parameters(p::Dict{Symbol,Any}, biomass)
  S = size(p[:A], 1)

  if p[:rewire_method] == :ADBM
    #assign new array
    p[:A] = ADBM(S,p,biomass)

    #update the parameters
    get_herbivores(p) #
    getW_preference(p) #
    get_efficiency(p)

  elseif p[:rewire_method] == :Gilljam
    #add extinction
    workingBiomass = deepcopy(biomass)
    deleteat!(workingBiomass,p[:extinctions])
    append!(p[:extinctions],findin(biomass,findmin(workingBiomass)[1]))
    sort!(p[:extinctions])

    #assign new array and update costs
    p[:A] , p = Gilljam(S,p,biomass)

    #update rewiring parameters
    if p[:preferenceMethod] == :specialist
      p = BioEnergeticFoodWebs.update_specialist_preference(p,S)
    end

    #update parameters
    get_herbivores(p)
    getW_preference(p)
    p[:w][find(p[:w] .== Inf)] = 1
    get_efficiency(p)

  elseif p[:rewire_method] == :stan
    #add extinction
    workingBiomass = deepcopy(biomass)
    deleteat!(workingBiomass,p[:extinctions])
    id_Ɛ = findin(biomass,findmin(workingBiomass)[1])
    append!(p[:extinctions], id_Ɛ)
    sort!(p[:extinctions])

    p[:A] = Staniczenko_rewire(p)
    get_herbivores(p)
    getW_preference(p)
    get_efficiency(p)

  end

  return p
end

function get_herbivores(p::Dict{Symbol,Any})
  #used internally by model_parameters and update_parameters
  S = size(p[:A], 1)
  is_herbivore = falses(S)
  # Identify herbivores
  # Herbivores consume producers
  for consumer in 1:S
    if !p[:is_producer][consumer]
      for resource in 1:S
        if p[:is_producer][resource]
          if p[:A][consumer, resource] == 1
            is_herbivore[consumer] = true
          end
        end
      end
    end
  end
  p[:is_herbivore] = is_herbivore
  #return(p)
end

function get_efficiency(p::Dict{Symbol,Any})
  #used internally by model_parameters and update_parameters
  S = size(p[:A], 1)
  # Efficiency matrix
  efficiency = zeros(Float64,(S, S))
  for consumer in 1:S
    for resource in 1:S
      if p[:A][consumer, resource] == 1
        if p[:is_producer][resource]
          efficiency[consumer, resource] = p[:e_herbivore]
        else
          efficiency[consumer, resource] = p[:e_carnivore]
        end
      end
    end
  end
  p[:efficiency] = efficiency
  #return(p)
end

function getW_preference(p::Dict{Symbol,Any})
  #used internally by model_parameters and update_parameters
  S = size(p[:A],1)
  generality = float(vec(sum(p[:A], 2)))

  if (p[:rewire_method] ∈ [:none, :ADBM, :stan])

    w = zeros(Float64,(S))
    for i in eachindex(generality)
      if generality[i] > 0.0
        w[i] = 1.0 / generality[i]
      end
    end
    w = w .*p[:A]

  else

    if p[:preferenceMethod] == :generalist
      w = zeros(Float64,(S))
      for i in eachindex(generality)
        if generality[i] > 0.0
          w[i] = 1.0 / generality[i]
        end
      end
      w = w .*p[:A]

    elseif p[:preferenceMethod] == :specialist
      w = zeros(Float64,(S,S))
      for i in eachindex(generality)
        if generality[i] > 0.0
          for j = 1:S
            if p[:A][i,j] == 1
              if p[:specialistPref][i] == j
                if generality[i] > 1
                  w[i,j] = p[:specialistPrefMag]
                else
                  w[i,j] = 1.0
                end
              else
                if generality[i] > 1
                  w[i,j] = (1 - p[:specialistPrefMag])/(generality[i]-1)
                else
                  w[i,j] = 1.0
                end
              end
            end
          end
        end
      end

    end # ifelse p[:preferenceMethod]

  end #ifelse p[:rewire_method]


  p[:w] = w
  #return(p)
end

function update_specialist_preference(p::Dict{Symbol,Any})
  S = size(p[:A], 1)
  #find those that have lost their specialistPref and are not extinct
  lost = falses(S)
  for i = 1:S
    if !p[:is_producer][i] && !in(i,p[:extinctions])
      if p[:A][i,p[:specialistPref][i]] == 0
        #assign new random species from diet
        p[:specialistPref][i] = sample(find(p[:A][i,:]))
      end
    else
      p[:specialistPref][i] = 0
    end
  end
  #return(p_r)
end
