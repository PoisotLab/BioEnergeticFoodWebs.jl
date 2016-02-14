# User guide

If you have followed the instructions for installation in the first pages
of this manual, from within julia, `befwm` can be imported as usual:

~~~ julia
using befwm
~~~

In this part of the manual, we will walk through the overall design and
usage of `befwm`.

Specifically, we will cover how to run simulations, generate random networks,
then deal with the output of the simulations.

## A note on integration

The system can be integrated using `Sundials.jl` (the default), the Euler
method, or one of the solvers in `ODE.jl`. Both of these approaches have
different advantages and pitfalls, and we will briefly discuss them here.

`Sundials.jl` is a wrapper around the library of the same name, and represent
the current "state of the art" of numerical integration in Julia. It is
by far the fastest solution, and tends to give better results. This being
said, solving a system with more than 20 species *is* a challenging task,
and it may give rise to integration errors. For small simulations (*e.g.*
when teaching), `Sundials` should be the obvious choice.

The Euler method is (currently) much slower, and not precise for less than
1000 intermediate timesteps. It is included for the sake of completeness,
but should not really be used in real-life situations.

The solvers in `ODE.jl` are intended to become a pure-Julia, efficient
solution for numerical integration. It is expected that they will replace
`Sundials` as the default in the future. They tend to give good results,
but have intermediate performances.

Depending on the situation, you may want to explore different combinations
of numbers of intermediate steps, and type of solver.

Note, however, that `Sundials.jl` currently has a huge memory leak. What
it means, in practice, is that memory allocated for a simulation is not
release after the simulation is done. This is currently being fixed, but as
a consequence, it is difficult to use `:Sundials` for many simulations in a
row. We had good success with `:ode45` as a replacement for `:Sundials`. There
is a decline in performance associated, but not a gigantic one. In terms of
overall performance, the two slowest options are `:Euler` and `:ode23s`. In
the `ODE.jl` family, `:ode45` is the fastest, and `:ode23` and `:ode78`
have similar speeds.

In addition, note that the solvers will only return the biomasses for *integer*
timesteps, no matter what the number of intermediate steps is. This is because
the memory footprints of simulations can rapidly become prohibitive otherwise.
