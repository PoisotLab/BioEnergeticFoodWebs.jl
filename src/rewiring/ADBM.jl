"""
**ADBM parameters**
"""
function adbm_parameters(parameters, e, a_adbm, ai, aj, b, h_adbm, hi, hj, n, ni, Hmethod, Nmethod, consrate_adbm)
    parameters[:e] = e
    parameters[:a_adbm] = a_adbm
    parameters[:ai] = ai
    parameters[:aj] = aj
    parameters[:b] = b
    parameters[:h_adbm] = h_adbm
    parameters[:hi] = hi
    parameters[:hj] = hj
    parameters[:n] = n
    parameters[:ni] = ni
    #check method for calculating consumption rates
    if consrate_adbm ∈ [:befwm, :adbm]
      parameters[:consrate_adbm] = consrate_adbm
    else
      error("Invalid value for consrate_adbm -- must be :befwm or :adbm")
    end
    #check Hmethod
    if Hmethod ∈ [:ratio, :power]
      parameters[:Hmethod] = Hmethod
    else
      error("Invalid value for Hmethod -- must be :ratio or :power")
    end
    # check Nmethod
    if Nmethod ∈ [:original, :allometric, :biomass, :density]
      parameters[:Nmethod] = Nmethod
    else
      error("Invalid value for Nmethod -- must be :allometric, :biomass, or :density")
    end
    # add empty cost matrix
    S = size(parameters[:A],2)
    parameters[:costMat] = ones(Float64,(S,S))
end


"""
**ADBM Terms**
This function takes the parameters for the ADBM model and returns
the final terms used to determine feeding patterns. It is used internally by  ADBM().
"""
function get_adbm_terms(S::Int64, parameters::Dict{Symbol,Any}, biomass::Vector{Float64})

  M = parameters[:bodymass]

  # energy content of resources
  E = parameters[:e] .* parameters[:bodymass]

  if parameters[:consrate_adbm] == :befwm 

    # The feeding rates come from the BEFW model and are mass-specific. 
    # If used with density they must be converted when using density

    A_adbm = parameters[:ar] #attack rate
    H = parameters[:ht] #handling time 

    if parameters[:Hmethod] == :ratio
      ratios = (parameters[:bodymass] ./ parameters[:bodymass]')' #PREDS IN ROWS : PREY IN COLS
      for i = 1:S , j = 1:S
        if ratios[j,i] < parameters[:b]
          H[j,i] =  H[j,i]
        else
          H[j,i] = Inf
        end
      end
    end

    if parameters[:Nmethod] ∈ [:allometric, :original]
      N = parameters[:n] .* (parameters[:bodymass] .^ parameters[:ni])
      A_adbm = A_adbm .* M'
      
    elseif parameters[:Nmethod] ∈ [:density]
      N = biomass ./ parameters[:bodymass]
      A_adbm = A_adbm .* M'

    else 
      N = biomass

    end

  elseif parameters[:consrate_adbm] == :adbm

    # get attack rate 
    A_adbm = parameters[:a_adbm] * (parameters[:bodymass].^parameters[:aj]) * (parameters[:bodymass].^parameters[:ai])' # a * pred * prey

    # get handling time
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

    # The feeding rates come from the ADB model and are individual-specific. 
    # If used with biomass they must be converted

    if parameters[:Nmethod] ∈ [:allometric, :original]
      N = parameters[:n] .* (parameters[:bodymass] .^ parameters[:ni])

    elseif parameters[:Nmethod] ∈ [:density]
      N = biomass ./ parameters[:bodymass]

    else
      N = biomass
      #mass-specific attack rate (because we multiply with the biomass of the resource to calculate encounter rate)
      A_adbm = A_adbm ./ (M') 

    end

  end

  #Encounter rate is attack rates * density
  for i = 1:S #for each prey
    A_adbm[:,i] = A_adbm[:,i] * N[i]
  end
  λ = A_adbm

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
function get_feeding_links(S::Int64,E::Array{Float64}, λ::Array{Float64}, H::Array{Float64}, biomass::Vector{Float64},j)

  profit = E ./ H[j,:]
  # Setting profit of species with zero biomass  to -1.0
  # This prevents them being included in the profitSort
  profit[vec(biomass .== 0.0)] .= -1.0

  profs = sortperm(profit,rev = true)

  λSort = λ[j,profs]
  HSort = H[j,profs]
  ESort = E[profs]

  λH = cumsum(λSort .* HSort)
  Eλ = cumsum(ESort .* λSort)

  λH[isnan.(λH)] .= Inf
  Eλ[isnan.(Eλ)] .= Inf

  cumulativeProfit = Eλ ./ (1 .+ λH)
  cumulativeProfit[isnan.(cumulativeProfit)] .= 0.0
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
