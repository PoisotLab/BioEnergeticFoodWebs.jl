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
**Derivatives**

This function is the one wrapped by the various integration routines. Based on a
timepoint `t`, an array of biomasses `biomass`, and a series of simulation
parameters `p`, it will return `dB/dt` for every species.
"""
function dBdt(t, biomass, p::Dict{Symbol,Any})

  S = size(p[:A], 1)
  #derivative = zeros(Float64, length(biomass))

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

  growth = zeros(Float64, S)

  for i in eachindex(biomass)
    if p[:is_producer][i]
      growth[i] = p[:r] * growthrate(p, biomass, i) * biomass[i]
    else
      growth[i] = - p[:x][i] * biomass[i]
    end
  end

  dbdt = growth .+ gain .- loss
  return dbdt

  # for i in eachindex(derivative)
  #   if dbdt[i] + biomass[i] < eps(0.0)
  #     derivative[i] = - biomass[i]
  #   else
  #     derivative[i] = dbdt[i]
  #   end
  # end
  #
  # return derivative
end
