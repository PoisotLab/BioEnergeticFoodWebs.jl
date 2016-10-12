``` @meta
CurrentModule = BioEnergeticFoodWebs
```

# Internal Documentation

## Contents

```@contents
Pages = ["internals.md"]
```

## Index

```@index
Pages = ["internals.md"]
```

## Functions and methods for networks

```@docs
connectance
distance_to_producer
trophic_rank
check_food_web
```

## ODE wrappers and functions for integration

```@docs
wrap_ode23
wrap_ode23s
wrap_ode45
wrap_ode78
wrap_ode
dBdt
growthrate
```


## Functions to work on output

```@docs
coefficient_of_variation
shannon
```

## Functions to prepare and check parameters

```@docs
make_initial_parameters
make_parameters
check_initial_parameters
check_parameters
```
