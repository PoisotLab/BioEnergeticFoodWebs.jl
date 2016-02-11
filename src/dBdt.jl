"""
**Total biomass available for each species**

Accounting for the allometric scaling and the number of resources.


This function should not be called by the user. Based on a vector of biomasses
(`biomass`) and a list of parameters (`p`), this function will update the
array `total` with the total biomass available to all species. `total[i]`
will give the biomass available to species `i`.
"""
function sum_biomasses!(total::Array{Float64, 1}, biomass::Array{Float64, 1}, p::Dict{Symbol, Any})
    for resource in eachindex(biomass)
        for consumer in eachindex(biomass)
            if !p[:is_producer][consumer]
                total[consumer] += p[:w][consumer] * p[:A][consumer, resource] * biomass[resource]^p[:h]
            end
        end
    end
end

"""
**Functional response**

General function for the functional response matrix. Modifies `F` in place. 

Not to be called by the user.
"""
function functional_response!(F::Array{Float64, 2}, biomass::Array{Float64, 1}, p::Dict{Symbol, Any}, total_biomass_available::Array{Float64, 1})
    Γh = p[:Γ]^p[:h] 
    for resource in eachindex(biomass)
        bm_h = biomass[resource]^p[:h]
        for consumer in eachindex(biomass)
            if !p[:is_producer][consumer]
                numerator = p[:w][consumer] * p[:A][consumer, resource] * bm_h
                denominator = Γh * (1.0 + p[:c] * biomass[consumer]) + total_biomass_available[consumer]
                F[consumer, resource] = numerator / denominator
            end
        end
    end
end

"""
**Consumption**
"""
function consumption_rates!(C::Array{Float64, 2}, biomass::Array{Float64, 1}, p::Dict{Symbol, Any}, F::Array{Float64, 2})
    for consumer in eachindex(biomass)
        inner_prod = p[:x][consumer] * p[:y][consumer] * biomass[consumer]
        if !p[:is_producer][consumer]
            for resource in eachindex(biomass)
                C[consumer, resource] = inner_prod * F[consumer, resource]
            end
        end
    end
end

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

    w = p[:w]
    efficiency = p[:efficiency]
    x = p[:x]
    y = p[:y]
    a = p[:a]
    A = p[:A]
    S = size(A)[1]
    is_herbivore = p[:is_herbivore]
    is_producer = p[:is_producer]

    # How much food is available?
    total_biomass_available = zeros(Float64, S)
    sum_biomasses!(total_biomass_available, biomass, p)

    # Functional response
    F = zeros(Float64, size(p[:A]))
    functional_response!(F, biomass, p, total_biomass_available)

    # Consumption
    consumption = zeros(Float64, size(p[:A]))
    consumption_rates!(consumption, biomass, p, F)

    pred_total = vec(sum(consumption ./ efficiency, 2))
    cons_total = vec(sum(consumption, 1))

    # Rate of change
    for species in eachindex(biomass)

        # Species-specific component of growth
        if is_producer[species]
            growth = p[:r] * (1.0 - biomass[species] / p[:K]) * biomass[species]
        else
            growth = - x[species] * biomass[species]
        end

        # Total predation
        #=pred = 0.0;=#
        #=cons = 0.0;=#
        #=for other in eachindex(biomass)=#
            #=if A[other, species] == 1=#
                #=pred += consumption[other, species] / efficiency[other, species]=#
            #=end=#
            #=if !is_producer[species]=#
                #=if A[species, other] == 1=#
                    #=cons += consumption[species, other]=#
                #=end=#
            #=end=#
        #=end=#

        #=derivative[species] = growth - pred + cons=#
        derivative[species] = growth - pred_total[species] + cons_total[species]
    end

    # The derivatives cannot be smaller than -B (i.e. the biomass is at least 0)
    for species in eachindex(derivative)
        if derivative[species] + biomass[species] < eps(0.0)
            derivative[species] = -biomass[species]
        end
    end


    return derivative

end
