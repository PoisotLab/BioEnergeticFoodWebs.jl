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
function simulate(parameters, biomass; concentration::Vector{Float64}=rand(Float64, 2).*10, start::Int64=0, stop::Int64=500, use::Symbol=:nonstiff, cb_interp_points::Int64=100, extinction_threshold::Float64=100*eps())
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
  prob = ODEProblem(BioEnergeticFoodWebs.dBdt, biomass, tspan, parameters)

  ϵ = []

  function species_under_extinction_threshold_nutrients(u, t, integrator)
    workingbm = deepcopy(integrator.u[1:end-2])
    sort!(ϵ)
    deleteat!(workingbm, unique(ϵ))
    #cond = any(x -> x < 100*eps(), workingbm) ? 0.0 : 1.0
    cond = any(x -> x < extinction_threshold, workingbm) ? 0.0 : 1.0
    return cond
  end

  function species_under_extinction_threshold(u, t, integrator)
    workingbm = deepcopy(u)
    sort!(ϵ)
    deleteat!(workingbm, unique(ϵ))
    #cond = any(x -> x < 100*eps(), workingbm) ? 0.0 : 1.0
    cond = any(x -> x < extinction_threshold, workingbm) ? -0.0 : 1.0
    return cond
  end

  function remove_species!(integrator)
    println(integrator.t)
    u = integrator.u
    #workingbm = deepcopy(u)
    #idϵ = findall(x -> x < 100*eps(), workingbm)
    idϵ = findall(x -> x < extinction_threshold, u)
    for e in idϵ
        if !(e ∈ ϵ)
            u[e] = 0.0
            append!(ϵ,e)
        end
    end
    sort!(ϵ)
    # deleteat!(workingbm, unique(ϵ))
    # append!(ϵ,idϵ)
    # u[idϵ] .= 0.0
    nothing
  end

  function remove_species_and_rewire!(integrator)
    remove_species!(integrator)
    if parameters[:productivity] == :nutrients
      workingbm = deepcopy(integrator.u[1:end-2])
    else
      workingbm = deepcopy(integrator.u)
    end
    parameters = update_rewiring_parameters(parameters, workingbm, integrator.t)
  end

  cb = parameters[:productivity] == :nutrients ? species_under_extinction_threshold_nutrients : species_under_extinction_threshold
  affect_function = parameters[:rewire_method] == :none ? remove_species! : remove_species_and_rewire!
  extinction_callback = ContinuousCallback(cb, affect_function, abstol = 1e-6, interp_points = cb_interp_points)
  #justincase_callback = PeriodicCallback(affect_function, periodic_check)
  #CBset =  CallbackSet(extinction_callback, justincase_callback)

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
