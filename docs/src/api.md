# Reference

## User functions

This page lists the functions that are exported by `befwm`, in the other
where you are likely to use them.

### Simulations

~~~@docs
model_parameters
simulate
~~~

### Measures on output

All of these functions work on the output of `simulate`

~~~@docs
population_stability
population_biomass
total_biomass
foodweb_diversity
befwm.save
~~~

### Network utilities

```@docs
trophic_rank
nichemodel
```

## Internal functions

These functions are unlikely to bee needed in a common workflow, but are
presented here in case you need to manipulate the internals of `befwm`.

### Preparation of parameters

~~~@docs
befwm.make_initial_parameters
befwm.make_parameters
~~~

### Internal simulation functions

~~~@docs
befwm.dBdt
befwm.inner_simulation_loop!
~~~

### Numerical integration

~~~@docs
befwm.wrap_ode
befwm.wrap_ode45
befwm.wrap_ode78
befwm.wrap_ode23
befwm.wrap_ode23s
~~~

### Internal checks

~~~@docs
befwm.check_parameters
befwm.check_food_web
~~~

### Other functions

~~~@docs
befwm.shannon
befwm.coefficient_of_variation
befwm.distance_to_producer
~~~
