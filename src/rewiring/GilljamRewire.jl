"""
**gilljam_parameters**
"""
function gilljam_parameters(parameters, cost, specialistPrefMag, preferenceMethod)
  #preference parameters
  rewireP = preference_parameters(cost, specialistPrefMag, parameters[:A], preferenceMethod)
  #check preferenceMethod
  if preferenceMethod ∈ [:generalist, :specialist]
    rewireP[:preferenceMethod] = preferenceMethod
    rewireP[:specialistPref] = get_specialist_preferences(rewireP,parameters[:A])
  else
    error("Invalid value for preferenceMethod -- must be :generalist or :specialist")
  end
  parameters[:similarity] = rewireP[:similarity]
  parameters[:specialistPrefMag] = rewireP[:specialistPrefMag]
  #parameters[:extinctions] = rewireP[:extinctions]
  parameters[:preferenceMethod] = rewireP[:preferenceMethod]
  parameters[:cost] = rewireP[:cost]
  parameters[:costMat] = rewireP[:costMat]
  parameters[:specialistPref] = rewireP[:specialistPref]
end

"""
Diet similarity rewiring model
"""
function Gilljam(S::Int64, parameters::Dict{Symbol,Any}, biomass::Vector{Float64})
  #create matrix to work on
  preferenceMat = deepcopy(parameters[:A])

  #add extinction to the new matrix
  preferenceMat[:,parameters[:extinctions]] .= 0
  preferenceMat[parameters[:extinctions],:] .= 0

  #where do new links need to be formed?
  newLinks = trues(3,S)
  #Sp that have no prey
  newLinks[1,:] = (sum(preferenceMat, dims = 2) .== 0)
  #Sp that are not producers
  newLinks[2,:] = .!parameters[:is_producer]
  #Sp that are extinction
  for i in parameters[:extinctions]
      newLinks[3,i] = false
  end
  #rows where all conditions are met
  nl = mapslices(all,newLinks, dims = 1)
  newLinks = LinearIndices(nl)[findall(nl)]

  if !isempty(newLinks)
    #code adds new links based on jaccard similariy
    for i in newLinks #for each Sp that needs a new link
      similarities = parameters[:similarity][newLinks][1] #get the similarity ranks
      deleteat!(similarities,findall((in)(parameters[:extinctions]), similarities)) # remove extinctions
      spnoprey = LinearIndices(sum(preferenceMat, dims = 2))[findall(x -> x == 0, sum(preferenceMat, dims = 2))]
      deleteat!(similarities,findall((in)(spnoprey), similarities))#remove Sp without prey
      if !isempty(similarities) #TODO : find a cleaner way to do it
        newLink = sample(findall(x -> x == 1, preferenceMat[similarities[end],:])) #choose link to make
        preferenceMat[i,newLink] = 1 #add  link to the new predation matrix
        parameters[:costMat][i,newLink] = parameters[:cost]
      end
    end
  end
  return(preferenceMat,parameters)
end
