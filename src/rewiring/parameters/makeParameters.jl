"""

**Make Rewiring parameters**

This function serves as a wrapper to generate the parameters for the various rewiring mechanisms.

The only requred arguments are the rewireMethod and A (array) if the method from Gilljam et al. (2015) is used.
"""
function rewire_parameters(rewireMethod::Symbol ; e::Float64 = 1.0, a::Float64 = 0.0189, ai::Float64 = -0.491, aj::Float64 = -0.465,
  b::Float64 = 0.401, h::Float64 = 1.0, hi::Float64 = 1.0, hj::Float64 = 1.0, n::Float64 = 1.0, ni::Float64= -0.75,
  Hmethod::Symbol = :ratio, Nmethod::Symbol = :original, cost = 0.0::Float64,specialistPrefMag::Float64 = 0.9,preferenceMethod::Symbol = :generalist,
  A = 0)

  #check rewire method
  if rewireMethod ∉ [:ADBM,:none,:Gilljam]
    error("Invalid value for rewiremethod -- must be :ADBM, :none or :Gilljam")
  end

  if typeof(A) != Matrix{Int64}
    error("No Array Supplied")
  end

  #ADBM parameters
  if rewireMethod == :ADBM
    rewireP = adbm_parameters(e,a,ai,aj,b,h,hi,hj,n,ni)
    #check Hmethod
    if Hmethod ∈ [:ratio, :power]
      rewireP[:Hmethod] = Hmethod
    else
      error("Invalid value for Hmethod -- must be :ratio or :power")
    end
    # check Nmethod
    if Nmethod ∈ [:original, :biomass]
      rewireP[:Nmethod] = Nmethod
    else
      error("Invalid value for Nmethod -- must be :original or :biomass")
    end
    #add empty cost matrix
    S = size(A,2)
    rewireP[:costMat] = ones(Float64,(S,S))

  elseif rewireMethod == :Gilljam
    #preference parameters
    rewireP = preference_parameters(cost,specialistPrefMag,A)
    #check preferenceMethod
    if preferenceMethod ∈ [:generalist, :specialist]
      rewireP[:preferenceMethod] = preferenceMethod
      rewireP[:specialistPref] = getSpeciaistPref(rewireP,A)
    else
      error("Invalid value for preferenceMethod -- must be :generalist or :specialist")
    end
  end
  rewireP[:rewireMethod] = rewireMethod
  #check_rewiring_parameters(rewireP,rewireMethod)
  return(rewireP)
end



function adbm_parameters(e::Float64,a::Float64,ai::Float64,aj::Float64,
  b::Float64,h::Float64,hi::Float64,hj::Float64,n::Float64,ni::Float64)

  adbmParameters = Dict{Symbol,Any}(:e  => e,
                                    :a  => a,
                                    :ai => ai,
                                    :aj => aj,
                                    :b  => b,
                                    :h  => h,
                                    :hi => hi,
                                    :hj => hj,
                                    :n  => n,
                                    :ni => ni)
  return(adbmParameters)
end

function preference_parameters(cost::Float64,specialistPrefMag::Float64,A::Array{Int64})
  #Work out the jaccard similarity
  S = size(A,1)
  similarity = zeros(Float64,(S,S))
  for i = 1:S, j = 1:S
    if i == j
    similarity[i,j] = 0
    else
      X = find(A[i,:])
      Y = find(A[j,:])
      if length(X) == 0 && length(Y) == 0
        similarity[i,j] = 0
      else
        similarity[i,j] = size(intersect(X,Y),1) / size(union(X,Y),1)
      end
    end
  end

  similarityIndexes = Vector{Vector{Int}}(S)
  #convert to indexes
  for i = 1:S
    similarityIndexes[i] = sortperm(similarity[i,:])
  end

  preferenceParameters = Dict{Symbol,Any}(:similarity => similarityIndexes,
                                          :cost       => cost,
                                          :specialistPrefMag => specialistPrefMag,
                                          :extinctions => Array{Int,1}(),
                                          :costMat => ones(Float64,(S,S)))
  return(preferenceParameters)
end



function getSpeciaistPref(rewireP::Dict{Symbol,Any},A)
  specials = zeros(Int64,size(A,1))
  if rewireP[:preferenceMethod] == :specialist
    for pred = 1:size(A,2)
        prey = find(A[pred,:])
        if length(prey) > 0
          specials[pred] = sample(prey,1)[1]
        end
    end
  end
  return(specials)
end
