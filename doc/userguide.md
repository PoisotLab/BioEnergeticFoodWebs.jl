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

In addition, note that the solvers will only return the biomasses for *integer*
timesteps, no matter what the number of intermediate steps is. This is because
the memory footprints of simulations can rapidly become prohibitive otherwise.
