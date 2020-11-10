module FunctionalResponse
  using Test
  using BioEnergeticFoodWebs

  foodchain = [0 1 0; 0 0 1; 0 0 0]
  omnivory = [0 1 1; 0 0 1; 0 0 0]
  init_biomass = [0.5, 0.3, 0.8]
  for a in [foodchain, omnivory]
    for i in [1.0, 2.0]
        for j in [0.0, 1.0]
            j = repeat([j], length(init_biomass))
            p = model_parameters(a, h = i, c = j)
            ω = a ./ sum(a, dims = 2)
            ω[isnan.(ω)] .= 0.0
            @test p[:w] == ω
            num = ω .* (init_biomass' .^ i)
            bm = zeros(eltype(init_biomass), (length(init_biomass), length(init_biomass)))
            fr = p[:functional_response]
            ar = p[:ar]
            ht = p[:ht]
            BioEnergeticFoodWebs.fill_bm_matrix!(bm, init_biomass, p[:w], p[:A], p[:h], fr, ar)
            @test num == bm
            hsd = [0.5, 0.5, 0.0] .^ i
            @test p[:Γh] == hsd
            ip = j .* hsd .* init_biomass
            fa = sum(num, dims = 2)
            den = hsd .+ ip .+ fa
            f_calc = num./den
            f_calc[isnan.(f_calc)] .= 0.0
            f = zeros(eltype(init_biomass), (length(init_biomass), length(init_biomass)))
            BioEnergeticFoodWebs.fill_F_matrix!(f, num, init_biomass, hsd, j, ht, fr)
            @test f == f_calc
            p = model_parameters(a, h = i, c = j, vertebrates = [true, false, false])
            x = [0.88, 0.3141, 0.138] #metabolic rates
            y = [4.0, 8.0, 0.0] #max. consumption efficiency
            eff = a == foodchain ? [0.0 0.85 0.0; 0.0 0.0 0.45; 0.0 0.0 0.0] : [0.0 0.85 0.45; 0.0 0.0 0.45; 0.0 0.0 0.0] #max. efficiency
            inflows = x .* y .* init_biomass .* f_calc
            outflows = inflows ./ eff
            outflows[isnan.(outflows)] .= 0.0
            xyb_model = zeros(eltype(init_biomass), length(init_biomass))
            BioEnergeticFoodWebs.fill_xyb_matrix!(xyb_model, init_biomass, p[:x], p[:y], p[:functional_response])
            @test xyb_model == x .* y .* init_biomass
            infl, outfl = BioEnergeticFoodWebs.consumption(p, init_biomass)
            @test infl == vec(sum(inflows, dims = 2))
            @test outfl == vec(sum(outflows, dims = 1))
          end
      end
  end

end

module ClassicalFR
    using BioEnergeticFoodWebs
    using Test

    foodchain = [0 1 0; 0 0 1; 0 0 0]
    omnivory = [0 1 1; 0 0 1; 0 0 0]
    init_biomass = [0.5, 0.3, 0.8]
    for a in [foodchain, omnivory]
      for i in [1.0, 2.0]
          for j in [0.0, 1.0]
              #atype = a == foodchain ? "foodchain" : "omnivory"
              #println("$atype - $i - $j")
              j = repeat([j], length(init_biomass))
              p = model_parameters(a, h = i, c = j, functional_response = :classical)
              fr = p[:functional_response]
              ar = p[:ar] .* a
              ht = p[:ht] .* a
              ht[isnan.(ht)] .= 0.0
              p[:ar] = ar
              p[:ht] = ht
              num = zeros(eltype(init_biomass), (length(init_biomass), length(init_biomass)))
              for l in 1:size(a,1), m in 1:size(a,1)
                num[l,m] = ar[l,m] .* (init_biomass[m] ^ i) * a[l,m]
              end
              bm = zeros(eltype(init_biomass), (length(init_biomass), length(init_biomass)))
              BioEnergeticFoodWebs.fill_bm_matrix!(bm, init_biomass, p[:w], p[:A], p[:h], fr, ar)
              @test num == bm
              fa = zeros(eltype(init_biomass), (length(init_biomass), length(init_biomass)))
              for l in 1:size(a,1), m in 1:size(a,1)
                fa[l,m] = num[l,m] * ht[l,m]
              end
              fa = sum(fa, dims = 2)
              den = zeros(eltype(init_biomass), length(init_biomass))
              for l in 1:size(a,1)
                den[l] = 1 + j[l] + fa[l]
              end
              f_calc = num./den
              f_calc[isnan.(f_calc)] .= 0.0
              f = zeros(eltype(init_biomass), (length(init_biomass), length(init_biomass)))
              hsd = [0.5, 0.5, 0.0] .^ i
              BioEnergeticFoodWebs.fill_F_matrix!(f, num, init_biomass, hsd, j, ht, fr)
              @test f == f_calc
              eff = a == foodchain ? [0.0 0.85 0.0; 0.0 0.0 0.45; 0.0 0.0 0.0] : [0.0 0.85 0.45; 0.0 0.0 0.45; 0.0 0.0 0.0] #max. efficiency
              inflows = init_biomass .* f_calc .* eff
              outflows = init_biomass .* f_calc
              xyb_model = zeros(eltype(init_biomass), length(init_biomass))
              BioEnergeticFoodWebs.fill_xyb_matrix!(xyb_model, init_biomass, p[:x], p[:y], p[:functional_response])
              @test xyb_model == init_biomass
              infl, outfl = BioEnergeticFoodWebs.consumption(p, init_biomass)
              @test infl == vec(sum(inflows, dims = 2))
              @test outfl == vec(sum(outflows, dims = 1))
            end
        end
    end
  
end