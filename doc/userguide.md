# Usage

## Installation

~~~ julia
Pkg.clone(pwd())
using befwm
~~~

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

# Simulation

To start with random biomasses:

~~~julia
println(simulate(p, rand(size(A)[1])))
~~~
