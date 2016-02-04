function simulate(p, biomass; start=0, stop=500, steps=10)
    t = collect(linspace(start, stop, stop * steps))
    f(t, y, ydot) = dBdt(t, y, ydot, p)
    timeseries = Sundials.cvode(f, biomass, t)

    output = Dict{Symbol,Any}(
        :p => p,
        :t => t,
        :B => timeseries
    )

    return output

end

