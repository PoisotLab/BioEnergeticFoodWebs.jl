"""
**Main simulation loop**

    simulate(parameters, biomass; start::Int64=0, stop::Int64=500, use::Symbol=:stiff)

This function takes two mandatory arguments:

- `p` is a `Dict` as returned by `make_parameters`
- `biomass` is an `Array{Float64, 1}` with the initial biomasses of every species

Internally, the function will check that the length of `biomass` matches
with the size of the network.

In addition, the function takes seven optional arguments:

- `start` (defaults to 0), the initial time
- `stop` (defaults to 500), the final time
- `use` (defaults to `:stiff`), a hint to select the solver
- `cb_interp_points` (default to 100), number of interpolation points used to check for an event (extinction)
- `extinction_threshold` (default to 1e-6), biomass below which a species is considered as extinct
- `interval_tkeep` (default to 0.25), controls the density of the outputs, defaukt behavior is to save outputs at times = [start:interval_tkeep:stop]

The integration method is, by default, `:stiff`, and can be changed to
`:nonstiff`. This is because internally, this function used the
`DifferentialEquations` package to pick the most appropriate algorithm.

The `simulate` function returns a `Dict{Symbol, Any}`, with three
top-level keys:

- `:p`, the parameters that were given as input
- `:t`, the timesteps
- `:B`, an `Array{Float64, 2}` with the biomasses

If a nutient intake model is used for productivity, a `C` Array is also returned, with the 2 nutrients concentrations through time

The array of biomasses (and nutrients concentrations if applicable) has one row for each timestep, and one column for
each species.
"""
function simulate(parameters, biomass; n_concentration::Vector{Float64}=rand(Float64, 2).*10, start::Int64=0, stop::Int64=500, use::Symbol=:nonstiff, cb_interp_points::Int64=100, extinction_threshold::Float64=1e-6, interval_tkeep::Number=0.25)
  @assert stop > start
  @assert length(biomass) == size(parameters[:A],1)
  @assert length(n_concentration) == 2
  if parameters[:productivity] == :nutrients
      biomass = vcat(biomass, n_concentration)
  end

  @assert use ∈ vec([:stiff :nonstiff])
  alg = use == :stiff ? Rodas4(autodiff=false) : Tsit5()

  S = size(parameters[:A], 1)

  # Pre-allocate the timeseries matrix
  tspan = (float(start), float(stop))
  t_keep = collect(start:interval_tkeep:stop)

  # Perform the actual integration
  prob = ODEProblem(dBdt, biomass, tspan, parameters)

  ϵ = []

  function species_under_extinction_threshold(u, t, integrator)
    workingbm = deepcopy(u)
    sort!(ϵ)
    deleteat!(workingbm, unique(ϵ))
    cond = any(x -> x < extinction_threshold, workingbm) ? -0.0 : 1.0
    return cond
  end

  function remove_species!(integrator)
    u = integrator.u
    idϵ = findall(x -> x < extinction_threshold, u)
    for e in idϵ
        if !(e ∈ ϵ)
            u[e] = 0.0
            append!(ϵ,e)
        end
    end
    sort!(ϵ)
    nothing
  end

  function remove_species_and_update!(integrator)
    remove_species!(integrator)
    if parameters[:productivity] == :nutrients
      workingbm = deepcopy(integrator.u[1:end-2])
    else
      workingbm = deepcopy(integrator.u)
    end
    parameters = update_rewiring_parameters(parameters, workingbm, integrator.t)
  end

  function remove_target_and_update!(u, t, integrator)
    remove_species!(integrator)
    if parameters[:productivity] == :nutrients
      workingbm = deepcopy(integrator.u[1:end-2])
    else
      workingbm = deepcopy(integrator.u)
    end
    parameters = BioEnergeticFoodWebs.update_rewiring_parameters(parameters, workingbm, integrator.t)
  end

  cb = species_under_extinction_threshold
  affect_function = remove_species_and_update!
  if parameters[:rewire_method] == :ADBM
    if parameters[:adbm_trigger] == :interval
      Δt = parameters[:adbm_interval]
      cb1 = PeriodicCallback(affect_function, Δt)
    else
      cb1 = ContinuousCallback(cb, affect_function, interp_points = cb_interp_points)
    end
  else
    cb1 = ContinuousCallback(cb, affect_function, interp_points = cb_interp_points)
  end

  is_any_extinct = any(biomass .< extinction_threshold)
  if is_any_extinct
    cb2 = FunctionCallingCallback(remove_target_and_update!, funcat = [0.0])
    extinction_callback = CallbackSet(cb1, cb2)
  else
    extinction_callback = cb1
  end

  sol = solve(prob, alg, callback = extinction_callback, saveat=t_keep, dense=false, save_timeseries=false, force_dtmin=false)

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
