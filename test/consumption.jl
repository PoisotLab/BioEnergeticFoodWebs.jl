module FunctionalResponse
  using Test
  using BioEnergeticFoodWebs

  foodchain = [0 1 0; 0 0 1; 0 0 0]
  omnivory = [0 1 1; 0 0 1; 0 0 0]
  init_biomass = [0.5, 0.3, 0.8]
  for a in [foodchain, omnivory]
      for i in [1.0, 2.0]
          for j in [0.0, 1.0]
              p = model_parameters(a, h = i, c = j)
              ω = a ./ sum(a, dims = 2)
              ω[isnan.(ω)] .= 0.0
              @test p[:w] == ω
              num = ω .* (init_biomass' .^ i)
              bm = zeros(eltype(init_biomass), (length(init_biomass), length(init_biomass)))
              BioEnergeticFoodWebs.fill_bm_matrix!(bm, init_biomass, p[:w], p[:A], p[:h])
              @test num == bm
              hsd = [0.5, 0.5, 0.0] .^ i
              @test p[:Γh] == hsd
              ip = j .* hsd .* init_biomass
              fa = sum(num, dims = 2)
              den = hsd .+ ip .+ fa
              f_calc = num./den
              f_calc[isnan.(f_calc)] .= 0.0
              f = zeros(eltype(init_biomass), (length(init_biomass), length(init_biomass)))
              BioEnergeticFoodWebs.fill_F_matrix!(f, num, init_biomass, hsd, j)
              @test f == f_calc

              p = model_parameters(a, h = i, c = j, vertebrates = [true, false, false])
              x = [0.88, 0.3141, 0.138] #metabolic rates
              y = [4.0, 8.0, 0.0] #max. consumption efficiency
              eff = [0.0 0.85 0.45; 0.0 0.0 0.45; 0.0 0.0 0.0] #max. efficiency

              inflows = x .* y .* init_biomass .* f_calc
              outflows = inflows ./ eff
              outflows[isnan.(outflows)] .= 0.0

              infl, outfl = BioEnergeticFoodWebs.consumption(p, init_biomass)
              @test infl == vec(sum(inflows, dims = 2))
              @test outfl == vec(sum(outflows, dims = 1))
          end
      end
  end
end
