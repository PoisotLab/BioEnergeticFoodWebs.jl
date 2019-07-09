module TestDDMortality
    using BioEnergeticFoodWebs
    using Test

    A = [0 1 0 ; 0 0 1 ; 0 0 0]
    ddm = (x -> x .* 0.2)
    p = model_parameters(A, dc = ddm)

    b = [0.5, 0.6, 0.8]
    PI_death = BioEnergeticFoodWebs.density_dependent_mortality(p, b)
    @test all(PI_death .== ddm(b) .* Int.(.!p[:is_producer]))

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

    ddm_prod = (x -> x .^ 2 .* 0.1)
    p = model_parameters(A, dc = ddm, dp = ddm_prod)
    PI_death = BioEnergeticFoodWebs.density_dependent_mortality(p, b)
    mc = ddm(b).* Int.(.!p[:is_producer])
    mp = ddm_prod(b).* Int.(p[:is_producer])
    @test all(PI_death .== mc .+ mp)

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


end
