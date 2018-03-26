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


"""
**Producers growth rate**

This function takes the simulation outputs from `simulate` and returns the producers
growth rates. Depending on the value given to the keyword `out_type`, it can return
more specifically:
- growth rates for each producer at each time step form end-last to last (`out_type = :all`)
- the mean growth rate for each producer over the last `last` time steps (`out_type = :mean`)
- the standard deviation of the growth rate for each producer over the last `last` time steps (`out_type = :std`)
"""
function producer_growth(out::Dict{Symbol,Any}; last::Int64 = 1000, out_type::Symbol = :all)
    p = out[:p] #extract parameters
    @assert last <= size(out[:B], 1)
    measure_on = out[:B][end-(last-1):end,:] #extract the biomasses that will be used
    measure_on_mat = [measure_on[i,:] for i = 1:last] #make it an array of array so we can use the map function
    if p[:productivity] == :nutrients #if the producers do NOT rely on nutrients for their growth
        c = out[:C][end-(last-1):end,:] #extract the timesteps of interest for the nutrients concentration
        c_mat = [c[i,:] for i = 1:last] #make it an array of array
        gr = map((x,y) -> get_growth(x,p,c=y), measure_on_mat, c_mat)
        growth = hcat(map(x -> x[:growth], gr)...)'
    else
        gr = map(x -> get_growth(x,p), measure_on_mat)
        growth = hcat(map(x -> x[:growth], gr)...)'
    end
    growth[:,.!p[:is_producer]] = 0.0
    if out_type == :all #return all growth rates (each producer at each time step)
        return growth
    elseif out_type == :mean #return the producers mean growth rate over the last `last` time steps
        return mean(growth, 1)
    elseif out_type == :std #return the growth rate standard deviation over the last `last` time steps (for each producer)
        return std(growth, 1)
    else #if the keyword used is not one of :mean, :all or :std, print an error
        error("out_type should be one of :all, :mean or :std")
    end
end

"""
**Nutrients intake**

This function takes the simulation outputs from `simulate` and returns the producers
nutrient intake. Depending on the value given to the keyword `out_type`, it can return
more specifically:
- nutrient intake for each producer at each time step form end-last to last (`out_type = :all`)
- the mean nutrient intake for each producer over the last `last` time steps (`out_type = :mean`)
- the standard deviation of the nutrient intake for each producer over the last `last` time steps (`out_type = :std`)
"""
function nutrient_intake(out::Dict{Symbol,Any}; last::Int64 = 1000, out_type::Symbol = :all)
    p = out[:p] #extract parameters
    @assert last <= size(out[:B], 1)
    @assert p[:productivity] == :nutrients
    measure_on = out[:B][end-(last-1):end,:] #extract the biomasses that will be used
    measure_on_mat = [measure_on[i,:] for i = 1:last] #make it an array of array so we can use the map function
    c = out[:C][end-(last-1):end,:] #extract the timesteps of interest for the nutrients concentration
    c_mat = [c[i,:] for i = 1:last] #make it an array of array
    gr = map((x,y) -> BioEnergeticFoodWebs.get_growth(x,p,c=y), measure_on_mat, c_mat)
    intake = hcat(map(x -> x[:G], gr)...)'
    if out_type == :all #return all growth rates (each producer at each time step)
        return intake
    elseif out_type == :mean #return the producers mean growth rate over the last `last` time steps
        return mean(intake, 1)
    elseif out_type == :std #return the growth rate standard deviation over the last `last` time steps (for each producer)
        return std(intake, 1)
    else #if the keyword used is not one of :mean, :all or :std, print an error
        error("out_type should be one of :all, :mean or :std")
    end
end

"""
**Consumers' biomass intake**

This function takes the simulation outputs from `simulate` and returns the consumers
biomass intake. Depending on the value given to the keyword `out_type`, it can return
more specifically:
- biomass intake for each species at each time step form end-last to last (`out_type = :all`)
- the mean biomass intake for each species over the last `last` time steps (`out_type = :mean`)
- the standard deviation of the biomass intake for each species over the last `last` time steps (`out_type = :std`)

"""
function consumer_intake(out::Dict{Symbol,Any}; last::Int64 = 1000, out_type::Symbol = :all)
    p = out[:p] #extract parameters
    @assert last <= size(out[:B], 1)
    measure_on = out[:B][end-(last-1):end,:] #extract the biomasses that will be used
    measure_on_mat = [measure_on[i,:] for i = 1:last] #make it an array of array so we can use the map function
    cons = map(x -> consumption(x, p), measure_on_mat)
    gains = hcat(map(x-> x[:gain], cons)...)'
    #losses = hcat(map(x-> x[:loss], cons)...)'
    if out_type == :all #return all growth rates (each producer at each time step)
        return gains
    elseif out_type == :mean #return the producers mean growth rate over the last `last` time steps
        return mean(gains, 1)
    elseif out_type == :std #return the growth rate standard deviation over the last `last` time steps (for each producer)
        return std(gains, 1)
    else #if the keyword used is not one of :mean, :all or :std, print an error
        error("out_type should be one of :all, :mean or :std")
    end
end

# """
# **Metabolic loss**
# """
