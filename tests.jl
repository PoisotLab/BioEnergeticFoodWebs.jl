include("src/BioEnergeticFoodWebs.jl")
using BioEnergeticFoodWebs
using Plots

S = 15
A = nichemodel(S, 0.2)
parameters = model_parameters(A)
bm = rand(Float64, S).*(1/S)

@time sim = simulate(parameters, bm; stop=500, use=:stiff)

minimum(sim[:B])

pl2 = vec(sum(sim[:B].>0.0, dims = 2)) |> x -> plot(sim[:t], x, leg=false)
pl1 = plot(sim[:t], sim[:B], leg=false, c=:teal)
plot(pl1, pl2)
