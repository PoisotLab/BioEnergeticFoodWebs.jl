function Gilljam(S::Int64,p::Dict{Symbol,Any},biomass::Vector{Float64})
  #create matrix to work on
  preferenceMat = deepcopy(p[:A])

  #add extinction to the new matrix
  preferenceMat[:,p[:extinctions]] = 0
  preferenceMat[p[:extinctions],:] = 0

  #where do new links need to be formed?
  newLinks = trues(3,S)
  #Sp that have no prey
  newLinks[1,:] = (sum(preferenceMat,2) .== 0)
  #Sp that are not producers
  newLinks[2,:] = .!p[:is_producer]
  #Sp that are extinction
  newLinks[3,p[:extinctions]] = false
  #rows where all conditions are met
  newLinks = find(mapslices(all,newLinks,1))

  if !isempty(newLinks)
    #code adds new links based on jaccard similariy
    for i in newLinks #for each Sp that needs a new link
      similarities = p[:similarity][newLinks][1] #get the similarity ranks
      deleteat!(similarities,findin(similarities,p[:extinctions])) # remove extinctions
      deleteat!(similarities,findin(similarities,find(sum(preferenceMat,2).==0,)))#remove Sp without prey

      newLink = sample(find(preferenceMat[similarities[end],:])) #choose link to make
      preferenceMat[i,newLink] = 1 #add  link to the new predation matrix
      p[:costMat][i,newLink] = p[:cost]
    end
  end
  return(preferenceMat,p)
end
