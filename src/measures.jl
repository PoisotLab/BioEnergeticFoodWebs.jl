"""
**Coefficient of variation**

Corrected for the sample size.

"""
function coefficient_of_variation(x)
    cv = std(x) / mean(x)
    norm = 1 + 1 / (4 * length(x))
    return norm * cv
end

"""
**Population stability**

Takes a matrix with populations in columns, timesteps in rows. This is usually
the element `:B` of the simulation output. Population stability is measured
as the mean of the negative coefficient of variations of all species with
an abundance higher than `threshold`. By default, the stability is measure
over the last `last=1000` timesteps.

"""
function population_stability(D; threshold=1e-10, last=1000)
    @assert last <= size(D, 1)
    non_extinct = D[end,:] .> threshold
    measure_on = D[end-(last-1):end,non_extinct]
    stability = -mapslices(coefficient_of_variation, measure_on, 1)
    return mean(stability)
end
