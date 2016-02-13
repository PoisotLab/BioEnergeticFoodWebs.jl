"""
**Derivatives**

This function is the one wrapped by the various integration routines. Based
on a timepoint `t`, an array of biomasses `biomass`, an equally sized array
of derivatives `derivative`, and a series of simulation parameters `p`,
it will return `dB/dt` for every species.

Note that at the end of the function, we perform different checks to ensure
that nothing wacky happens during subsequent integration steps. Specifically,
if B+dB/dt a< ϵ(0.0), we set dBdt to -B. ϵ(0.0) is the next value above
0.0 that your system can represent.

"""
function dBdt(t, biomass, derivative, p::Dict{Symbol,Any})

    S = size(p[:A], 1)

    # How much food is available?
    total_biomass_available =  p[:A] * (biomass.^p[:h]) .* p[:w]
    #=total_biomass_available = zeros(Float64, S)=#
    #=sum_biomasses!(total_biomass_available, biomass, p)=#

    # Functional response
    #=F = zeros(Float64, size(p[:A]))=#
    #=functional_response!(F, biomass, p, total_biomass_available)=#
    F = (p[:w] .* p[:A] .* (biomass .^p[:h])') ./ (p[:Γh] .*(1.0 + p[:c] .* biomass) .+ total_biomass_available )

    # Consumption
    consumption = p[:x] .* p[:y] .* biomass .* F
    #=consumption = zeros(Float64, size(p[:A]))=#
    #=consumption_rates!(consumption, biomass, p, F)=#

    # Rate of change
    for species in eachindex(biomass)

        # Species-specific component of growth
        if p[:is_producer][species]
            growth = p[:r] * (1.0 - biomass[species] / p[:K]) * biomass[species]
        else
            growth = - p[:x][species] * biomass[species]
        end

        # Total predation
        pred = 0.0;
        cons = 0.0;
        for other in eachindex(biomass)
            if p[:A][other, species] == 1
                pred += consumption[other, species] / p[:efficiency][other, species]
            end
            if !p[:is_producer][species]
                if p[:A][species, other] == 1
                    cons += consumption[species, other]
                end
            end
        end

        derivative[species] = growth - pred + cons
        if derivative[species] + biomass[species] < eps(0.0)
            derivative[species] = -biomass[species]
        end

    end

    return derivative

end
