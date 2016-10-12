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
- `use` (defaults to `:ode45`), the integration method


The integration method is, by default, `:ode45`, and can be changed to one of
`:ode23`, `:ode45`, `:ode78`, or `:ode23s`.

The `simulate` function returns a `Dict{Symbol, Any}`, with three top-level
keys:

- `:p`, the parameters that were given as input
- `:t`, the timesteps
- `:B`, an `Array{Float64, 2}` with the biomasses

The array of biomasses has one row for each timestep, and one column for
each species.

"""
function simulate(p, biomass; start::Int64=0, stop::Int64=500, use::Symbol=:ode45)
    @assert stop > start
    @assert length(biomass) == size(p[:A],1)
    @assert use ∈ vec([:ode23 :ode23s :ode45 :ode78])

    # Pre-allocate the timeseries matrix
    t = collect(linspace(start, stop, (stop-start)+1))

    # Pre-assign function
    f(t, y, ydot) = dBdt(t, y, ydot, p)

    # Integrate
    func_dict = Dict{Symbol,Function}(
      :ode23  => wrap_ode23,
      :ode23s => wrap_ode23s,
      :ode45  => wrap_ode45,
      :ode78  => wrap_ode78
    )
    # Perform the actual integration
    timeseries = func_dict[use](f, biomass, t)

    output = Dict{Symbol,Any}(
        :p => p,
        :t => t,
        :B => timeseries
    )

    return output

end

"""
**Wrapper for ode23**

See `wrap_ode`.
"""
function wrap_ode23(f, b, t)
    return wrap_ode(ODE.ode23, f, b, t)
end

"""
**Wrapper for ode23s**

See `wrap_ode`.
"""
function wrap_ode23s(f, b, t)
    return wrap_ode(ODE.ode23s, f, b, t)
end

"""
**Wrapper for ode45**

See `wrap_ode`.
"""
function wrap_ode45(f, b, t)
    return wrap_ode(ODE.ode45, f, b, t)
end

"""
**Wrapper for ode78**

See `wrap_ode`.
"""
function wrap_ode78(f, b, t)
    return wrap_ode(ODE.ode78, f, b, t)
end

"""
**Wrapper for ode functions**

These functions will let `ODE` do its job, then return the results in way
we can handle. To be entirely explicit, these functions return objects in
the same format as the output of `Sundials`. The long-term plan is to use
Sundials only, but there is currently a significant memory leak issue,
so we are resorting to ODE for the time being.
"""
function wrap_ode(i, f, b, t)
    d = copy(b)
    g(t, y) = f(t, y, d)
    t, y = i(g, b, t, points=:specified)
    return hcat(y...)'
end
