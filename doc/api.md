# befwm

## Exported

---

<a id="method__foodweb_diversity.1" class="lexicon_definition"></a>
#### foodweb_diversity(p) [¶](#method__foodweb_diversity.1)
**Food web diversity**

Based on the average of Shannon's entropy over the last `last` timesteps.



*source:*
[befwm/src/measures.jl:96](file:///home/tpoisot/.julia/v0.4/befwm/src/measures.jl)

---

<a id="method__model_parameters.1" class="lexicon_definition"></a>
#### model_parameters(A) [¶](#method__model_parameters.1)
**Create default parameters**

This function creates model parameters, based on a food web
matrix. Specifically, the default values are:

| Parameter      | Default Value | Meaning                                                                             |
|----------------|---------------|-------------------------------------------------------------------------------------|
| K              | 1.0           | carrying capacity of producers                                                      |
| Z              | 1.0           | consumer-resource body mass ratio                                                   |
| r              | 1.0           | growth rate of producers                                                            |
| a_invertebrate | 0.314         | allometric constant for invertebrate consumers                                      |
| a_producers    | 1.0           | allometric constant of producers                                                    |
| a_vertebrate   | 0.88          | allometric constant for vertebrate consumers                                        |
| c              | 0             | quantifies the predator interference                                                |
| h              | 1             | Hill coefficient                                                                    |
| e_carnivore    | 0.85          | assimilation efficiency of carnivores                                               |
| e_herbivore    | 0.45          | assimilation efficiency of herbivores                                               |
| m_producers    | 1             | body-mass of producers                                                              |
| y_invertebrate | 8             | maximum consumption rate of invertebrate predators relative to their metabolic rate |
| y_vertebrate   | 4             | maximum consumption rate of vertebrate predators relative to their metabolic rate   |
| Γ              | 0.5           | half-saturation density                                                             |

All of these values are passed as optional keyword arguments to the function.

Alternatively, every parameter can be used as a *keyword* argument when calling the function. For example

    A = [0 1 1; 0 0 0; 0 0 0]
    p = model_parameters(A, Z=100.0)

The final keyword is `vertebrates`, which is an array of `true` or `false`
for every species in the matrix. By default, all species are invertebrates.


*source:*
[befwm/src/make_parameters.jl:34](file:///home/tpoisot/.julia/v0.4/befwm/src/make_parameters.jl)

---

<a id="method__nichemodel.1" class="lexicon_definition"></a>
#### nichemodel(S::Int64,  C::Float64) [¶](#method__nichemodel.1)
**Niche model of food webs**

Takes a number of species `S` and a connectance `C`, and returns a food web
with predators in rows, and preys in columns. Note that the connectance is
first transformed into an integer number of interactions.



*source:*
[befwm/src/random.jl:70](file:///home/tpoisot/.julia/v0.4/befwm/src/random.jl)

---

<a id="method__nichemodel.2" class="lexicon_definition"></a>
#### nichemodel(S::Int64,  L::Int64) [¶](#method__nichemodel.2)
**Niche model of food webs**

Takes a number of species `S` and a number of interactions `L`, and returns
a food web with predators in rows, and preys in columns.



*source:*
[befwm/src/random.jl:20](file:///home/tpoisot/.julia/v0.4/befwm/src/random.jl)

---

<a id="method__population_biomass.1" class="lexicon_definition"></a>
#### population_biomass(p) [¶](#method__population_biomass.1)
**Per species biomass**

Returns the average biomass of all species, over the last `last` timesteps.



*source:*
[befwm/src/measures.jl:56](file:///home/tpoisot/.julia/v0.4/befwm/src/measures.jl)

---

<a id="method__population_stability.1" class="lexicon_definition"></a>
#### population_stability(p) [¶](#method__population_stability.1)
**Population stability**

Takes a matrix with populations in columns, timesteps in rows. This is usually
the element `:B` of the simulation output. Population stability is measured
as the mean of the negative coefficient of variations of all species with
an abundance higher than `threshold`. By default, the stability is measure
over the last `last=1000` timesteps.



*source:*
[befwm/src/measures.jl:23](file:///home/tpoisot/.julia/v0.4/befwm/src/measures.jl)

---

<a id="method__simulate.1" class="lexicon_definition"></a>
#### simulate(p,  biomass) [¶](#method__simulate.1)
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
- `use` (defaults to `:ode45`), the integration method

Note that the value of `steps` is the number of intermediate steps when moving
from `t` to `t+1`. The total number of steps is therefore on the order of
(stop - start) * steps.

Because this results in very large simulations, the function will return
results with a timestep equal to unity.

The integration method is, by default, `:ode45`, and can be changed to one of
`:ode23`, `:ode45`, `:ode78`, or `:ode23s`.

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



*source:*
[befwm/src/simulate.jl:46](file:///home/tpoisot/.julia/v0.4/befwm/src/simulate.jl)

---

<a id="method__total_biomass.1" class="lexicon_definition"></a>
#### total_biomass(p) [¶](#method__total_biomass.1)
**Total biomass**

Returns the sum of biomass, average over the last `last` timesteps.



*source:*
[befwm/src/measures.jl:40](file:///home/tpoisot/.julia/v0.4/befwm/src/measures.jl)

---

<a id="method__trophic_rank.1" class="lexicon_definition"></a>
#### trophic_rank(L::Array{Int64, 2}) [¶](#method__trophic_rank.1)
**Trophic rank**

Based on the average distance of preys to primary producers. Specifically, the
rank is defined as the average of the distance of preys to primary producers
(recursively). Primary producers always have a trophic rank of 1.



*source:*
[befwm/src/trophic_rank.jl:42](file:///home/tpoisot/.julia/v0.4/befwm/src/trophic_rank.jl)

## Internal

---

<a id="method__check_food_web.1" class="lexicon_definition"></a>
#### check_food_web(A) [¶](#method__check_food_web.1)
**Is the matrix correctly formatted?**

A *correct* matrix has only 0 and 1, two dimensions, and is square.

This function returns nothing, but raises an `AssertionError` if one of the
conditions is not met.


*source:*
[befwm/src/checks.jl:9](file:///home/tpoisot/.julia/v0.4/befwm/src/checks.jl)

---

<a id="method__check_parameters.1" class="lexicon_definition"></a>
#### check_parameters(p) [¶](#method__check_parameters.1)
**Are the simulation parameters present?**

This function will make sure that all the required parameters are here,
and that the arrays and matrices have matching dimensions.


*source:*
[befwm/src/checks.jl:44](file:///home/tpoisot/.julia/v0.4/befwm/src/checks.jl)

---

<a id="method__coefficient_of_variation.1" class="lexicon_definition"></a>
#### coefficient_of_variation(x) [¶](#method__coefficient_of_variation.1)
**Coefficient of variation**

Corrected for the sample size.



*source:*
[befwm/src/measures.jl:7](file:///home/tpoisot/.julia/v0.4/befwm/src/measures.jl)

---

<a id="method__dbdt.1" class="lexicon_definition"></a>
#### dBdt(t,  biomass,  derivative,  p::Dict{Symbol, Any}) [¶](#method__dbdt.1)
**Derivatives**

This function is the one wrapped by the various integration routines. Based
on a timepoint `t`, an array of biomasses `biomass`, an equally sized array
of derivatives `derivative`, and a series of simulation parameters `p`,
it will return `dB/dt` for every species.

Note that at the end of the function, we perform different checks to ensure
that nothing wacky happens during subsequent integration steps. Specifically,
if B+dB/dt < ϵ(0.0), we set dBdt to -B. ϵ(0.0) is the next value above
0.0 that your system can represent.



*source:*
[befwm/src/dBdt.jl:15](file:///home/tpoisot/.julia/v0.4/befwm/src/dBdt.jl)

---

<a id="method__distance_to_producer.1" class="lexicon_definition"></a>
#### distance_to_producer(L::Array{Int64, 2}) [¶](#method__distance_to_producer.1)
**Distance to a primary producer**

This function measures, for every species, its shortest path to a primary
producer using matrix exponentiation. A primary producer has a value of 1,
a primary consumer a value of 2, and so forth.



*source:*
[befwm/src/trophic_rank.jl:9](file:///home/tpoisot/.julia/v0.4/befwm/src/trophic_rank.jl)

---

<a id="method__inner_simulation_loop.1" class="lexicon_definition"></a>
#### inner_simulation_loop!(output,  p,  i,  f) [¶](#method__inner_simulation_loop.1)
**Inner simulation loop**

This function is called internally by `simulate`, and should not be called
by the user.

Note that `output` is a pre-allocated array in which the simulation result
will be written, and `i` is the origin of the simulation.



*source:*
[befwm/src/simulate.jl:96](file:///home/tpoisot/.julia/v0.4/befwm/src/simulate.jl)

---

<a id="method__make_initial_parameters.1" class="lexicon_definition"></a>
#### make_initial_parameters(A) [¶](#method__make_initial_parameters.1)
**Make initial parameters**

Used internally by `model_parameters`.


*source:*
[befwm/src/make_parameters.jl:67](file:///home/tpoisot/.julia/v0.4/befwm/src/make_parameters.jl)

---

<a id="method__make_parameters.1" class="lexicon_definition"></a>
#### make_parameters(p::Dict{Symbol, Any}) [¶](#method__make_parameters.1)
**Make the complete set of parameters**

This function will add simulation parameters, based on the output of
`make_initial_parameters`. Used internally by `model_parameters`.



*source:*
[befwm/src/make_parameters.jl:105](file:///home/tpoisot/.julia/v0.4/befwm/src/make_parameters.jl)

---

<a id="method__save.1" class="lexicon_definition"></a>
#### save(p::Dict{Symbol, Any}) [¶](#method__save.1)
**Save the output of a simulation**

Takes a simulation output as a mandatory argument. The two keyword arguments
are `as` (can be `:json` or `:jld`), defining the file format, and `filename`
(without an extension, defaults to `NaN`). If `:jld` is used, the variable
is named `befwm_simul` unless a `varname` is given.

Called with the defaults, this function will write `befwm_xxxxxxxx.json`
with the current simulation output, where `xxxxxxxx` is a hash of the `p`
output (ensuring that all output files are unique).

This function is *not* exported, so it must be called with `befwm.save`.



*source:*
[befwm/src/measures.jl:121](file:///home/tpoisot/.julia/v0.4/befwm/src/measures.jl)

---

<a id="method__shannon.1" class="lexicon_definition"></a>
#### shannon(n) [¶](#method__shannon.1)
**Shannon's entropy**

Corrected for the number of species, removes negative and null values, return
`NaN` in case of problem.



*source:*
[befwm/src/measures.jl:73](file:///home/tpoisot/.julia/v0.4/befwm/src/measures.jl)

---

<a id="method__wrap_ode.1" class="lexicon_definition"></a>
#### wrap_ode(i,  f,  b,  t) [¶](#method__wrap_ode.1)
**Wrapper for ode functions**

The solvers in `ODE.jl` have a different API from `Sundials.jl`. These
functions will let `ODE` do its job, then return the results in way we
can handle.


*source:*
[befwm/src/simulate.jl:170](file:///home/tpoisot/.julia/v0.4/befwm/src/simulate.jl)

---

<a id="method__wrap_ode23.1" class="lexicon_definition"></a>
#### wrap_ode23(f,  b,  t) [¶](#method__wrap_ode23.1)
**Wrapper for ode23**

See `wrap_ode`.


*source:*
[befwm/src/simulate.jl:132](file:///home/tpoisot/.julia/v0.4/befwm/src/simulate.jl)

---

<a id="method__wrap_ode23s.1" class="lexicon_definition"></a>
#### wrap_ode23s(f,  b,  t) [¶](#method__wrap_ode23s.1)
**Wrapper for ode23s**

See `wrap_ode`.


*source:*
[befwm/src/simulate.jl:141](file:///home/tpoisot/.julia/v0.4/befwm/src/simulate.jl)

---

<a id="method__wrap_ode45.1" class="lexicon_definition"></a>
#### wrap_ode45(f,  b,  t) [¶](#method__wrap_ode45.1)
**Wrapper for ode45**

See `wrap_ode`.


*source:*
[befwm/src/simulate.jl:150](file:///home/tpoisot/.julia/v0.4/befwm/src/simulate.jl)

---

<a id="method__wrap_ode78.1" class="lexicon_definition"></a>
#### wrap_ode78(f,  b,  t) [¶](#method__wrap_ode78.1)
**Wrapper for ode78**

See `wrap_ode`.


*source:*
[befwm/src/simulate.jl:159](file:///home/tpoisot/.julia/v0.4/befwm/src/simulate.jl)

