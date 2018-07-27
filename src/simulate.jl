"""
**Main simulation loop**

    simulate(parameters, biomass; start::Int64=0, stop::Int64=500, use::Symbol=:stiff)

This function takes two mandatory arguments:

- `p` is a `Dict` as returned by `make_parameters`
- `biomass` is an `Array{Float64, 1}` with the initial biomasses of every species

Internally, the function will check that the length of `biomass` matches
with the size of the network.

In addition, the function takes three optional arguments:

- `start` (defaults to 0), the initial time
- `stop` (defaults to 500), the final time
- `use` (defaults to `:stiff`), a hint to select the solver

The integration method is, by default, `:stiff`, and can be changed to
`:nonstiff`. This is because internally, this function used the
`DifferentialEquations` package to pick the most appropriate algorithm.

The `simulate` function returns a `Dict{Symbol, Any}`, with three
top-level keys:

- `:p`, the parameters that were given as input
- `:t`, the timesteps
- `:B`, an `Array{Float64, 2}` with the biomasses

The array of biomasses has one row for each timestep, and one column for
each species.
"""
function simulate(parameters, biomass; concentration::Vector{Float64}=rand(Float64, 2).*10, start::Int64=0, stop::Int64=500, use::Symbol=:nonstiff)
  @assert stop > start
  @assert length(biomass) == size(parameters[:A],1)
  @assert length(concentration) == 2
  if parameters[:productivity] == :nutrients
      biomass = vcat(biomass, concentration)
  end

  @assert use ∈ vec([:stiff :nonstiff])
  alg = use == :stiff ? Rodas4(autodiff=false) : Tsit5()

  S = size(parameters[:A], 1)

  # Pre-allocate the timeseries matrix
  tspan = (float(start), float(stop))
  t_keep = collect(start:0.25:stop)

  # Perform the actual integration
  prob = ODEProblem(dBdt, biomass, tspan, parameters)

  function species_under_extinction_threshold(u, t, integrator)
    return minimum(integrator.u) < (100.0*eps())
  end

  function remove_species!(integrator)
    for i in eachindex(integrator.u)
      integrator.u[i] = integrator.u[i] < 100.0*eps() ? 0.0 : integrator.u[i]
    end
  end

  function remove_species_and_rewire!(integrator)
    remove_species!(integrator)
    parameters = update_rewiring_parameters(parameters, integrator.u)
  end

  affect_function = parameters[:rewire_method] == :none ? remove_species! : remove_species_and_rewire!
  extinction_callback = DiscreteCallback(species_under_extinction_threshold, affect_function; save_positions=(false,false))

  sol = solve(prob, alg, callback = CallbackSet(PositiveDomain(), extinction_callback), saveat=t_keep, dense=false, save_timeseries=false, force_dtmin=true)

  B = hcat(sol.u...)'

  if parameters[:productivity] == :nutrients
      output = Dict{Symbol,Any}(
      :p => parameters,
      :t => sol.t,
      :B => B[:,1:S],
      :C => B[:,S+1:end]
      )
  else
      output = Dict{Symbol,Any}(
      :p => parameters,
      :t => sol.t,
      :B => B)
  end

  return output

end
