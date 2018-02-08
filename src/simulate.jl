"""
**Main simulation loop**

    simulate(p, biomass; start::Int64=0, stop::Int64=500, use::Symbol=:stiff)

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
function simulate(p, biomass; start::Int64=0, stop::Int64=500, use::Symbol=:nonstiff)
  @assert stop > start
  if p[:productivity] == :nutrients
      @assert length(biomass) == size(p[:A],1) + 2
  else
      @assert length(biomass) == size(p[:A],1)
  end

  @assert use ∈ vec([:stiff :nonstiff])

  S = size(p[:A],1)

  # Pre-allocate the timeseries matrix
  t = (float(start), float(stop))
  t_keep = collect(start:1.0:stop)

  # Pre-assign function
  f(t, y) = dBdt(t, y, p)

  # Perform the actual integration
  prob = ODEProblem(f, biomass, t)

  if use == :stiff
      alg = Rodas4()
  else
      alg = Tsit5()
  end

  if p[:rewire_method] == :none
      sol = solve(prob, alg, dtmax = 1, saveat=t_keep, dense=false, save_timeseries=false)
  else
      extspecies = Int[]
      #isext = falses(S)

      function condition(t,y,integrator)
        # if t == Int(round(t))
        #   println(minimum(y[.!isext]))
        # end
        isext = y .== 0.0
        !all(isext) ? minimum(y[.!isext]) : one(eltype(y))
      end

      function affect!(integrator)

        p = update_rewiring_parameters(p,integrator.u)
        #id extinct species
        isext = integrator.u .== 0.0
        minb = minimum(integrator.u[.!isext])
        sp_min = findin(integrator.u, minb)[1]
        #push id to extspecies
        push!(extspecies, sp_min)
        #isext[extspecies] = true
        #set biomass to 0 to avoid ghost species
        info(string("extinction of species ", sp_min))
        integrator.u[sp_min] = 0.0

      end

      cb = ContinuousCallback(condition,affect!, abstol = 1e-10)
      sol = solve(prob, alg, callback = cb, saveat=t_keep, dense=false, save_timeseries=false)
  end

  if p[:productivity] == :nutrients
      output = Dict{Symbol,Any}(
      :p => p,
      :t => sol.t,
      :B => hcat(sol.u...)'
      )
  else
      output = Dict{Symbol,Any}(
      :p => p,
      :t => sol.t,
      :B => hcat(sol.u...)'
      )
  end

  return output

end
