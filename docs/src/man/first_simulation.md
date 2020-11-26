# First simulation

Starting a simulation has three steps: 

1. getting the network, 
2. deciding on the parameters, 
3. and then starting the simulation itself.

For a detailed description of the core model, see [Delmas et al.,
2017][https://besjournals.onlinelibrary.wiley.com/doi/full/10.1111/2041-210X.12713],
however, since the publication of this software note, we have added many
interesting new features. In this example, we will start with a simple
generation of the null model, then generate the default set of parameters (see
`?model_parameters`), and start a short simulation.

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

## Other useful packages

If you are here, you are probably interested in analysing food web structures and dynamics. Here are a few packages that can help you do that:
- [Mangal][https://github.com/EcoJulia/Mangal.jl] is a wrapper around the API for the [mangal][https://mangal.io/#/] ecological interactions database. This will allow you to get some nice empirical food webs from aroung the world. 
- [EcologicalNetworks][https://github.com/EcoJulia/EcologicalNetworks.jl] provides a common interface to analyze all types of data on ecological networks, so if you want to calculate your food web degree distribution, maximum food chain length, modularity, etc., now you can. 
- [EcologicalNetworksPlots][https://github.com/EcoJulia/EcologicalNetworksPlots.jl]: and now you can plot your food webs too!