"""

**ADBM Terms**

This function takes the parameters for the ADBM model and returns
the final terms used to determine feeding patterns. It is used internally by  ADBM().
"""

function getADBM_Terms(S::Int64,p::Dict{Symbol,Any},biomass::Vector{Float64})
  E = p[:e] .* p[:bodymass]
  if p[:Nmethod] == :original
    N = p[:n] .* (p[:bodymass] .^ p[:ni])
  elseif p[:Nmethod] == :biomass
    N = biomass
  end
  A = p[:a_adbm] * (p[:bodymass].^p[:aj]) * (p[:bodymass].^p[:ai])' # a * pred * prey
  for i = 1:S #for each prey
    A[:,i] = A[:,i] .* N[i]
  end
  λ = A
  if p[:Hmethod] == :ratio
    H = zeros(Float64,(S,S))
    ratios = (p[:bodymass] ./ p[:bodymass]')' #PREDS IN ROWS : PREY IN COLS
    for i = 1:S , j = 1:S
      if ratios[j,i] < p[:b]
      H[j,i] =  p[:h_adbm] / (p[:b] - ratios[j,i])
      else
      H[j,i] = Inf
      end
    end
  elseif p[:Hmethod] == :power
    H = p[:h_adbm] * (p[:bodymass].^p[:hj]) * (p[:bodymass].^p[:hi])' # h * pred * prey
  end

  adbmTerms = Dict{Symbol,Any}(
  :E => E,
  :λ => λ,
  :H => H)

  return(adbmTerms)
end

"""

**ADBM Feeding Links**

This function takes the terms calculated by getADBM_Terms() and uses them to determine the feeding
links of species j. Used internally by ADBM().
"""

function getFeedingLinks(S::Int64,E::Vector{Float64}, λ::Array{Float64}, H::Array{Float64},j)
  profit = E ./ H[j,:]
  profs = sortperm(profit,rev = true)

  λSort = λ[j,profs]
  HSort = H[j,profs]
  ESort = E[profs]

  λH = cumsum(λSort .* HSort)
  Eλ = cumsum(ESort .* λSort)

  λH[isnan.(λH)] = Inf
  Eλ[isnan.(Eλ)] = Inf

  cumulativeProfit = Eλ ./ (1 + λH)

  if all(0 .== cumulativeProfit)
  feeding = []
  else
  feeding = profs[1:maximum(find(cumulativeProfit .== maximum(cumulativeProfit)))]
  end

  #cumulativeProfit[end] = NaN
  #feeding = profs[(append!([true],cumulativeProfit[1:end-1] .< profitSort[2:end]))]
  return(feeding)
end


"""
**ADBM Web**

This function returns the food web based on the ADBM model of Petchey et al. 2008. The function
takes the paramteres created by rewire_parameters() and uses getADBM_Terms() and getFeedingLinks() to
detemine the web structure. This function is called using the callback to include rewiring into biomass simulations.
"""


function ADBM(S::Int64,p::Dict{Symbol,Any},biomass::Vector{Float64})
  adbmMAT = zeros(Int64,(S,S))
  adbmTerms = getADBM_Terms(S,p,biomass)
  E = adbmTerms[:E]
  λ = adbmTerms[:λ]
  H = adbmTerms[:H]
  for j = 1:S
    if !p[:is_producer][j]
      feeding = getFeedingLinks(S,E,λ,H,j)
      adbmMAT[j,feeding] = 1
    end
  end
  return(adbmMAT)
end
