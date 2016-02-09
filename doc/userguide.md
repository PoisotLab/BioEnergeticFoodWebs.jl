# Installation

Currently, the easiest way to install this package is to clone it, and either
use the `Makefile` (`make install`), or start julia from within the package
directory, and:

~~~ julia
Pkg.clone(pwd())
using befwm
~~~

# Overview of the simulation

Running a simulation has three steps. First, setting up a series of
initial parameters. Second, generating the body sizes, metabolic rates,
*etc.*. Finally, starting the simulation itself.

Starting from a network `A`, this is as simple as

~~~ julia
A = [0 1 0 0; 0 0 1 1; 0 0 0 0; 0 0 0 0]
p = make_initial_parameters(A)
p = make_parameters(p)
initial_biomass = rand(size(A, 1))
d = simulate(p, initial_biomass, start=0, stop=100, steps=10000)
~~~

We will see in the next sections what each of these steps do.

All networks are expected to be square, with only `0` or `1`, and have
predators in rows and preys in columns. In addition, it is expected that
*at least* one species is a primary producer (*i.e.* at least one of the
rows in the matrix has no interaction). This is checked internally by the
different functions.

# Running a simulation

## Create simulation parameters

First, create or import an interaction matrix, with predators in rows and
preys in columns:

~~~ julia
diamond_food_web = [0 1 1 0; 0 0 0 1; 0 0 0 1; 0 0 0 0]
~~~

Once done, get the initial parameters:

~~~ julia
p = make_initial_parameters(A)
~~~

This function will generate most of the metabolic rates, etc. Once this step
is done, you can change the values of some parameters, *e.g.*:

~~~ julia
p[:Z] = 2.0 # Scaling of body mass with trophic rank
~~~

Once this is done, you need to generate some additional simulation parameters
(such as the efficiency matrix):

~~~ julia
p = make_parameters(p)
~~~

When this is done, the simulation is ready to start.

## Simulation

To start with random biomasses:

~~~julia
println(simulate(p, rand(size(A)[1])))
~~~
