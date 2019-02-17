module FunctionalResponse
  using Base.Test
  using BioEnergeticFoodWebs

foodchain = [0 1 0; 0 0 1; 0 0 0]
init_biomass = [0.5, 0.3, 0.8]
for i in [1.0, 2.0]
    for j in [0.0, 1.0]
        p = model_parameters(foodchain, h = i, c = j)
        ω = foodchain ./ sum(foodchain, 2)
        ω[isnan.(ω)] .= 0.0
        @test p[:w] == ω
        num = ω .* (init_biomass' .^ i)
        bm = zeros(eltype(init_biomass), (length(init_biomass), length(init_biomass)))
        BioEnergeticFoodWebs.fill_bm_matrix!(bm, init_biomass, p[:w], p[:A], p[:h])
        # testfun(bm, init_biomass, p[:w], p[:A], p[:h])
        @test num == bm
        hsd = [0.5, 0.5, 0.0] .^ i
        @test p[:Γh] == hsd
        ip = j .* hsd .* init_biomass
        fa = sum(num, 2)
        den = hsd .+ ip .+ fa
        f_calc = num./den
        f_calc[isnan.(f_calc)] .= 0.0
        f = zeros(eltype(init_biomass), (length(init_biomass), length(init_biomass)))
        BioEnergeticFoodWebs.fill_F_matrix!(f, num, init_biomass, hsd, j)
        # testfunF(f, num, init_biomass, hsd, j)
        @test f == f_calc
    end
end

end
