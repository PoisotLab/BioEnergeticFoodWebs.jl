include("src/BioEnergeticFoodWebs.jl")
using BioEnergeticFoodWebs
using Plots

S = 15
A = nichemodel(S, 0.2)
parameters = model_parameters(A)
bm = rand(Float64, S).*0.05

@time sim = simulate(parameters, bm; stop=500, use=:stiff)
#plot(sim[:t], sim[:B], leg=false, c=:teal)

vec(sum(sim[:B].>0.0, 2)) |> x -> plot!(sim[:t], x, leg=false)

minimum(sim[:B])
