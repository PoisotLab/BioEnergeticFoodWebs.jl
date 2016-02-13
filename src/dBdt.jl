"""
**Derivatives**

This function is the one wrapped by the various integration routines. Based
on a timepoint `t`, an array of biomasses `biomass`, an equally sized array
of derivatives `derivative`, and a series of simulation parameters `p`,
it will return `dB/dt` for every species.

Note that at the end of the function, we perform different checks to ensure
that nothing wacky happens during subsequent integration steps. Specifically,
if B+dB/dt a< ϵ(), we set dBdt to -B. ϵ() is the next value above
1.0 that your system can represent.

"""
function dBdt(t, biomass, derivative, p::Dict{Symbol,Any})

    S = size(p[:A], 1)

    # Functional response
    # This is a big-ass operation, but it works orders of magnitude faster than loops
    F = (p[:w] .* p[:A] .* (biomass .^p[:h])') ./ (p[:Γh] .*(1.0 + p[:c] .* biomass) .+ (p[:A] * (biomass.^p[:h]) .* p[:w]) )

    # Consumption
    consumption = p[:x] .* p[:y] .* biomass .* F

    ce = consumption./p[:efficiency]
    ce[isnan(ce)] = 0.0

    interac = -vec(sum(ce, 2)).+ sum(consumption, 1)


    # Rate of change
    for species in eachindex(biomass)

        # Species-specific component of growth
        if p[:is_producer][species]
            growth = p[:r] * (1.0 - biomass[species] / p[:K]) * biomass[species]
        else
            growth = - p[:x][species] * biomass[species]
        end
        
        derivative[species] = growth + interac[species]
       
        if derivative[species] + biomass[species] < eps()
            derivative[species] = -biomass[species]
        end

    end

    return derivative

end
