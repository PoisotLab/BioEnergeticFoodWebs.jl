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
**Number of surviving species**

Number of species with a biomass larger than the `threshold`. The threshold is
by default set at `eps()`, which should be close to 10^-16.
"""
function species_richness(p; threshold::Float64=eps(), last::Int64=1000)
    @assert last <= size(p[:B], 1)
    measure_on = p[:B][end-(last-1):end,:]
    if sum(measure_on) == 0
        return NaN
    end
    richness = vec(sum(measure_on .> threshold, 2))
    return mean(richness)
end

"""
**Proportion of surviving species**

Proportion of species with a biomass larger than the `threshold`. The threshold is
by default set at `eps()`, which should be close to 10^-16.
"""
function species_persistence(p; threshold::Float64=eps(), last::Int64=1000)
    r = species_richness(p, threshold=threshold, last=last)
    m = size(p[:B], 2) # Number of species is the number of columns in the biomass matrix
    return r/m
end

"""
**Population stability**

Population stability is measured as the mean of the negative coefficient
of variations of all species with an abundance higher than `threshold`. By
default, the stability is measured over the last `last=1000` timesteps.
"""
function population_stability(p; threshold::Float64=eps(), last=1000)
    @assert last <= size(p[:B], 1)
    non_extinct = p[:B][end,:] .> threshold
    measure_on = p[:B][end-(last-1):end,non_extinct]
    if sum(measure_on) == 0
        return NaN
    end
    stability = -mapslices(coefficient_of_variation, measure_on, 1)
    return mean(stability)
end

"""
**Total biomass**

Returns the sum of biomass, averaged over the last `last` timesteps.

"""
function total_biomass(p; last=1000)
    @assert last <= size(p[:B], 1)
    measure_on = p[:B][end-(last-1):end,:]
    if sum(measure_on) == 0
        return NaN
    end
    biomass = vec(sum(measure_on, 2))
    return mean(biomass)
end

"""
**Per species biomass**

Returns the average biomass of all species, over the last `last` timesteps.
"""
function population_biomass(p; last=1000)
    @assert last <= size(p[:B], 1)
    measure_on = p[:B][end-(last-1):end,:]
    if sum(measure_on) == 0
        return NaN
    end
    biomass = vec(mean(measure_on, 1))
    return biomass
end

"""
**Shannon's entropy**

Corrected for the number of species, removes negative and null values, return
`NaN` in case of problem.
"""
function shannon(n)
    x = copy(n)
    x = filter((k) -> k > 0.0, x)
    try
        if length(x) > 1
            p = x ./ sum(x)
            corr = log.(length(x))
            p_ln_p = p .* log.(p)
            return -(sum(p_ln_p)/corr)
        else
            return NaN
        end
    catch
        return NaN
    end
end

"""
**Food web diversity**

Based on the average of Shannon's entropy (corrected for the number of
species) over the last `last` timesteps. Values close to 1 indicate that
all populations have equal biomasses.

"""
function foodweb_evenness(p; last=1000)
    @assert last <= size(p[:B], 1)
    measure_on = p[:B][end-(last-1):end,:]
    if sum(measure_on) == 0
        return NaN
    end
    shan = [shannon(vec(measure_on[i,:])) for i in 1:size(measure_on, 1)]
    return mean(shan)
end

"""
**Save the output of a simulation**

Takes a simulation output as a mandatory argument. The two keyword arguments
are `as` (can be `:json` or `:jld`), defining the file format, and `filename`
(without an extension, defaults to `NaN`). If `:jld` is used, the variable
is named `befwm_simul` unless a `varname` is given.

Called with the defaults, this function will write `befwm_xxxxxxxx.json`
with the current simulation output, where `xxxxxxxx` is a hash of the `p`
output (ensuring that all output files are unique).

This function is *not* exported, so it must be called with `BioEnergeticFoodWebs.save`.

"""
function save(p::Dict{Symbol,Any}; as::Symbol=:json, filename=NaN, varname=NaN)
    if as == :JSON
        as = :json
    end
    if as == :JLD
        as = :jld
    end
    @assert as ∈ vec([:json :jld])
    if isnan(filename)
        filename = "befwm_" * string(hash(p))
    end
    if isnan(varname)
        varname = "befwm_simul"
    end
    if as == :json
        filename = filename * ".json"
        f = open(filename, "w")
        JSON.print(f, p)
        close(f)
    end
    if as == :jld
        filename = filename * ".jld"
        JLD.save(filename, varname, p)
    end
end
