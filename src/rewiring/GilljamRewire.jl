function Gilljam(S::Int64,parameters::Dict{Symbol,Any},biomass::Vector{Float64})
  #create matrix to work on
  preferenceMat = deepcopy(parameters[:A])

  #add extinction to the new matrix
  preferenceMat[:,parameters[:extinctions]] = 0
  preferenceMat[parameters[:extinctions],:] = 0

  #where do new links need to be formed?
  newLinks = trues(3,S)
  #Sp that have no prey
  newLinks[1,:] = (sum(preferenceMat,2) .== 0)
  #Sp that are not producers
  newLinks[2,:] = .!parameters[:is_producer]
  #Sp that are extinction
  newLinks[3,parameters[:extinctions]] = false
  #rows where all conditions are met
  newLinks = find(mapslices(all,newLinks,1))

  if !isempty(newLinks)
    #code adds new links based on jaccard similariy
    for i in newLinks #for each Sp that needs a new link
      similarities = parameters[:similarity][newLinks][1] #get the similarity ranks
      deleteat!(similarities,findin(similarities,parameters[:extinctions])) # remove extinctions
      deleteat!(similarities,findin(similarities,find(sum(preferenceMat,2).==0,)))#remove Sp without prey
      if !isempty(similarities) #TODO : find a cleaner way to do it
        newLink = sample(find(preferenceMat[similarities[end],:])) #choose link to make
        preferenceMat[i,newLink] = 1 #add  link to the new predation matrix
        parameters[:costMat][i,newLink] = parameters[:cost]
      end
    end
  end
  return(preferenceMat,p)
end
