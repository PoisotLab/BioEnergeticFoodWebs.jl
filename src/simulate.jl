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

If the difference between stop and start is more than an arbitrary threshold
(currently 2000 timesteps), the simulations will be run in chunks of 2000
timesteps each. This is because the amount of memory needed to store the
dynamics scales very badly. To avoid `OutOfMemory()` errors, running the
simulation by parts is sufficient.

"""
function simulate(p, biomass; start::Int64=0, stop::Int64=500, steps::Int64=5000)
    @assert stop > start
    @assert steps > 1
    @assert length(biomass) == size(p[:A],1)

    # Pre-allocate the timeseries matrix
    t = collect(linspace(start, stop, (stop-start)+1))
    nt, ns = length(t), length(biomass)
    timeseries = zeros((nt, ns))

    # We put the starting conditions in the array
    timeseries[1,:] = biomass

    chunk_size = 2000
    done_up_to = start
    while done_up_to < stop
        start_at = done_up_to
        stop_at = start_at + chunk_size
        if stop_at > stop
            stop_at = stop
        end
        i = start_at-start + 1
        inner_simulation_loop!(timeseries, p, i, start=start_at, stop=stop_at, steps=steps)
        done_up_to = stop_at
    end

    output = Dict{Symbol,Any}(
        :p => p,
        :t => t,
        :B => timeseries
    )

    return output

end

"""
**Inner simulation loop**

This function is called internally by `simulate`, and should not be called
by the user.

Note that `output` is a pre-allocated array in which the simulation result
will be written, and `i` is the origin of the simulation.

"""
function inner_simulation_loop!(output, p, i; start::Int64=0, stop::Int64=2000, steps::Int64=5000)
    
    t_nsteps = (stop - start + 1)
    nsteps = (stop - start) * steps + 1
    t = collect(linspace(start, stop, nsteps))
    f(t, y, ydot) = dBdt(t, y, ydot, p)

    # Read the biomass in the pre-allocated array
    biomass = vec(output[i,:])

    # Integrate
    timeseries = Sundials.cvode(f, biomass, t)

    # Get only the int times
    t_collect = collect(linspace(start, stop, t_nsteps))
    t_keep = [x ∈ t_collect for x in t]

    ok_indices = collect(i:(i+sum(t_keep)-1))
    
    # Update the output array
    output[ok_indices,:] = timeseries[t_keep,:]
end

