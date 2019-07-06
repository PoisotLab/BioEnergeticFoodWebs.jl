using BioEnergeticFoodWebs
using Test

A = [0 1 0 ; 0 0 1 ; 0 0 0]
ddm = [0.2]
p = model_parameters(A, d = ddm)

@test all(p[:d] .== [0.2, 0.2, 0.0])
b = [0.5, 0.6, 0.8]
PI_death = BioEnergeticFoodWebs.density_dependent_mortality(p, b)
@test all(PI_death .== b .* ddm .* Int.(.!p[:is_producer]))

dbdt = BioEnergeticFoodWebs.dBdt(zeros(3), b, p, 1)

# Consumption
gain, loss = BioEnergeticFoodWebs.consumption(p, b)

# Growth
growth, G = BioEnergeticFoodWebs.get_growth(p, b)

# Balance
balance = zeros(eltype(b), length(b))
for i in eachindex(balance)
  balance[i] = growth[i] + gain[i] - loss[i] - PI_death[i]
end

@test all(dbdt .== balance)
