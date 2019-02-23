"""
**Growth rate**

TODO
"""
function growthrate(parameters, biomass, i; c = [0.0, 0.0])
  # Default -- species-level regulation
  compete_with = biomass[i]
  effective_K = parameters[:K]
  # If regulation is system-wide (all species share K)
  if parameters[:productivity] == :system
    compete_with = biomass[i]
    effective_K = parameters[:K] / parameters[:np]
    G = 1.0 - compete_with / effective_K
  elseif parameters[:productivity] == :competitive # If there is competition
    compete_with = biomass[i]
    for j in eachindex(biomass)
      if (i != j) & (parameters[:is_producer][j])
        compete_with += parameters[:α] * biomass[j]
      end
    end
    effective_K = parameters[:K]
    G = 1.0 - compete_with / effective_K
  elseif parameters[:productivity] == :nutrients
    limit_n1 = c[1] ./ (parameters[:K1][i] .+ c[1])
    limit_n2 = c[2] ./ (parameters[:K2][i] .+ c[2])
    limiting_nutrient = hcat(limit_n1, limit_n2)
    G = minimum(limiting_nutrient, dims = 2)
  else
    G = 1.0 - compete_with / effective_K
  end
  return G
end

"""
**Species growth - internal**

This function is used internally by `dBdt` and `producer_growth`. It takes the vector of biomass
at each time steps, the model parameters (and the vector of nutrients concentrations
if `productivity = :nutrients`), and return the producers' growth rates for this time step
"""
function get_growth(parameters, biomass; c = 0)
    S = size(parameters[:A], 1)
    growth = zeros(eltype(biomass), S)
    G = zeros(eltype(biomass), S)
    for i in eachindex(biomass)
      if parameters[:is_producer][i]
        gr = growthrate(parameters, biomass, i, c = c)[1]
        G[i] = (parameters[:r][i] * gr * biomass[i])
        if parameters[:productivity] == :nutrients #Nutrient intake
          growth[i] = G[i] - (parameters[:x][i] * biomass[i])
        else
          growth[i] = G[i]
        end
      else
        growth[i] = - parameters[:x][i] * biomass[i]
      end
    end
    return growth, G
end

"""
**Nutrient uptake**

TODO
"""
function nutrientuptake(parameters, biomass, nutrients, G)
  gr_x_bm = sum(G) #G here is already weighted by biomass (see get_growth)
  dndt = zeros(eltype(nutrients), length(nutrients))
  for i in eachindex(dndt)
    turnover = parameters[:D] * (parameters[:supply][i] - nutrients[i])
    dndt[i] = turnover - parameters[:υ][i] * gr_x_bm
  end
  return dndt
end

function fill_bm_matrix!(bm_matrix::Matrix{Float64}, biomass::Vector{Float64}, w::Matrix{Float64}, A::Matrix{Int64}, h::Float64; rewire::Bool=false, costMat=nothing)
  for i in eachindex(biomass), j in eachindex(biomass)
    @inbounds bm_matrix[i,j] = w[i,j] * (biomass[j] .^ h) * A[i,j]
    if rewire
      bm_matrix[i,j] *= costMat[i,j]
    end
  end
end

function fill_F_matrix!(F, bm_matrix, biomass, Γh, c)
  food_available = vec(sum(bm_matrix, dims = 2))
  f_den = zeros(eltype(biomass), length(biomass))
  for i in eachindex(biomass)
    f_den[i] = Γh[i]*(1.0+c*biomass[i])+food_available[i]
  end
  for i in eachindex(biomass), j in eachindex(biomass)
    F[i,j] = bm_matrix[i,j] / f_den[i]
  end
  F[isnan.(F)] .= 0.0
end

function fill_xyb_matrix!(xyb, biomass, x, y)
  for i in eachindex(biomass)
    @inbounds xyb[i] = x[i]*y[i]*biomass[i]
  end
  for j in eachindex(xyb)
    if xyb[j] == Inf
      xyb[j] = 0
    end
  end
end

function update_F_matrix!(F, xyb)
  for i in eachindex(xyb), j in eachindex(xyb)
    @inbounds F[i,j] = F[i,j] * xyb[i]
  end
end

function get_trophic_loss!(F, pe)
  for i in eachindex(F)
    F[i] = pe[i] == 0.0 ? 0.0 : F[i]/pe[i]
  end
end

function consumption(parameters, biomass)

  # Total available biomass
  bm_matrix = zeros(eltype(biomass), (length(biomass), length(biomass)))
  rewire = (parameters[:rewire_method] == :ADBM) | (parameters[:rewire_method] == :Gilljam)
  costMat = rewire ? parameters[:costMat] : nothing
  fill_bm_matrix!(bm_matrix, biomass, parameters[:w], parameters[:A], parameters[:h]; rewire=rewire, costMat=costMat)

  # Available food
  F = zeros(eltype(biomass), (length(biomass), length(biomass)))
  fill_F_matrix!(F, bm_matrix, biomass, parameters[:Γh], parameters[:c])

  # XYB matrix
  xyb = zeros(eltype(biomass), length(biomass))
  fill_xyb_matrix!(xyb, biomass, parameters[:x], parameters[:y])

  update_F_matrix!(F, xyb)

  gain = vec(sum(F, dims = 2))

  get_trophic_loss!(F, parameters[:efficiency])

  loss = vec(sum(F, dims = 1))

  return gain, loss

end

"""
**Derivatives**

This function is the one wrapped by the various integration routines. Based on a
timepoint `t`, an array of biomasses `biomass`, and a series of simulation
parameters `p`, it will return `dB/dt` for every species.
"""
function dBdt(derivative, biomass, parameters::Dict{Symbol,Any}, t)
  S = size(parameters[:A], 1)

  # producer growth if NP model
  if parameters[:productivity] == :nutrients
    nutrients = biomass[S+1:end] #nutrients concentration
    nutrients[nutrients .< 0] .= 0.0
    biomass = biomass[1:S] #species biomasses
  else
    nutrients = [NaN, NaN]
  end

  # Consumption
  gain, loss = consumption(parameters, biomass)

  # Growth
  growth, G = get_growth(parameters, biomass; c = nutrients)

  # Balance
  dbdt = zeros(eltype(biomass), length(biomass))
  for i in eachindex(dbdt)
    dbdt[i] = growth[i] + gain[i] - loss[i]
  end

  parameters[:productivity] == :nutrients && append!(dbdt, nutrientuptake(parameters, biomass, nutrients, G))
  for i in eachindex(dbdt)
    derivative[i] = dbdt[i]
  end
  return dbdt
end
