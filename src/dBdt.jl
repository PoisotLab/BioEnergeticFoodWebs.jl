"""
Total biomass available to a given species, accounting for the allometric
scaling and the number of resources.
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

function dBdt(t, biomass, derivative, p::Dict{Symbol,Any})

    w = p[:w]
    efficiency = p[:efficiency]
    x = p[:x]
    y = p[:y]
    a = p[:a]
    A = p[:A]
    consumption = zeros(Float64, size(A))
    S = size(A)[1]
    is_herbivore = p[:is_herbivore]
    is_producer = p[:is_producer]

    # How much food is available?
    total_biomass_available = zeros(Float64, S)
    sum_biomasses!(total_biomass_available, biomass, p)

    # What is the functional response ?
    F = zeros(size(p[:A]))
    functional_response!(F, biomass, p, total_biomass_available)

    # Consumption
    for resource in 1:S
        for consumer in 1:S
            if !is_producer[consumer]
                consumption[consumer, resource] = x[consumer] * y[consumer] * biomass[consumer] * F[consumer, resource]
            end
        end
    end

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

end
