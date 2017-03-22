# First simulation

Starting a simulation has three steps: getting the network, deciding on the
parameters, and then starting the simulation itself.

In this example, we will start with a simple generation of the null model,
then generate the default set of parameters (see `?model_parameters`),
and start a short simulation.

Do keep in mind that all functions are documented, so you can type in
`?function_name` from within *Julia*, and get access to the documentation.

```julia
A = nichemodel(10, 0.3);
p = model_parameters(A);
b = rand(size(A, 1));

s = simulate(p, b, start=0, stop=50, steps=1000)
```

The `A` matrix, which is used by subsequent functions, has predators in rows,
and preys in columns. It can only have 0 and 1.
