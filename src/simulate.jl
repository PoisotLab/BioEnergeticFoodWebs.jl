function simulate(p, biomass; start=0, stop=500, steps=10)
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

