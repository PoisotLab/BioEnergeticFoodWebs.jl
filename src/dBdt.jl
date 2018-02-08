"""
**Growth rate**

TODO
"""
function growthrate(p, b, i)
  # Default -- species-level regulation
  compete_with = b[i]
  effective_K = p[:K]
  # If regulation is system-wide (all species share K)
  if p[:productivity] == :system
    compete_with = b[i]
    effective_K = p[:K] / p[:np]
  end
  # If there is competition
  if p[:productivity] == :competitive
    compete_with = b[i]
    for j in eachindex(b)
      if (i != j) & (p[:is_producer][j])
        compete_with += p[:α] * b[j]
      end
    end
    effective_K = p[:K]
  end
  return (1.0 - compete_with / effective_K)
end

"""
**Nutrient uptake**

TODO
"""
function nutrientuptake(nutrients, biomass, p)
  #producers growth factor (G)
  Ks = vcat(p[:K1]', p[:K2]')
  limiting_nutrient = nutrients ./ (Ks .+ nutrients)
  growth_factor = minimum(limiting_nutrient, 1)
  #nutrients concentrations
  nutrient_turnover = p[:D] .* (p[:S] .- nutrients)
  nutrient_uptake = sum(p[:r] .* growth_factor' .* biomass[p[:is_producer]])
  dndt = nutrient_turnover .- (p[:υ] .* nutrient_uptake)
  NP = Dict(:G => growth_factor, :dndt => dndt)
end

"""
**Derivatives**

This function is the one wrapped by the various integration routines. Based on a
timepoint `t`, an array of biomasses `biomass`, and a series of simulation
parameters `p`, it will return `dB/dt` for every species.
"""
function dBdt(t, biomass, p::Dict{Symbol,Any})
  if (t/10) == round(t/10)
    println(t)
  end
  S = size(p[:A], 1)

  if(p[:productivity] == :nutrients)
    nutrients = biomass[S+1:end] #nutrients concentration
    biomass = biomass[1:S] #species biomasses
    NP_outputs = nutrientuptake(nutrients, biomass, p)
    G = NP_outputs[:G]
    dndt = NP_outputs[:dndt]
  end

  # Total available biomass
  if p[:rewire_method] ∈ [:ADBM, :Gilljam]
    bm_matrix = p[:w] .* ( biomass'.*p[:A]) .* p[:costMat]
  else
    bm_matrix = p[:w] .* ( biomass'.*p[:A])
  end
  food_available = vec(sum(bm_matrix, 2))

  f_den = p[:Γh]*(1.0+p[:c].*biomass).+food_available
  F = bm_matrix ./ f_den

  xyb = p[:x].*p[:y].*biomass
  transfered = F.*xyb
  consumed = transfered./p[:efficiency]
  consumed[isnan.(consumed)] = 0.0

  gain = vec(sum(transfered, 2))
  loss = vec(sum(consumed, 1))

  growth = zeros(eltype(biomass), S)

  j = 0
  for i in eachindex(biomass)
    if p[:is_producer][i]
      j = j+1
      if p[:productivity] == :nutrients #Nutrient intake
        growth_factor = G[j]
      else
        growth_factor = growthrate(p, biomass, i)
      end
      growth[i] = p[:r] * growth_factor * biomass[i]
    else
      growth[i] = - p[:x][i] * biomass[i]
    end
  end

  dbdt = growth .+ gain .- loss

  for i in eachindex(dbdt)
   if (dbdt[i] + biomass[i] < 100eps()) & (dbdt[i] + biomass[i] > 0.0)
     dbdt[i] = - (biomass[i]+100eps())
   else
     dbdt[i] = dbdt[i]
   end
 end

 if p[:productivity] == :nutrients
   dbdt = vcat(dbdt, dndt)
 end

  return dbdt
end
