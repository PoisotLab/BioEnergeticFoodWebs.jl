
<a id='Overview-of-the-simulation-1'></a>

## Overview of the simulation


Running a simulation has three steps. First, setting up a series of initial parameters. Second, generating the body sizes, metabolic rates, *etc.*. Finally, starting the simulation itself.


Starting from a network `A`, this is as simple as


```julia
A = [0 1 0 0; 0 0 1 1; 0 0 0 0; 0 0 0 0]
p = model_parameters(A)
initial_biomass = rand(size(A, 1))
d = simulate(p, initial_biomass, start=0, stop=100, steps=10000)
```


We will see in the next sections what each of these steps do.


All networks are expected to be square, with only `0` or `1`, and have predators in rows and preys in columns. In addition, it is expected that *at least* one species is a primary producer (*i.e.* at least one of the rows in the matrix has no interaction). This is checked internally by the different functions.


<a id='Create-model-parameters-1'></a>

### Create model parameters


First, create or import an interaction matrix, with predators in rows and preys in columns:


```julia
#=
Predators are in rows, so this corresponds to a "diamond" food web: 1 eats
2 and 3, and 2 and 3 eat 4. 1 is a top predator, 2 and 3 are intermediate
consumers, and 4 is a primary producer.
=#
A = [0 1 1 0; 0 0 0 1; 0 0 0 1; 0 0 0 0]

# We start with random biomasses in [0;1]
initial_biomasses = rand(size(A, 1))
```


Once done, get the initial parameters, and if needed change some of their values:


```julia
p = model_parameters(A, Z=2.0)
```


To see what the initial parameters values are, either look at the `p` object, or (better) at the help of `model_parameters`, with


```
?model_parameters
```


<a id='Simulation-1'></a>

### Simulation


To start with random biomasses:


```julia
println(simulate(p, initial_biomasses))
```

