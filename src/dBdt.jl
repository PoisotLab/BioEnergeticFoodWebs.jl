"""
**Derivatives**

This function is the one wrapped by the various integration routines. Based
on a timepoint `t`, an array of biomasses `biomass`, an equally sized array
of derivatives `derivative`, and a series of simulation parameters `p`,
it will return `dB/dt` for every species.

Note that at the end of the function, we perform different checks to ensure
that nothing wacky happens during subsequent integration steps. Specifically,
if B+dB/dt < ϵ(0.0), we set dBdt to -B. ϵ(0.0) is the next value above
0.0 that your system can represent.

"""
function dBdt(t, biomass, derivative, p::Dict{Symbol,Any})

  S = size(p[:A], 1)

  # Total available biomass
  bm_matrix = p[:w]*biomass'.*p[:A]
  food_available = vec(sum(bm_matrix, 2))

  f_den = p[:Γh]*(1.0+p[:c].*biomass).+food_available
  F = bm_matrix ./ f_den

  xyb = p[:x].*p[:y].*biomass
  transfered = F.*xyb
  consumed = transfered./p[:efficiency]
  consumed[isnan(consumed)] = 0.0

  gain = vec(sum(transfered, 2))
  loss = vec(sum(consumed, 1))

  growth = zeros(Float64, S)

  # Competition matrix
  competition_matrix = p[:α] .* (p[:is_producer] * p[:is_producer]') * biomassUodate

  # Real K is K/np if system-wide prod, K if not
  real_k = p[:productivity] == :system ? p[:K]/p[:np] : p[:K]

  for i in eachindex(biomass)
    if p[:is_producer][i]

      # The pool of competing biomass is only the focal species
      competition = biomass[i]
      # Unless we have competitive productivity
      if p[:productivity] == :competitive
        for j in eachindex(biomass)
          if p[:is_producer][j]
            if i != j
              # in which case there is inter-specific competition too
              competition += p[:α] * biomass[j]
            end
          end
        end
      end
      growth[i] = p[:r] * (1.0 - competition / real_k) * biomass[i]
    else
      growth[i] = - p[:x][i] * biomass[i]
    end
  end

  dBdt = growth .+ gain .- loss

  for i in eachindex(derivative)
    if dBdt[i] + biomass[i] < eps(0.0)
      derivative[i] = -biomass[i]
    else
      derivative[i] = dBdt[i]
    end
  end

  return derivative

end
