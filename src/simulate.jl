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
- `use` (defaults to `:Sundials`), the integration method

Note that the value of `steps` is the number of intermediate steps when moving
from `t` to `t+1`. The total number of steps is therefore on the order of
(stop - start) * steps.

Because this results in very large simulations, the function will return
results with a timestep equal to unity.

The integration method can be changed to `:Euler`. Not that it should,
because it takes longer to run and is more likely to give weird results. It
can also be changed to one of the `Ode` functions, *i.e.* `:ode23`, `:ode45`,
`:ode78`, or `:ode23s`.

The `simulate` function returns a `Dict{Symbol, Any}`, with three top-level
keys:

- `:p`, the parameters that were given as input
- `:t`, the timesteps
- `:B`, an `Array{Float64, 2}` with the biomasses

The array of biomasses has one row for each timestep, and one column for
each species.

If the difference between stop and start is more than an arbitrary threshold
(currently 500 timesteps), the simulations will be run in chunks of 500
timesteps each. This is because the amount of memory needed to store the
dynamics scales very badly. To avoid `OutOfMemory()` errors, running the
simulation by parts is sufficient.

"""
function simulate(p, biomass; start::Int64=0, stop::Int64=500, steps::Int64=5000, use::Symbol=:Sundials)
    @assert stop > start
    @assert steps > 1
    @assert length(biomass) == size(p[:A],1)
    @assert use ∈ vec([:Sundials :Euler :ode23 :ode23s :ode45 :ode78])

    # Pre-allocate the timeseries matrix
    t = collect(linspace(start, stop, (stop-start)+1))
    nt, ns = length(t), length(biomass)
    timeseries = zeros((nt, ns))

    # We put the starting conditions in the array
    timeseries[1,:] = biomass
    
    # Pre-assing function
    f(t, y, ydot) = dBdt(t, y, ydot, p)

    chunk_size = 500
    done_up_to = start
    while done_up_to < stop
        start_at = done_up_to
        stop_at = start_at + chunk_size
        if stop_at > stop
            stop_at = stop
        end
        i = start_at-start + 1
        inner_simulation_loop!(timeseries, p, i, f, start=start_at, stop=stop_at, steps=steps, use=use)
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
function inner_simulation_loop!(output, p, i, f; start::Int64=0, stop::Int64=2000, steps::Int64=5000, use::Symbol=:Sundials)
    
    t_nsteps = (stop - start + 1)
    nsteps = (stop - start) * steps + 1
    t = collect(linspace(start, stop, nsteps))

    # Read the biomass in the pre-allocated array
    biomass = vec(output[i,:])

    # Integrate
    func_dict = Dict{Symbol,Function}(
        :Sundials => Sundials.cvode,
        :Euler  => euler_integration,
        :ode23  => wrap_ode23,
        :ode23s => wrap_ode23s,
        :ode45  => wrap_ode45,
        :ode78  => wrap_ode78
    )
    ts = func_dict[use](f, biomass, t)

    # Get only the int times
    t_collect = collect(linspace(start, stop, t_nsteps))
    t_keep = [x ∈ t_collect for x in t]

    ok_indices = collect(i:(i+sum(t_keep)-1))
    
    # Update the output array
    output[ok_indices,:] = ts[t_keep,:]

    # Free memory (just to be super double plus sure)
    ts = 0
end

"""
**Euler integration**

Performs Euler integration along a known time series. This method is *slower*
(several orders of magnitude, in fact) than using `:Sundials`, and consumes
more memory. This is mostly useful for situations in which Sundials chokes
on a problem.

"""
function euler_integration(f, biomass, t)
    # Initial population density
    dynamics = zeros(Float64, (length(t), length(biomass)))
    dynamics[1,:] = biomass
    for time in 2:length(t)
        time_differential = t[time] - t[time-1]
        derivatives = f(t, vec(dynamics[time-1,:]), zeros(length(biomass)))
        dynamics[time,:] = vec(dynamics[time-1,:]) .+ vec(derivatives) .* time_differential
    end
    return dynamics
end

function wrap_ode23(f, b, t)
    return wrap_ode(ODE.ode23, f, b, t)
end

function wrap_ode23s(f, b, t)
    return wrap_ode(ODE.ode23s, f, b, t)
end

function wrap_ode45(f, b, t)
    return wrap_ode(ODE.ode45, f, b, t)
end

function wrap_ode78(f, b, t)
    return wrap_ode(ODE.ode78, f, b, t)
end

function wrap_ode(i, f, b, t)
    d = copy(b)
    g(t, y) = f(t, y, d)
    t, y = i(g, b, t)
    println(t)
    println(y)
    return y
end
