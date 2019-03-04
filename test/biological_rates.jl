module TestDefault
  using Test
  using BioEnergeticFoodWebs

  food_chain = [0 1 0 ; 0 0 1; 0 0 0]
  metab_status = [true, false, false]
  p = model_parameters(food_chain, vertebrates = metab_status)

  # DEFAULT ARG.
  # growth rates
  @test p[:r] == [1, 1, 1]
  # metabolic rates
  a_invertebrate = 0.3141
  a_vertebrate = 0.88
  a_producer = 0.138
  @test p[:x] == [a_vertebrate, a_invertebrate, a_producer]
  # maximum consumption rate
  y_vertebrate = 4.0
  y_invertebrate = 8.0
  y_producer = 0.0
  @test p[:y] == [y_vertebrate, y_invertebrate, y_producer]
  # handling time
  @test p[:ht] == 1 ./ p[:y]
  # attack rate
  @test p[:ar] == 1 ./ (0.5 * p[:ht])
  # half saturation constant
  hsc = 1 ./ (p[:ar] .* p[:ht])
  hsc[isnan.(hsc)] .= 0.0
  @test p[:Γ] == hsc

  # PASSED ARG.
  p = model_parameters(food_chain, vertebrates = metab_status,
                       handlingtime = NoEffectTemperature(:handlingtime, parameters_tuple = (y_vertebrate = 3.0, y_invertebrate = 7.0)),
                       attackrate = NoEffectTemperature(:attackrate, parameters_tuple = (Γ = 0.8,)),
                       metabolicrate = NoEffectTemperature(:metabolism, parameters_tuple = (a_vertebrate = 0.8, a_invertebrate = 0.3, a_producer = 0.1)),
                       growthrate = NoEffectTemperature(:growth, parameters_tuple = (r = 2.0,)))
  @test p[:r] == [2.0, 2.0, 2.0]
  # metabolic rates
  a_invertebrate = 0.3
  a_vertebrate = 0.8
  a_producer = 0.1
  @test p[:x] == [a_vertebrate, a_invertebrate, a_producer]
  # maximum consumption rate
  y_vertebrate = 3.0
  y_invertebrate = 7.0
  y_producer = 0.0
  @test p[:y] == [y_vertebrate, y_invertebrate, y_producer]
  # handling time
  @test p[:ht] == 1 ./ p[:y]
  # attack rate
  @test p[:ar] == 1 ./ (0.8 * p[:ht])
  # half saturation constant
  hsc = 1 ./ (p[:ar] .* p[:ht])
  hsc[isnan.(hsc)] .= 0.0
  @test p[:Γ] == hsc
  @test p[:Γ] == [0.8, 0.8, 0.0]

  # Different temperatures, same rates
  temp2 = 293.15
  p2 = model_parameters(food_chain, T = temp2, vertebrates = metab_status,
                       handlingtime = NoEffectTemperature(:handlingtime, parameters_tuple = (y_vertebrate = 3.0, y_invertebrate = 7.0)),
                       attackrate = NoEffectTemperature(:attackrate, parameters_tuple = (Γ = 0.8,)),
                       metabolicrate = NoEffectTemperature(:metabolism, parameters_tuple = (a_vertebrate = 0.8, a_invertebrate = 0.3, a_producer = 0.1)),
                       growthrate = NoEffectTemperature(:growth, parameters_tuple = (r = 2.0,)))
  @test p[:r] == p2[:r]
  @test p[:x] == p2[:x]
  @test p[:ht] == p2[:ht]
  @test p[:ar] == p2[:ar]


  # ERRORS

  @test_throws Exception model_parameters(food_chain, vertebrates = metab_status, handlingtime = NoEffectTemperature(:y))
  @test_throws Exception model_parameters(food_chain, vertebrates = metab_status, attackrate = NoEffectTemperature(:y))
  @test_throws Exception model_parameters(food_chain, vertebrates = metab_status, metabolicrate = NoEffectTemperature(:y))
  @test_throws Exception model_parameters(food_chain, vertebrates = metab_status, growthrate = NoEffectTemperature(:y))

end

module TestEppley
  using Test
  using BioEnergeticFoodWebs

  omnivory = [0 1 1 ; 0 0 1 ; 0 0 0]
  metabolic_status = [:true, :false, :false]
  bmass = [100.0, 10.0, 1.0]
  temp = 270.0

  # GROWTH - defaults
  p_g_def = model_parameters(omnivory, T = temp, bodymass = bmass, vertebrates = metabolic_status, growthrate = ExtendedEppley(:r))
  r_g_def = bmass .^ -0.25 .* 0.81 .* exp(0.0631 .* (temp.-273.15)) * (1 .- (((temp.-273.15) .- (298.15-273.15)) ./ (35/2)).^2)
  @test p_g_def[:r] == r_g_def

  # GROWTH - changing temperature
  temp_2 = 250.0
  p_g_temp = model_parameters(omnivory, T = temp_2, bodymass = bmass, vertebrates = metabolic_status, growthrate = ExtendedEppley(:r))
  r_g_temp = bmass .^ -0.25 .* 0.81 .* exp(0.0631 .* (temp_2.-273.15)) * (1 .- (((temp_2.-273.15) .- (298.15-273.15)) ./ (35/2)).^2)
  @test p_g_temp[:r] == r_g_temp

  # GROWTH - negative outside of range
  mintemp = 298.15-17.5
  maxtemp = 298.15+17.5
  p_r_min = model_parameters(omnivory, T = mintemp, bodymass = bmass, vertebrates = metabolic_status, growthrate = ExtendedEppley(:r))
  p_r_max = model_parameters(omnivory, T = maxtemp, bodymass = bmass, vertebrates = metabolic_status, growthrate = ExtendedEppley(:r))
  @test p_r_min[:r] == p_r_max[:r] == [0.0, 0.0, 0.0]
  inftemp = mintemp - 1
  suptemp = maxtemp + 1
  p_r_inf = model_parameters(omnivory, T = inftemp, bodymass = bmass, vertebrates = metabolic_status, growthrate = ExtendedEppley(:r))
  p_r_sup = model_parameters(omnivory, T = suptemp, bodymass = bmass, vertebrates = metabolic_status, growthrate = ExtendedEppley(:r))
  @test !any(x -> x > 0, p_r_inf[:r])

  # GROWTH - passed
  pt = (maxrate_0 = 0.6, eppley_exponent = 0.1, z = 215, β = -0.2, range = 20)
  p_g = model_parameters(omnivory, T = temp, bodymass = bmass, vertebrates = metabolic_status, growthrate = ExtendedEppley(:r, parameters_tuple = pt))
  r_g = bmass .^ -0.2 .* 0.6 .* exp(0.1 .* (temp.-273.15)) * (1 .- (((temp.-273.15) .- (215-273.15)) ./ (20/2)).^2)
  @test p_g[:r] == r_g

  # METABOLISM - default
  p_x_def = model_parameters(omnivory, T = temp, bodymass = bmass, vertebrates = metabolic_status, metabolicrate = ExtendedEppley(:x))
  @test p_x_def[:x] == p_g_def[:r]

  # METABOLISM - changing temperature
  p_x_temp = model_parameters(omnivory, T = temp_2, bodymass = bmass, vertebrates = metabolic_status, metabolicrate = ExtendedEppley(:x))
  @test p_x_temp[:x] == p_g_temp[:r]

  # METABOLISM - negative outside of range
  mintemp = 298.15-17.5
  maxtemp = 298.15+17.5
  p_x_min = model_parameters(omnivory, T = mintemp, bodymass = bmass, vertebrates = metabolic_status, metabolicrate = ExtendedEppley(:metabolicrate))
  p_x_max = model_parameters(omnivory, T = maxtemp, bodymass = bmass, vertebrates = metabolic_status, metabolicrate = ExtendedEppley(:metabolicrate))
  @test p_x_min[:x] == p_x_max[:x] == [0.0, 0.0, 0.0]
  inftemp = mintemp - 1
  suptemp = maxtemp + 1
  p_x_inf = model_parameters(omnivory, T = inftemp, bodymass = bmass, vertebrates = metabolic_status, metabolicrate = ExtendedEppley(:metabolicrate))
  p_x_sup = model_parameters(omnivory, T = suptemp, bodymass = bmass, vertebrates = metabolic_status, metabolicrate = ExtendedEppley(:metabolicrate))
  @test !any(x -> x > 0, p_x_inf[:x])


  # METABOLISM - passed arguments
  pt_x = (maxrate_0_producer = 0.8, maxrate_0_invertebrate = 0.6, maxrate_0_vertebrate = 5,
      eppley_exponent_producer = 0.1, eppley_exponent_invertebrate = 0.06, eppley_exponent_vertebrate = 0.09,
      z_producer = 298, z_invertebrate = 250, z_vertebrate = 270,
      range_producer = 30, range_invertebrate = 32, range_vertebrate = 33,
      β_producer = -0.2, β_invertebrate = -0.3, β_vertebrate = -0.27)
  p_x = model_parameters(omnivory, T = temp, bodymass = bmass, vertebrates = metabolic_status, metabolicrate = ExtendedEppley(:x, parameters_tuple = pt_x))
  maxrate_0_all = [5, 0.6, 0.8]
  eppley_exponent_all = [0.09, 0.06, 0.1]
  z_all = [270, 250, 298]
  z_all = z_all .- 273.15
  range_all = [33, 32, 30]
  β_all = [-0.27, -0.3, -0.2]
  x_x = bmass.^β_all .* maxrate_0_all .* exp.(eppley_exponent_all .* (temp.-273.15)) .* (1 .- (((temp.-273.15) .- z_all) ./ (range_all./2)).^2)
  @test x_x == p_x[:x]

  # ERRORS
  @test_throws Exception model_parameters(omnivory, metabolicrate = ExtendedEppley(:handlingtime))
  @test_throws Exception model_parameters(omnivory, metabolicrate = ExtendedEppley(:attackrate))
  @test_throws Exception model_parameters(omnivory, metabolicrate = ExtendedEppley(:y))

end

module TestExponentialBA
  using Test
  using BioEnergeticFoodWebs

  omnivory = [0 1 1 ; 0 0 1 ; 0 0 0]
  metabolic_status = [:true, :false, :false]
  bmass = [100.0, 10.0, 1.0]
  temp = 270.0

  #GROWTH
  #defaults
  p_r_d = model_parameters(omnivory, T = temp, bodymass = bmass, vertebrates = metabolic_status, growthrate = ExponentialBA(:r))
  k = 8.617e-5
  r_d = exp(-15.68) .* 4e6 .* (bmass .^-0.25) .* exp.(-0.84 .* (293.15 .- temp) ./ (k .* temp .* 293.15))
  @test p_r_d[:r] == r_d
  #change temperature
  temp2 = 250.0
  p_r_t = model_parameters(omnivory, T = temp2, bodymass = bmass, vertebrates = metabolic_status, growthrate = ExponentialBA(:r))
  r_t = exp(-15.68) .* 4e6 .* (bmass .^-0.25) .* exp.(-0.84 .* (293.15 .- temp2) ./ (k .* temp2 .* 293.15))
  @test p_r_t[:r] == r_t
  #rate increases with temperature
  @test !any(p_r_t[:r] .> p_r_d[:r])
  #passed arguments
  pt_r = (norm_constant = exp(-18), activation_energy = -0.8, T0 = 290, β = -0.31)
  p_r_2 = model_parameters(omnivory, T = temp, bodymass = bmass, vertebrates = metabolic_status, growthrate = ExponentialBA(:r, parameters_tuple = pt_r))
  r_2 = exp(-18) .* (bmass .^-0.31) .* exp.(-0.8 .* (290 .- temp) ./ (k .* temp .* 290))
  @test p_r_2[:r] == r_2

  #METABOLISM
  #defaults
  p_x_d = model_parameters(omnivory, T = temp, bodymass = bmass, vertebrates = metabolic_status, metabolicrate = ExponentialBA(:x))
  x_d = exp(-16.54) .* 4e6 .* (bmass .^-0.31) .* exp.(-0.69 .* (293.15 .- temp) ./ (k .* temp .* 293.15))
  @test p_x_d[:x] == x_d
  #change temperature
  p_x_t = model_parameters(omnivory, T = temp2, bodymass = bmass, vertebrates = metabolic_status, metabolicrate = ExponentialBA(:x))
  x_t = exp(-16.54) .* 4e6 .* (bmass .^-0.31) .* exp.(-0.69 .* (293.15 .- temp2) ./ (k .* temp2 .* 293.15))
  @test p_x_t[:x] == x_t
  #rate increases with temperature
  @test !any(p_x_t[:x] .> p_x_d[:x])
  #passed arguments
  pt_x = (norm_constant_producer = exp(-16), norm_constant_invertebrate = exp(-17), norm_constant_vertebrate = exp(-18),
             activation_energy_producer = -0.6, activation_energy_invertebrate = -0.7, activation_energy_vertebrate = -0.8,
             T0_producer = 270, T0_invertebrate = 280, T0_vertebrate = 290,
             β_producer = -0.2, β_invertebrate = -0.3, β_vertebrate = -0.4)
  norm_constant_all = [-18, -17, -16]
  activation_energy_all = [-0.8, -0.7, -0.6]
  T0_all = [290, 280, 270]
  β_all = [-0.4, -0.3, -0.2]
  p_x_2 = model_parameters(omnivory, T = temp, bodymass = bmass, vertebrates = metabolic_status, metabolicrate = ExponentialBA(:x, parameters_tuple = pt_x))
  x_2 = exp.(norm_constant_all) .* (bmass .^β_all) .* exp.(activation_energy_all .* (T0_all .- temp) ./ (k .* temp .* T0_all))
  @test p_x_2[:x] == x_2

  #ATTACK
  #defaults
  p_ar_d = model_parameters(omnivory, T = temp, bodymass = bmass, vertebrates = metabolic_status, attackrate = ExponentialBA(:attackrate))
  ar_d = exp.([-13.1, -13.1, 0.0]) .* 4e6 .* (bmass .^[-0.8, -0.8, 0.0]) .* (bmass' .^[0 -0.8 0.25; 0 0 0.25 ; 0 0 0]) .* exp.([-0.38, -0.38, 0.0] .* ([293.15, 293.15, 0.0] .- temp) ./ (k .* temp .* [293.15, 293.15, 0.0]))
  ar_d[isnan.(ar_d)] .= 0
  @test p_ar_d[:ar] == ar_d
  #change temperature
  p_ar_t = model_parameters(omnivory, T = temp2, bodymass = bmass, vertebrates = metabolic_status, attackrate = ExponentialBA(:attackrate))
  ar_t = exp.([-13.1, -13.1, 0.0]) .* 4e6 .* (bmass .^[-0.8, -0.8, 0.0]) .* (bmass' .^[0 -0.8 0.25; 0 0 0.25 ; 0 0 0]) .* exp.([-0.38, -0.38, 0.0] .* ([293.15, 293.15, 0.0] .- temp2) ./ (k .* temp2 .* [293.15, 293.15, 0.0]))
  ar_t[isnan.(ar_t)] .= 0
  @test p_ar_t[:ar] == ar_t
  #rate increases with temperature
  @test !any(p_ar_t[:ar] .> p_ar_d[:ar])
  #passed arguments
  pt_ar = (norm_constant_vertebrate = exp(-12), norm_constant_invertebrate = exp(-14),
  						activation_energy_vertebrate = -0.3, activation_energy_invertebrate = -0.4,
  						T0_vertebrate = 290, T0_invertebrate = 270,
  						β_producer = 0.2, β_vertebrate = -0.9, β_invertebrate = -0.7)
  p_ar_2 = model_parameters(omnivory, T = temp, bodymass = bmass, vertebrates = metabolic_status, attackrate = ExponentialBA(:attackrate, parameters_tuple = pt_ar))
  ar_2 = exp.([-12, -14, 0.0]) .* (bmass .^[-0.9, -0.7, 0.0]) .* (bmass' .^[0 -0.7 0.2; 0 0 0.2 ; 0 0 0]) .* exp.([-0.3, -0.4, 0.0] .* ([290, 270, 0.0] .- temp) ./ (k .* temp .* [290, 270, 0.0]))
  ar_2[isnan.(ar_2)] .= 0
  @test p_ar_2[:ar] == ar_2

  #HANDLING
  #defaults
  p_ht_d = model_parameters(omnivory, T = temp, bodymass = bmass, vertebrates = metabolic_status, handlingtime = ExponentialBA(:handlingtime))
  ht_d = exp.([9.66, 9.66, 0.0]) .* 4e6 .* (bmass .^[0.47, 0.47, 0.0]) .* (bmass' .^[0.0 0.47 -0.45 ; 0 0 -0.45; 0 0 0]) .* exp.([0.26, 0.26, 0.0] .* ([293.15, 293.15, 0.0] .- temp) ./ (k .* temp .* [293.15, 293.15, 0.0]))
  ht_d[isnan.(ht_d)] .= 0
  @test p_ht_d[:ht] == ht_d
  #change temperature
  p_ht_t = model_parameters(omnivory, T = temp2, bodymass = bmass, vertebrates = metabolic_status, handlingtime = ExponentialBA(:handlingtime))
  ht_t = exp.([9.66, 9.66, 0.0]) .* 4e6 .* (bmass .^[0.47, 0.47, 0.0]) .* (bmass' .^[0.0 0.47 -0.45 ; 0 0 -0.45; 0 0 0]) .* exp.([0.26, 0.26, 0.0] .* ([293.15, 293.15, 0.0] .- temp2) ./ (k .* temp2 .* [293.15, 293.15, 0.0]))
  ht_t[isnan.(ht_t)] .= 0
  @test p_ht_t[:ht] == ht_t
  #rate decreases with temperature
  @test !any(p_ht_t[:ht] .< p_ht_d[:ht])
  #passed arguments
  pt_ht = (norm_constant_vertebrate = exp(9), norm_constant_invertebrate = exp(10),
  						activation_energy_vertebrate = 0.2, activation_energy_invertebrate = 0.3,
  						T0_vertebrate = 290, T0_invertebrate = 270,
  						β_producer = -0.4, β_vertebrate = 0.3, β_invertebrate = 0.5)
  p_ht_2 = model_parameters(omnivory, T = temp, bodymass = bmass, vertebrates = metabolic_status, handlingtime = ExponentialBA(:handlingtime, parameters_tuple = pt_ht))
  ht_2 = exp.([9, 10, 0.0]) .* (bmass .^[0.3, 0.5, 0.0]) .* (bmass' .^[0.0 0.5 -0.4 ; 0 0 -0.4; 0 0 0]) .* exp.([0.2, 0.3, 0.0] .* ([290, 270, 0.0] .- temp) ./ (k .* temp .* [290, 270, 0.0]))
  ht_2[isnan.(ht_2)] .= 0
  @test p_ht_2[:ht] == ht_2

  #ERRORS
  @test_throws Exception model_parameters(omnivory, metabolicrate = ExponentialBA(:y))

end

module TestExtendedBA
  using Test
  using BioEnergeticFoodWebs

  omnivory = [0 1 1 ; 0 0 1 ; 0 0 0]
  metabolic_status = [:true, :false, :false]
  bmass = [100.0, 10.0, 1.0]
  temp = 270.0
  temp2 = 250.0
  k = 8.617e-5 # Boltzmann constant

  #GROWTH
  #defaults
  p_r_d = model_parameters(omnivory, T = temp, bodymass = bmass, vertebrates = metabolic_status, growthrate = ExtendedBA(:r))
  Δenergy = 1.15 - 0.53
  r_d = 1.8e9 .* bmass .^(-0.25) .* exp.(.-0.53 ./ (k * temp)) .* (1 ./ (1 + exp.(-1 / (k * temp) .* (1.15 .- (1.15 ./ 298.15 .+ k .* log(0.53 ./ Δenergy)).*temp))))
  @test p_r_d[:r] == r_d
  #change temperature
  p_r_t = model_parameters(omnivory, T = temp2, bodymass = bmass, vertebrates = metabolic_status, growthrate = ExtendedBA(:r))
  @test p_r_d[:r] != p_r_t[:r]
  #passed arguments
  pt_r = (norm_constant = 4000,)
  p_r_2 = model_parameters(omnivory, T = temp, bodymass = bmass, vertebrates = metabolic_status, growthrate = ExtendedBA(:r, parameters_tuple = pt_r))
  r_2 = (r_d ./ 1.8e9) .* 4000
  @test p_r_2[:r] ≈ r_2 atol=1e-6
  #max rate at Topt
  p_r_inf = model_parameters(omnivory, T = 297.0, bodymass = bmass, vertebrates = metabolic_status, growthrate = ExtendedBA(:r))
  p_r_sup = model_parameters(omnivory, T = 299.0, bodymass = bmass, vertebrates = metabolic_status, growthrate = ExtendedBA(:r))
  p_r_opt = model_parameters(omnivory, T = 298.15, bodymass = bmass, vertebrates = metabolic_status, growthrate = ExtendedBA(:r))
  @test !any(p_r_opt[:r] .< p_r_sup[:r])
  @test !any(p_r_opt[:r] .< p_r_inf[:r])

  #METABOLISM
  #defaults
  p_x_d = model_parameters(omnivory, T = temp, bodymass = bmass, vertebrates = metabolic_status, metabolicrate = ExtendedBA(:x))
  x_d = 3e8 .* bmass .^(-0.25) .* exp.(.-[0.53, 0.53, 0.53] ./ (k * temp)) .* (1 ./ (1 .+ exp.(-1 ./ (k * temp) .* (1.15 .- (1.15 ./ 298.15 .+ k .* log.(0.53 ./ Δenergy)).* temp))))
  @test p_x_d[:x] == x_d
  #change temperature
  p_x_t = model_parameters(omnivory, T = temp2, bodymass = bmass, vertebrates = metabolic_status, metabolicrate = ExtendedBA(:x))
  @test p_x_t[:x] != p_x_d[:x]
  #passed arguments
  pt_x = (β_vertebrate = -0.5,)
  p_x_2 = model_parameters(omnivory, T = temp, bodymass = bmass, vertebrates = metabolic_status, metabolicrate = ExtendedBA(:x, parameters_tuple = pt_x))
  p_x_2[:x] != p_x_d[:x]
  x_2 = 3e8 .* bmass .^([-0.5, -0.25, -0.25]) .* exp.(.-[0.53, 0.53, 0.53] ./ (k * temp)) .* (1 ./ (1 .+ exp.(-1 ./ (k * temp) .* (1.15 .- (1.15 ./ 298.15 .+ k .* log.(0.53 ./ Δenergy)).* temp))))
  @test p_x_2[:x] == x_2
  #max rate at Topt
  p_x_inf = model_parameters(omnivory, T = 297.0, bodymass = bmass, vertebrates = metabolic_status, metabolicrate = ExtendedBA(:x))
  p_x_sup = model_parameters(omnivory, T = 299.0, bodymass = bmass, vertebrates = metabolic_status, metabolicrate = ExtendedBA(:x))
  p_x_opt = model_parameters(omnivory, T = 298.15, bodymass = bmass, vertebrates = metabolic_status, metabolicrate = ExtendedBA(:x))
  @test !any(p_x_opt[:x] .< p_x_sup[:x])
  @test !any(p_x_opt[:x] .< p_x_inf[:x])

  #ATTACK
  #defaults
  p_ar_d = model_parameters(omnivory, T = temp, bodymass = bmass, vertebrates = metabolic_status, attackrate = ExtendedBA(:attackrate))
  Δenergy = 1.15 - 0.8
  ar_d = [5e13, 5e13, 5e13] .* bmass .^([0.25, 0.25, 0.0]) .* bmass' .^([0.0 0.25 0.25 ; 0.0 0.0 0.25 ; 0.0 0.0 0.0]) .* exp.(.-[0.8, 0.8, 0.8] ./ (k * temp)) .* (1 ./ (1 .+ exp.(-1 / (k * temp) .* ([1.15, 1.15, 0.0] .- ([1.15, 1.15, 0.0] ./ [298.15, 298.15, 0.0] .+ k .* log.([0.8, 0.8, 0.0] ./ Δenergy)) .* temp))))
  ar_d[isnan.(ar_d)] .= 0
  @test p_ar_d[:ar] == ar_d
  #change temperature
  p_ar_t = model_parameters(omnivory, T = temp2, bodymass = bmass, vertebrates = metabolic_status, attackrate = ExtendedBA(:attackrate))
  @test p_ar_d[:ar] != p_ar_t[:ar]
  #passed arguments
  pt_ar = (norm_constant_invertebrate = 3e7,)
  p_ar_2 = model_parameters(omnivory, T = temp, bodymass = bmass, vertebrates = metabolic_status, attackrate = ExtendedBA(:attackrate, parameters_tuple = pt_ar))
  @test p_ar_2[:ar] != p_ar_d[:ar]
  ar_2 = [5e13, 3e7, 5e13] .* bmass .^([0.25, 0.25, 0.0]) .* bmass' .^([0.0 0.25 0.25 ; 0.0 0.0 0.25 ; 0.0 0.0 0.0]) .* exp.(.-[0.8, 0.8, 0.8] ./ (k * temp)) .* (1 ./ (1 .+ exp.(-1 / (k * temp) .* ([1.15, 1.15, 1.15] .- ([1.15, 1.15, 1.15] ./ [298.15, 298.15, 0.0] .+ k .* log.([0.8, 0.8, 0.8] ./ Δenergy)) .* temp))))
  @test p_ar_2[:ar] == ar_2
  #max rate at Topt
  p_ar_inf = model_parameters(omnivory, T = 297.0, bodymass = bmass, vertebrates = metabolic_status, attackrate = ExtendedBA(:attackrate))
  p_ar_sup = model_parameters(omnivory, T = 299.0, bodymass = bmass, vertebrates = metabolic_status, attackrate = ExtendedBA(:attackrate))
  p_ar_opt = model_parameters(omnivory, T = 298.15, bodymass = bmass, vertebrates = metabolic_status, attackrate = ExtendedBA(:attackrate))
  @test !any(p_ar_opt[:ar] .< p_ar_sup[:ar])
  @test !any(p_ar_opt[:ar] .< p_ar_inf[:ar])

  #ERRORS
  @test_throws Exception model_parameters(omnivory, T = temp, bodymass = bmass, vertebrates = metabolic_status, attackrate = ExtendedBA(:handlingtime))
  @test_throws Exception model_parameters(omnivory, T = temp, bodymass = bmass, vertebrates = metabolic_status, attackrate = ExtendedBA(:y))

end

module TestGaussian
  using Test
  using BioEnergeticFoodWebs

  omnivory = [0 1 1 ; 0 0 1 ; 0 0 0]
  metabolic_status = [:true, :false, :false]
  bmass = [100.0, 10.0, 1.0]
  temp = 270.0
  temp2 = 250.0

  #GROWTH
  #defaults
  p_r_d = model_parameters(omnivory, T = temp, bodymass = bmass, vertebrates = metabolic_status, growthrate = Gaussian(:r))
  r_d = bmass .^ -0.25 .* 1.0 .* exp( .- (temp .- 298.15) .^ 2 ./ (2 .* 20 .^ 2))
  @test p_r_d[:r] == r_d
  #change temperature
  p_r_t = model_parameters(omnivory, T = temp2, bodymass = bmass, vertebrates = metabolic_status, growthrate = Gaussian(:r))
  @test p_r_t[:r] != p_r_d[:r]
  #passed arguments
  pt_r = (norm_constant = 0.7,)
  p_r_2 = model_parameters(omnivory, T = temp, bodymass = bmass, vertebrates = metabolic_status, growthrate = Gaussian(:r, parameters_tuple = pt_r))
  @test p_r_2[:r] != p_r_d[:r]
  r_2 = bmass .^ -0.25 .* 0.7 .* exp( .- (temp .- 298.15) .^ 2 ./ (2 .* 20 .^ 2))
  @test p_r_2[:r] == r_2
  #max rate at Topt
  p_r_inf = model_parameters(omnivory, T = 297.0, bodymass = bmass, vertebrates = metabolic_status, growthrate = Gaussian(:r))
  p_r_sup = model_parameters(omnivory, T = 299.0, bodymass = bmass, vertebrates = metabolic_status, growthrate = Gaussian(:r))
  p_r_opt = model_parameters(omnivory, T = 298.15, bodymass = bmass, vertebrates = metabolic_status, growthrate = Gaussian(:r))
  @test !any(p_r_opt[:r] .< p_r_sup[:r])
  @test !any(p_r_opt[:r] .< p_r_inf[:r])

  #METABOLISM
  #defaults
  p_x_d = model_parameters(omnivory, T = temp, bodymass = bmass, vertebrates = metabolic_status, metabolicrate = Gaussian(:x))
  x_d = bmass .^ -0.25 .* [0.9, 0.35, 0.2] .* exp.( .- (temp .- 298.15) .^ 2 ./ (2 .* 20 .^ 2))
  @test p_x_d[:x] == x_d
  #change temperature
  p_x_t = model_parameters(omnivory, T = temp2, bodymass = bmass, vertebrates = metabolic_status, metabolicrate = Gaussian(:x))
  @test p_x_t[:x] != p_x_d[:x]
  #passed arguments
  pt_x = (range_producer = 30,)
  p_x_2 = model_parameters(omnivory, T = temp, bodymass = bmass, vertebrates = metabolic_status, metabolicrate = Gaussian(:x, parameters_tuple = pt_x))
  @test p_x_2[:x] != p_x_d[:x]
  x_2 = bmass .^ -0.25 .* [0.9, 0.35, 0.2] .* exp.( .- (temp .- 298.15) .^ 2 ./ (2 .* [20,20,30] .^ 2))
  @test p_x_2[:x] == x_2
  #max rate at Topt
  p_x_inf = model_parameters(omnivory, T = 297.0, bodymass = bmass, vertebrates = metabolic_status, metabolicrate = Gaussian(:x))
  p_x_sup = model_parameters(omnivory, T = 299.0, bodymass = bmass, vertebrates = metabolic_status, metabolicrate = Gaussian(:x))
  p_x_opt = model_parameters(omnivory, T = 298.15, bodymass = bmass, vertebrates = metabolic_status, metabolicrate = Gaussian(:x))
  @test !any(p_x_opt[:x] .< p_x_sup[:x])
  @test !any(p_x_opt[:x] .< p_x_inf[:x])

  #ATTACK
  #defaults
  p_ar_d = model_parameters(omnivory, T = temp, bodymass = bmass, vertebrates = metabolic_status, attackrate = Gaussian(:attackrate))
  ar_d = bmass .^ [-0.25,-0.25,0.0] .* bmass' .^ [0.0 -0.25 -0.25 ; 0.0 0.0 -0.25 ; 0.0 0.0 0.0] .* [16, 16, 0.0] .* exp.( .- (temp .- [295,295,0]) .^ 2 ./ (2 .* [20,20,0] .^ 2))
  ar_d[isnan.(ar_d)] .= 0
  @test p_ar_d[:ar] == ar_d
  #change temperature
  p_ar_t = model_parameters(omnivory, T = temp2, bodymass = bmass, vertebrates = metabolic_status, attackrate = Gaussian(:attackrate))
  @test p_ar_t[:ar] != p_ar_d[:ar]
  #passed arguments
  pt_ar = (T_opt_invertebrate = 270,)
  p_ar_2 = model_parameters(omnivory, T = temp, bodymass = bmass, vertebrates = metabolic_status, attackrate = Gaussian(:attackrate, parameters_tuple = pt_ar))
  @test p_ar_2[:ar] != p_ar_d[:ar]
  ar_2 = bmass .^ [-0.25,-0.25,0.0] .* bmass' .^ [0.0 -0.25 -0.25 ; 0.0 0.0 -0.25 ; 0.0 0.0 0.0] .* [16, 16, 0.0] .* exp.( .- (temp .- [295,270,0]) .^ 2 ./ (2 .* [20,20,0] .^ 2))
  ar_2[isnan.(ar_2)] .= 0
  @test p_ar_2[:ar] == ar_2
  #max rate at Topt
  p_ar_inf = model_parameters(omnivory, T = 293.0, bodymass = bmass, vertebrates = metabolic_status, attackrate = Gaussian(:attackrate))
  p_ar_sup = model_parameters(omnivory, T = 297.0, bodymass = bmass, vertebrates = metabolic_status, attackrate = Gaussian(:attackrate))
  p_ar_opt = model_parameters(omnivory, T = 295.0, bodymass = bmass, vertebrates = metabolic_status, attackrate = Gaussian(:attackrate))
  @test !any(p_ar_opt[:ar] .< p_ar_sup[:ar])
  @test !any(p_ar_opt[:ar] .< p_ar_inf[:ar])

  #HANDLING
  #defaults
  p_ht_d = model_parameters(omnivory, T = temp, bodymass = bmass, vertebrates = metabolic_status, handlingtime = Gaussian(:handlingtime))
  ht_d = bmass .^ [-0.25,-0.25,0.0] .* bmass' .^ [0.0 -0.25 -0.25 ; 0.0 0.0 -0.25 ; 0.0 0.0 0.0] .* [0.5, 0.5, 0.0] .* exp.((temp .- [295,295,0]) .^ 2 ./ (2 .* [20,20,0] .^ 2))
  ht_d[isnan.(ht_d)] .= 0
  @test p_ht_d[:ht] == ht_d
  #change temperature
  p_ht_t = model_parameters(omnivory, T = temp2, bodymass = bmass, vertebrates = metabolic_status, handlingtime = Gaussian(:handlingtime))
  @test p_ht_t[:ht] != p_ht_d[:ht]
  #passed arguments
  pt_ht = (T_opt_invertebrate = 270,)
  p_ht_2 = model_parameters(omnivory, T = temp, bodymass = bmass, vertebrates = metabolic_status, handlingtime = Gaussian(:handlingtime, parameters_tuple = pt_ht))
  @test p_ht_2[:ht] != p_ht_d[:ht]
  ht_2 = bmass .^ [-0.25,-0.25,0.0] .* bmass' .^ [0.0 -0.25 -0.25 ; 0.0 0.0 -0.25 ; 0.0 0.0 0.0] .* [0.5, 0.5, 0.0] .* exp.((temp .- [295,270,0]) .^ 2 ./ (2 .* [20,20,0] .^ 2))
  ht_2[isnan.(ht_2)] .= 0
  @test p_ht_2[:ht] == ht_2
  #min rate at Topt
  p_ht_inf = model_parameters(omnivory, T = 290.0, bodymass = bmass, vertebrates = metabolic_status, handlingtime = Gaussian(:handlingtime))
  p_ht_sup = model_parameters(omnivory, T = 305.0, bodymass = bmass, vertebrates = metabolic_status, handlingtime = Gaussian(:handlingtime))
  p_ht_opt = model_parameters(omnivory, T = 298.15, bodymass = bmass, vertebrates = metabolic_status, handlingtime = Gaussian(:handlingtime))
  @test !any(p_ht_opt[:ht] .> p_ht_sup[:ht])
  @test !any(p_ht_opt[:ht] .> p_ht_inf[:ht])


  #ERRORS
  @test_throws Exception model_parameters(omnivory, T = temp, bodymass = bmass, vertebrates = metabolic_status, handlingtime = Gaussian(:y))

end
