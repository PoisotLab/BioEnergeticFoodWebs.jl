function update_rewiring_parameters(parameters::Dict{Symbol,Any}, biomass)
  S = size(parameters[:A], 1)

  if parameters[:rewire_method] == :ADBM
    #assign new array
    parameters[:A] = ADBM(S,parameters,biomass)

    #update the parameters
    get_herbivores(parameters) #
    getW_preference(parameters) #
    get_efficiency(parameters)

  elseif parameters[:rewire_method] == :Gilljam
    #add extinction
    workingBiomass = deepcopy(biomass)
    deleteat!(workingBiomass,parameters[:extinctions])
    append!(parameters[:extinctions],findmin(workingBiomass)[2])
    sort!(parameters[:extinctions])

    #assign new array and update costs
    parameters[:A] , parameters = Gilljam(S,parameters,biomass)

    #update rewiring parameters
    if parameters[:preferenceMethod] == :specialist
      parameters = update_specialist_preference(parameters,S)
    end

    #update parameters
    get_herbivores(parameters)
    getW_preference(parameters)
    parameters[:w][(LinearIndices(parameters[:w]))[findall(x -> x .== Inf, parameters[:w])]] .= 1
    get_efficiency(parameters)

  elseif parameters[:rewire_method] == :stan
    #add extinction
    workingBiomass = deepcopy(biomass)
    deleteat!(workingBiomass,parameters[:extinctions])
    id_Ɛ = findmin(workingBiomass)[2]
    append!(parameters[:extinctions], id_Ɛ)
    sort!(parameters[:extinctions])

    parameters[:A] = Staniczenko_rewire(parameters)
    get_herbivores(parameters)
    getW_preference(parameters)
    get_efficiency(parameters)

  end

  return parameters
end

function get_herbivores(parameters::Dict{Symbol,Any})
  #used internally by model_parameters and update_parameters
  S = size(parameters[:A], 1)
  is_herbivore = falses(S)
  # Identify herbivores
  # Herbivores consume producers
  for consumer in 1:S
    if !parameters[:is_producer][consumer]
      for resource in 1:S
        if parameters[:is_producer][resource]
          if parameters[:A][consumer, resource] == 1
            is_herbivore[consumer] = true
          end
        end
      end
    end
  end
  parameters[:is_herbivore] = is_herbivore
  #return(p)
end

function get_efficiency(parameters::Dict{Symbol,Any})
  #used internally by model_parameters and update_parameters
  S = size(parameters[:A], 1)
  # Efficiency matrix
  efficiency = zeros(Float64,(S, S))
  for consumer in 1:S
    for resource in 1:S
      if parameters[:A][consumer, resource] == 1
        if parameters[:is_producer][resource]
          efficiency[consumer, resource] = parameters[:e_herbivore]
        else
          efficiency[consumer, resource] = parameters[:e_carnivore]
        end
      end
    end
  end
  parameters[:efficiency] = efficiency
  #return(p)
end

function getW_preference(parameters::Dict{Symbol,Any})
  #used internally by model_parameters and update_parameters
  S = size(parameters[:A],1)
  generality = float(vec(sum(parameters[:A], dims = 2)))

  if (parameters[:rewire_method] ∈ [:none, :ADBM, :stan])

    w = zeros(Float64,(S))
    for i in eachindex(generality)
      if generality[i] > 0.0
        w[i] = 1.0 / generality[i]
      end
    end
    w = w .*parameters[:A]

  else

    if parameters[:preferenceMethod] == :generalist
      w = zeros(Float64,(S))
      for i in eachindex(generality)
        if generality[i] > 0.0
          w[i] = 1.0 / generality[i]
        end
      end
      w = w .*parameters[:A]

    elseif parameters[:preferenceMethod] == :specialist
      w = zeros(Float64,(S,S))
      for i in eachindex(generality)
        if generality[i] > 0.0
          for j = 1:S
            if parameters[:A][i,j] == 1
              if parameters[:specialistPref][i] == j
                if generality[i] > 1
                  w[i,j] = parameters[:specialistPrefMag]
                else
                  w[i,j] = 1.0
                end
              else
                if generality[i] > 1
                  w[i,j] = (1 - parameters[:specialistPrefMag])/(generality[i]-1)
                else
                  w[i,j] = 1.0
                end
              end
            end
          end
        end
      end

    end # ifelse parameters[:preferenceMethod]

  end #ifelse parameters[:rewire_method]


  parameters[:w] = w
  #return(p)
end

function update_specialist_preference(parameters::Dict{Symbol,Any})
  S = size(parameters[:A], 1)
  #find those that have lost their specialistPref and are not extinct
  lost = falses(S)
  for i = 1:S
    if !parameters[:is_producer][i] && !in(i,parameters[:extinctions])
      if parameters[:A][i,parameters[:specialistPref][i]] == 0
        #assign new random species from diet
        parameters[:specialistPref][i] = sample(findall(!iszero, parameters[:A][i,:]))
      end
    else
      parameters[:specialistPref][i] = 0
    end
  end
  #return(p_r)
end
