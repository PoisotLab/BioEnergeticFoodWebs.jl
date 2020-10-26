function update_rewiring_parameters(parameters::Dict{Symbol,Any}, biomass, t)
  S = size(parameters[:A], 1)

  if parameters[:rewire_method] == :ADBM
    # Is there any extinction and/or rewiring happening?
    A = parameters[:A] #interaction matrix
    Anew = ADBM(S,parameters,biomass) #potentially new interaction  matrix
    if A != Anew #different matrices => rewired
      append!(parameters[:tmpA], [parameters[:A]]) #store the old matrix
      if parameters[:adbm_trigger] == :interval
        append!(parameters[:rewiretime], t) #store the time t whichrewiring happened
      end
    end
    #Is there any extinction?
    extinct = findall(biomass .< 100*eps())
    for i in extinct
      if i ∉ parameters[:extinctions]
        append!(parameters[:extinctions], i) ;
        append!(parameters[:extinctionstime], [(t, i)])
      end
    end
    sort!(parameters[:extinctions])

    #assign new array
    parameters[:A] = Anew

    #update the parameters
    get_herbivores(parameters) #
    getW_preference(parameters) #
    get_efficiency(parameters)

  elseif parameters[:rewire_method] ∈ [:Gilljam, :DS]
    #add extinction
    extinct = findall(biomass .< 100*eps())
    for i in extinct
      if i ∉ parameters[:extinctions]
        append!(parameters[:extinctions], i) ;
        append!(parameters[:extinctionstime], [(t, i)])
        append!(parameters[:tmpA], [parameters[:A]])
      end
    end
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

  elseif parameters[:rewire_method] ∈ [:stan, :DO]
    #add extinction
    extinct = findall(biomass .< 100*eps())
    for i in extinct
      if i ∉ parameters[:extinctions]
        append!(parameters[:extinctions], i) ;
        append!(parameters[:extinctionstime], [(t, i)])
        append!(parameters[:tmpA], [parameters[:A]])
      end
    end
    sort!(parameters[:extinctions])

    parameters[:A] = Staniczenko_rewire(parameters)
    get_herbivores(parameters)
    getW_preference(parameters)
    get_efficiency(parameters)

  else
    #add extinction
    extinct = findall(biomass .< 100*eps())
    for i in extinct
      if i ∉ parameters[:extinctions]
        append!(parameters[:extinctions], i) ;
        append!(parameters[:extinctionstime], [(t, i)])
        append!(parameters[:tmpA], [parameters[:A]])
      end
    end
    sort!(parameters[:extinctions])
  end

  return parameters
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
