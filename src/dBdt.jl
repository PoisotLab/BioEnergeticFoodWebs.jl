"""
**Total biomass available for each species**

Accounting for the allometric scaling and the number of resources.


This function should not be called by the user. Based on a vector of biomasses
(`biomass`) and a list of parameters (`p`), this function will update the
array `total` with the total biomass available to all species. `total[i]`
will give the biomass available to species `i`.
"""
function sum_biomasses!(total, biomass, p)
    S = size(p[:A], 1)
    for consumer in 1:S
        if !p[:is_producer][consumer]
            for resource in 1:S
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
function functional_response!(F, biomass, p, total_biomass_available)
    S = size(p[:A], 1)
    for consumer in 1:S
        if !p[:is_producer][consumer]
            for resource in 1:S
                numerator = p[:w][consumer] * p[:A][consumer, resource] * biomass[resource]^p[:h]
                denominator = p[:Γ]^p[:h] * (1.0 + p[:c] * biomass[consumer]) + total_biomass_available[consumer]
                F[consumer, resource] = numerator / denominator;
            end
        end
    end
end

"""
**Consumption**
"""
function consumption_rates!(C, biomass, p, F)
    S = size(p[:A], 1)
    for resource in 1:S
        for consumer in 1:S
            if !p[:is_producer][consumer]
                C[consumer, resource] = p[:x][consumer] * p[:y][consumer] * biomass[consumer] * F[consumer, resource]
            end
        end
    end
end

"""
**Derivatives**

This function is the one wrapped by `Sundials`. Based on a timepoint `t`,
an array of biomasses `biomass`, an equally sized array of derivatives
`derivative`, and a series of simulation parameters `p`, it will return
$\frac{dB}{dt}$ for every species.
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


    # Rate of change
    for species in 1:S

        # Species-specific component of growth
        if is_producer[species]
            growth = p[:r] * (1.0 - biomass[species] / p[:K]) * biomass[species]
        else
            growth = - x[species] * biomass[species]
        end

        # Total predation
        pred = 0.0;
        cons = 0.0;
        for other in 1:S
            if A[other, species] == 1
                pred += consumption[other, species] / efficiency[other, species]
            end
            if !is_producer[species]
                if A[species, other] == 1
                    cons += consumption[species, other]
                end
            end
        end

        derivative[species] = growth - pred + cons
    end

    return derivative

end
