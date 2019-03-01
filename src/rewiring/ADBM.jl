"""
**ADBM Terms**
This function takes the parameters for the ADBM model and returns
the final terms used to determine feeding patterns. It is used internally by  ADBM().
"""
function get_adbm_terms(S::Int64, parameters::Dict{Symbol,Any}, biomass::Vector{Float64})
  E = parameters[:e] .* parameters[:bodymass]
  if parameters[:Nmethod] == :original
    N = parameters[:n] .* (parameters[:bodymass] .^ parameters[:ni])
  elseif parameters[:Nmethod] == :biomass
    N = biomass
  end
  A_adbm = parameters[:a_adbm] * (parameters[:bodymass].^parameters[:aj]) * (parameters[:bodymass].^parameters[:ai])' # a * pred * prey
  for i = 1:S #for each prey
    A_adbm[:,i] = A_adbm[:,i] .* N[i]
  end
  λ = A_adbm
  if parameters[:Hmethod] == :ratio
    H = zeros(Float64,(S,S))
    ratios = (parameters[:bodymass] ./ parameters[:bodymass]')' #PREDS IN ROWS : PREY IN COLS
    for i = 1:S , j = 1:S
      if ratios[j,i] < parameters[:b]
      H[j,i] =  parameters[:h_adbm] / (parameters[:b] - ratios[j,i])
      else
      H[j,i] = Inf
      end
    end
  elseif parameters[:Hmethod] == :power
    H = parameters[:h_adbm] * (parameters[:bodymass].^parameters[:hj]) * (parameters[:bodymass].^parameters[:hi])' # h * pred * prey
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
function get_feeding_links(S::Int64,E::Vector{Float64}, λ::Array{Float64},
   H::Array{Float64},biomass::Vector{Float64},j)

  profit = E ./ H[j,:]
  # Setting profit of species with zero biomass  to -1.0
  # This prevents them being included in the profitSort
  profit[biomass .== 0.0] .= -1.0

  profs = sortperm(profit,rev = true)

  λSort = λ[j,profs]
  HSort = H[j,profs]
  ESort = E[profs]

  λH = cumsum(λSort .* HSort)
  Eλ = cumsum(ESort .* λSort)

  λH[isnan.(λH)] .= Inf
  Eλ[isnan.(Eλ)] .= Inf

  cumulativeProfit = Eλ ./ (1 .+ λH)

  if all(0 .== cumulativeProfit)
  feeding = []
  else
  feeding = profs[1:maximum(findall(cumulativeProfit .== maximum(cumulativeProfit)))]
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
function ADBM(S::Int64,parameters::Dict{Symbol,Any},biomass::Vector{Float64})
  adbmMAT = zeros(Int64,(S,S))
  adbmTerms = get_adbm_terms(S,parameters,biomass)
  E = adbmTerms[:E]
  λ = adbmTerms[:λ]
  H = adbmTerms[:H]
  for j = 1:S
    if !parameters[:is_producer][j]
      if biomass[j] > 0.0
        feeding = get_feeding_links(S,E,λ,H,biomass,j)
        adbmMAT[j,feeding] .= 1
      end
    end
  end
  return(adbmMAT)
end
