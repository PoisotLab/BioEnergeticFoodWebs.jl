"""
**Main simulation loop**

This function takes two mandatory arguments:

- `p` is a `Dict` as returned by `make_parameters`
- `biomass` is a `Array{Float64, 1}` with the initial biomasses of every species

Internally, the function will check that the length of `biomass` matches
with the size of the network.

In addition, the function takes three optional arguments:

- `start` (defaults to 0), the initial time
- `stop` (defaults to 500), the final time
- `steps` (defaults to 5000), the number of internal steps

Note that the value of `steps` is the number of intermediate steps when moving
from `t` to `t+1`. The total number of steps is therefore on the order of
(stop - start) * steps.

Because this results in very large simulations, the function will return
results with a timestep equal to unity.

The `simulate` function returns a `Dict{Symbol, Any}`, with three top-level
keys:

- `:p`, the parameters that were given as input
- `:t`, the timesteps
- `:B`, an `Array{Float64, 2}` with the biomasses

The array of biomasses has one row for each timestep, and one column for
each species.
"""
function simulate(p, biomass; start::Int64=0, stop::Int64=500, steps::Int64=5000)
    @assert stop > start
    @assert steps > 1
    @assert length(biomass) == size(p[:A],1)
    t_nsteps = (stop - start + 1)
    nsteps = steps * t_nsteps + t_nsteps
    t = collect(linspace(start, stop, nsteps))
    f(t, y, ydot) = dBdt(t, y, ydot, p)
    timeseries = Sundials.cvode(f, biomass, t)

    # Because small timesteps are sometimes needed, the output can get big
    # As in, several GB per simulation
    # So we'll record only every timestep

    t_collect = collect(linspace(start, stop, t_nsteps))
    t_keep = [x ∈ t_collect for x in t]

    output = Dict{Symbol,Any}(
        :p => p,
        :t => t[t_keep],
        :B => timeseries[t_keep,:]
    )

    return output

end

