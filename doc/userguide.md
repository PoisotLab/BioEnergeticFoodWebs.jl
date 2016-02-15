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

### Differences between solvers and potential issues

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

### A simple benchmark

For reference, we present a simple benchmark of the different solvers (the
code is given below). We generated a solution using `:Sundials` with 1000
intermediate steps, for 200 timesteps, with a network of 30 species. We
then measure the execution time of every solver, with the same starting
conditions, and with an increasing number of timesteps. The outputs are (i)
the execution time and (ii) the absolute error to the `:Sundials` solution:

| Solver    | steps | time (s.) |   error |
|-----------|-------|----------:|--------:|
| `:ode23`  | 10    |      0.29 | 1.26e-5 |
|           | 50    |      0.21 | 1.26e-5 |
|           | 100   |      0.23 | 1.26e-5 |
|           | 500   |      0.33 | 1.26e-5 |
|           | 1000  |      0.58 | 1.26e-5 |
| `:ode45`  | 10    |      0.21 | 1.26e-5 |
|           | 50    |      0.23 | 1.26e-5 |
|           | 100   |      0.23 | 1.26e-5 |
|           | 500   |      0.45 | 1.26e-5 |
|           | 1000  |      0.49 | 1.26e-5 |
| `:ode78`  | 10    |      0.60 | 1.25e-5 |
|           | 50    |      0.78 | 1.25e-5 |
|           | 100   |      0.63 | 1.25e-5 |
|           | 500   |      0.90 | 1.25e-5 |
|           | 1000  |      0.98 | 1.25e-5 |
| `:Euler`  | 10    |      0.10 | 1.03e-4 |
|           | 50    |      0.52 | 2.12e-5 |
|           | 100   |      1.27 | 1.58e-5 |
|           | 500   |      5.99 | 1.18e-5 |
|           | 1000  |     12.00 | 1.15e-5 |
| `:ode23s` | 10    |     35.87 | 1.25e-5 |
|           | 50    |     36.14 | 1.25e-5 |
|           | 100   |     32.96 | 1.25e-5 |
|           | 500   |     23.54 | 1.25e-5 |
|           | 1000  |     28.91 | 1.25e-5 |

And here is the code:

~~~ julia 
using befwm

A = nichemodel(30, 135)
b0 = rand(30)

Solver = (:ode23, :ode45, :ode78, :Euler, :ode23s)

p = make_initial_parameters(A)
p = make_parameters(p)

stop = 200
steps = vec([10 50 100 500 1000])

println(:Sundials)
@time ref = simulate(p, b0, stop=stop, steps=1000, use=:Sundials)
ref_b = ref[:B][end,:]

for s in Solver
    println(s)
    for st in steps
        @time com = simulate(p, b0, stop=stop, steps=st, use=s)
        println("  ", st, " Error: ", sum(abs(ref_b .- com[:B][end,:]))/30)
    end
end
~~~
