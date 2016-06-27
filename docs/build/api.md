
<a id='Reference-1'></a>

# Reference


<a id='User-functions-1'></a>

## User functions


This page lists the functions that are exported by `befwm`, in the other where you are likely to use them.


<a id='Simulations-1'></a>

### Simulations

<a id='befwm.model_parameters' href='#befwm.model_parameters'>#</a>
**`befwm.model_parameters`** &mdash; *Function*.



**Create default parameters**

This function creates model parameters, based on a food web matrix. Specifically, the default values are:

     Parameter | Default Value |                                                                             Meaning
-------------: | ------------: | ----------------------------------------------------------------------------------:
             K |           1.0 |                                                      carrying capacity of producers
             Z |           1.0 |                                                   consumer-resource body mass ratio
             r |           1.0 |                                                            growth rate of producers
a_invertebrate |         0.314 |                                      allometric constant for invertebrate consumers
   a_producers |           1.0 |                                                    allometric constant of producers
  a_vertebrate |          0.88 |                                        allometric constant for vertebrate consumers
             c |             0 |                                                quantifies the predator interference
             h |             1 |                                                                    Hill coefficient
   e_carnivore |          0.85 |                                               assimilation efficiency of carnivores
   e_herbivore |          0.45 |                                               assimilation efficiency of herbivores
   m_producers |             1 |                                                              body-mass of producers
y_invertebrate |             8 | maximum consumption rate of invertebrate predators relative to their metabolic rate
  y_vertebrate |             4 |   maximum consumption rate of vertebrate predators relative to their metabolic rate
             Γ |           0.5 |                                                             half-saturation density

All of these values are passed as optional keyword arguments to the function.

Alternatively, every parameter can be used as a *keyword* argument when calling the function. For example

```
A = [0 1 1; 0 0 0; 0 0 0]
p = model_parameters(A, Z=100.0)
```

The final keyword is `vertebrates`, which is an array of `true` or `false` for every species in the matrix. By default, all species are invertebrates.

<a id='befwm.simulate' href='#befwm.simulate'>#</a>
**`befwm.simulate`** &mdash; *Function*.



**Main simulation loop**

This function takes two mandatory arguments:

  * `p` is a `Dict` as returned by `make_parameters`
  * `biomass` is a `Array{Float64, 1}` with the initial biomasses of every species

Internally, the function will check that the length of `biomass` matches with the size of the network.

In addition, the function takes three optional arguments:

  * `start` (defaults to 0), the initial time
  * `stop` (defaults to 500), the final time
  * `steps` (defaults to 5000), the number of internal steps
  * `use` (defaults to `:ode45`), the integration method

Note that the value of `steps` is the number of intermediate steps when moving from `t` to `t+1`. The total number of steps is therefore on the order of (stop - start) * steps.

Because this results in very large simulations, the function will return results with a timestep equal to unity.

The integration method is, by default, `:ode45`, and can be changed to one of `:ode23`, `:ode45`, `:ode78`, or `:ode23s`.

The `simulate` function returns a `Dict{Symbol, Any}`, with three top-level keys:

  * `:p`, the parameters that were given as input
  * `:t`, the timesteps
  * `:B`, an `Array{Float64, 2}` with the biomasses

The array of biomasses has one row for each timestep, and one column for each species.

If the difference between stop and start is more than an arbitrary threshold (currently 500 timesteps), the simulations will be run in chunks of 500 timesteps each. This is because the amount of memory needed to store the dynamics scales very badly. To avoid `OutOfMemory()` errors, running the simulation by parts is sufficient.


<a id='Measures-on-output-1'></a>

### Measures on output


All of these functions work on the output of `simulate`

<a id='befwm.population_stability' href='#befwm.population_stability'>#</a>
**`befwm.population_stability`** &mdash; *Function*.



**Population stability**

Takes a matrix with populations in columns, timesteps in rows. This is usually the element `:B` of the simulation output. Population stability is measured as the mean of the negative coefficient of variations of all species with an abundance higher than `threshold`. By default, the stability is measure over the last `last=1000` timesteps.

<a id='befwm.population_biomass' href='#befwm.population_biomass'>#</a>
**`befwm.population_biomass`** &mdash; *Function*.



**Per species biomass**

Returns the average biomass of all species, over the last `last` timesteps.

<a id='befwm.total_biomass' href='#befwm.total_biomass'>#</a>
**`befwm.total_biomass`** &mdash; *Function*.



**Total biomass**

Returns the sum of biomass, average over the last `last` timesteps.

<a id='befwm.foodweb_diversity' href='#befwm.foodweb_diversity'>#</a>
**`befwm.foodweb_diversity`** &mdash; *Function*.



**Food web diversity**

Based on the average of Shannon's entropy over the last `last` timesteps.

<a id='befwm.save' href='#befwm.save'>#</a>
**`befwm.save`** &mdash; *Function*.



**Save the output of a simulation**

Takes a simulation output as a mandatory argument. The two keyword arguments are `as` (can be `:json` or `:jld`), defining the file format, and `filename` (without an extension, defaults to `NaN`). If `:jld` is used, the variable is named `befwm_simul` unless a `varname` is given.

Called with the defaults, this function will write `befwm_xxxxxxxx.json` with the current simulation output, where `xxxxxxxx` is a hash of the `p` output (ensuring that all output files are unique).

This function is *not* exported, so it must be called with `befwm.save`.


<a id='Network-utilities-1'></a>

### Network utilities

<a id='befwm.trophic_rank' href='#befwm.trophic_rank'>#</a>
**`befwm.trophic_rank`** &mdash; *Function*.



**Trophic rank**

Based on the average distance of preys to primary producers. Specifically, the rank is defined as the average of the distance of preys to primary producers (recursively). Primary producers always have a trophic rank of 1.

<a id='befwm.nichemodel' href='#befwm.nichemodel'>#</a>
**`befwm.nichemodel`** &mdash; *Function*.



**Niche model of food webs**

Takes a number of species `S` and a connectance `C`, and returns a food web with predators in rows, and preys in columns. Note that the connectance is first transformed into an integer number of interactions.

**Niche model of food webs**

Takes a number of species `S` and a number of interactions `L`, and returns a food web with predators in rows, and preys in columns.


<a id='Internal-functions-1'></a>

## Internal functions


These functions are unlikely to bee needed in a common workflow, but are presented here in case you need to manipulate the internals of `befwm`.


<a id='Preparation-of-parameters-1'></a>

### Preparation of parameters

<a id='befwm.make_initial_parameters' href='#befwm.make_initial_parameters'>#</a>
**`befwm.make_initial_parameters`** &mdash; *Function*.



**Make initial parameters**

Used internally by `model_parameters`.

<a id='befwm.make_parameters' href='#befwm.make_parameters'>#</a>
**`befwm.make_parameters`** &mdash; *Function*.



**Make the complete set of parameters**

This function will add simulation parameters, based on the output of `make_initial_parameters`. Used internally by `model_parameters`.


<a id='Internal-simulation-functions-1'></a>

### Internal simulation functions

<a id='befwm.dBdt' href='#befwm.dBdt'>#</a>
**`befwm.dBdt`** &mdash; *Function*.



**Derivatives**

This function is the one wrapped by the various integration routines. Based on a timepoint `t`, an array of biomasses `biomass`, an equally sized array of derivatives `derivative`, and a series of simulation parameters `p`, it will return `dB/dt` for every species.

Note that at the end of the function, we perform different checks to ensure that nothing wacky happens during subsequent integration steps. Specifically, if B+dB/dt < ϵ(0.0), we set dBdt to -B. ϵ(0.0) is the next value above 0.0 that your system can represent.

<a id='befwm.inner_simulation_loop!' href='#befwm.inner_simulation_loop!'>#</a>
**`befwm.inner_simulation_loop!`** &mdash; *Function*.



**Inner simulation loop**

This function is called internally by `simulate`, and should not be called by the user.

Note that `output` is a pre-allocated array in which the simulation result will be written, and `i` is the origin of the simulation.


<a id='Numerical-integration-1'></a>

### Numerical integration

<a id='befwm.wrap_ode' href='#befwm.wrap_ode'>#</a>
**`befwm.wrap_ode`** &mdash; *Function*.



**Wrapper for ode functions**

These functions will let `ODE` do its job, then return the results in way we can handle.

<a id='befwm.wrap_ode45' href='#befwm.wrap_ode45'>#</a>
**`befwm.wrap_ode45`** &mdash; *Function*.



**Wrapper for ode45**

See `wrap_ode`.

<a id='befwm.wrap_ode78' href='#befwm.wrap_ode78'>#</a>
**`befwm.wrap_ode78`** &mdash; *Function*.



**Wrapper for ode78**

See `wrap_ode`.

<a id='befwm.wrap_ode23' href='#befwm.wrap_ode23'>#</a>
**`befwm.wrap_ode23`** &mdash; *Function*.



**Wrapper for ode23**

See `wrap_ode`.

<a id='befwm.wrap_ode23s' href='#befwm.wrap_ode23s'>#</a>
**`befwm.wrap_ode23s`** &mdash; *Function*.



**Wrapper for ode23s**

See `wrap_ode`.


<a id='Internal-checks-1'></a>

### Internal checks

<a id='befwm.check_parameters' href='#befwm.check_parameters'>#</a>
**`befwm.check_parameters`** &mdash; *Function*.



**Are the simulation parameters present?**

This function will make sure that all the required parameters are here, and that the arrays and matrices have matching dimensions.

<a id='befwm.check_food_web' href='#befwm.check_food_web'>#</a>
**`befwm.check_food_web`** &mdash; *Function*.



**Is the matrix correctly formatted?**

A *correct* matrix has only 0 and 1, two dimensions, and is square.

This function returns nothing, but raises an `AssertionError` if one of the conditions is not met.


<a id='Other-functions-1'></a>

### Other functions

<a id='befwm.shannon' href='#befwm.shannon'>#</a>
**`befwm.shannon`** &mdash; *Function*.



**Shannon's entropy**

Corrected for the number of species, removes negative and null values, return `NaN` in case of problem.

<a id='befwm.coefficient_of_variation' href='#befwm.coefficient_of_variation'>#</a>
**`befwm.coefficient_of_variation`** &mdash; *Function*.



**Coefficient of variation**

Corrected for the sample size.

<a id='befwm.distance_to_producer' href='#befwm.distance_to_producer'>#</a>
**`befwm.distance_to_producer`** &mdash; *Function*.



**Distance to a primary producer**

This function measures, for every species, its shortest path to a primary producer using matrix exponentiation. A primary producer has a value of 1, a primary consumer a value of 2, and so forth.

