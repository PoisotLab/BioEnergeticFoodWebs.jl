function coefficient_of_variation(x)
    cv = std(x) / mean(x)
    norm = 1 + 1 / (4 * length(x))
    return norm * cv
end

function population_stability(D; threshold=1e-10, last=1000)
    @assert last <= size(A, 1)
    non_extinct = D[end,:] .> threshold
    measure_on = D[end-(last-1):end,non_extinct]
    stability = -mapslices(coefficient_of_variation, measure_on, 1)
    return mean(stability)
end
