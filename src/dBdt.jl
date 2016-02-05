function dBdt(t, biomass, derivative, p::Dict{Symbol,Any})

    w = p[:w]
    efficiency = p[:efficiency]
    F = zeros(size(efficiency))
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
    for consumer in 1:S
        if !is_producer[consumer]
            for resource in 1:S
                total_biomass_available[consumer] += w[consumer] * A[consumer, resource] * biomass[resource]^p[:h]
            end
        end
    end
    #=total_biomass_available = sum( (w .* (biomass.^p[:h])') .* A, 2)=#

    # What is the functional response ?
    for consumer in 1:S
        if !is_producer[consumer]
            for resource in 1:S
                numerator = w[consumer] * A[consumer, resource] * biomass[resource]^p[:h]
                denominator = p[:Γ]^p[:h] * (1.0 + p[:c] * biomass[consumer]) + total_biomass_available[consumer]
                F[consumer, resource] = numerator / denominator;
            end
        end
    end

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
