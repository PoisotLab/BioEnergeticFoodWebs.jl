module TestMakeParameters
  using BioEnergeticFoodWebs
  using Base.Test

  # Test the keyword interface
  correct_network = [0 1 0 0; 0 0 1 1; 0 0 0 0; 0 0 0 0]
  p = model_parameters(correct_network, Z=2.0)
  @test p[:Z] == 2.0

  # Test that producers, etc, are identified
  @test p[:is_producer][4] == true
  @test p[:is_producer][3] == true
  @test p[:is_producer][2] == false
  @test p[:is_producer][1] == false

  @test p[:is_herbivore][4] == false
  @test p[:is_herbivore][3] == false
  @test p[:is_herbivore][2] == true
  @test p[:is_herbivore][1] == false

  # Test the direct interface
  correct_network = [0 1 0 0; 0 0 1 1; 0 0 0 0; 0 0 0 0]
  p = BioEnergeticFoodWebs.model_parameters(correct_network, Z=2.0)
  @test p[:Z] == 2.0

  # Test that there is an exception if the vertebrates is of the wrong size
  wrong_vert = vec([true true true false false true true true false false])
  @test_throws ErrorException model_parameters(correct_network, vertebrates=wrong_vert)

  # Test that there the vertebrates can be passed
  right_vert = vec([true false true false])
  p = model_parameters(correct_network, vertebrates=right_vert)
  @test right_vert == p[:vertebrates]

  # Test that there is an exception if the body masses is of the wrong size
  wrong_bs = rand(100)
  @test_throws ErrorException model_parameters(correct_network, bodymass=wrong_bs)

  # Test that there the bodymasses can be passed
  right_bs = rand(4)
  p = model_parameters(correct_network, bodymass=right_bs)
  @test right_bs == p[:bodymass]

  # Test that the metabolic rates are calculated from bodymass
  p = model_parameters(correct_network)
  p_b = model_parameters(correct_network, bodymass = p[:bodymass])
  @test p[:x] == p_b[:x]

  # Test that there is an exception if the wrong productivity is used
  wrong_pr = :global
  @test_throws ErrorException model_parameters(correct_network, productivity=wrong_pr)

  # Test that there the productivity can be passed
  right_pr = :system
  p = model_parameters(correct_network, productivity=right_pr)
  @test right_pr == p[:productivity]

  # Test that there is an exception if the wrong rewiring method is used
  wrong_rm = :Rewire
  @test_throws ErrorException model_parameters(correct_network, rewire_method=wrong_rm)

  # Test that the rewire method can be passed
  right_rm = :ADBM
  p = model_parameters(correct_network, rewire_method=right_rm)
  @test right_rm == p[:rewire_method]

  # Test the adbm_parameters function:
  # Test that the parameters can be passed
  p = model_parameters(correct_network, rewire_method=:none)
  test_e = 2.0
  test_a_adbm = 0.02
  test_ai = -0.5
  test_aj = -0.5
  test_b = 0.4
  test_h_adbm = 2.0
  test_hi = 2.0
  test_hj = 2.0
  test_n = 2.0
  test_ni= -0.8
  test_Hmethod = :power
  test_Nmethod = :biomass
  BioEnergeticFoodWebs.adbm_parameters(p, test_e, test_a_adbm, test_ai, test_aj, test_b, test_h_adbm, test_hi, test_hj, test_n, test_ni, test_Hmethod, test_Nmethod)
  @test test_e == p[:e]
  @test test_a_adbm == p[:a_adbm]
  @test test_ai == p[:ai]
  @test test_aj == p[:aj]
  @test test_b == p[:b]
  @test test_h_adbm == p[:h_adbm]
  @test test_hi == p[:hi]
  @test test_hj == p[:hj]
  @test test_n == p[:n]
  @test test_ni == p[:ni]
  @test test_Hmethod == p[:Hmethod]
  @test test_Nmethod == p[:Nmethod]

  # Test that there is an exception if the wrong Nmethod is passed
  wrong_Nmethod = :logbiomass
  @test_throws ErrorException model_parameters(correct_network, rewire_method=:ADBM, Nmethod=wrong_Nmethod)

  # Test that there is an exception if the wrong Hmethod is passed
  wrong_Hmethod = :sum
  @test_throws ErrorException model_parameters(correct_network, rewire_method=:ADBM, Hmethod=wrong_Hmethod)

  # Test that a cost matrix (each cost = 1.0) of size (S, S) is added to p
  S = size(correct_network, 1)
  right_cm = ones(S,S)
  @test right_cm == p[:costMat]

  # Tests for the gilljam_parameters function:
    # Tests for the internal preference_parameters function:

      # parameters can be passed
  test_cost = .2
  test_preferenceMethod = :specialist
  test_specialistPrefMag = .8
  pref_par = BioEnergeticFoodWebs.preference_parameters(test_cost, test_specialistPrefMag, correct_network, test_preferenceMethod)
  @test pref_par[:cost] == test_cost
  @test pref_par[:preferenceMethod] == test_preferenceMethod
  @test pref_par[:specialistPrefMag] == test_specialistPrefMag

      # empty extinction vector to store extinct species during simulations
  right_extinctions = Int64[]
  @test pref_par[:extinctions] == right_extinctions

      # jaccard similarity matrix
  network_1 = correct_network #all species have different resources
  pref_par_1 = BioEnergeticFoodWebs.preference_parameters(test_cost, test_specialistPrefMag, network_1, test_preferenceMethod)
  n1_simIndex = [[1,2,3,4],[1,2,3,4],[1,2,3,4],[1,2,3,4]]
  @test n1_simIndex == pref_par_1[:similarity]

  network_2 = [0 0 1 1; 0 0 1 1; 0 0 0 0; 0 0 0 0] #species 1 and 2 have the same diet
  pref_par_2 = BioEnergeticFoodWebs.preference_parameters(test_cost, test_specialistPrefMag, network_2, test_preferenceMethod)
  n2_simIndex = [[1,3,4,2],[2,3,4,1],[1,2,3,4],[1,2,3,4]]
  @test n2_simIndex == pref_par_2[:similarity]

      # cost matrix (each cost = 1.0) of size (S, S) is added to p
  S = size(correct_network, 1)
  right_cm = ones(S,S)
  @test right_cm == pref_par[:costMat]

    # Test the internal get_specialist_preferences function:

      # Test that the preferences returned are empty if test_preferenceMethod = :generalist
  pm = :generalist
  pr = BioEnergeticFoodWebs.preference_parameters(test_cost, test_specialistPrefMag, correct_network, pm)
  right_pref = zeros(Int64, S)
  pref = BioEnergeticFoodWebs.get_specialist_preferences(pr, correct_network)
  @test right_pref == pref

      # Test that the preferences returned are correct when test_preferenceMethod = :specialist
  pm = :specialist
  pr = BioEnergeticFoodWebs.preference_parameters(test_cost, test_specialistPrefMag, correct_network, pm)
  pref = BioEnergeticFoodWebs.get_specialist_preferences(pr, correct_network)
  right_pref_1 = [2,4,0,0]
  right_pref_2 = [2,3,0,0]
  @test (pref == right_pref_1) | (pref == right_pref_2)

    # Test the gilljam_parameters function:

      # exception if the wrong preferenceMethod is passed
  wrong_pm = :gen
  @test_throws ErrorException model_parameters(correct_network, rewire_method=:Gilljam, preferenceMethod=wrong_pm)
  p = model_parameters(correct_network, rewire_method = :Gilljam, preferenceMethod = :specialist)
  @test p[:similarity] == n1_simIndex
  @test p[:specialistPrefMag] == .9
  @test p[:extinctions] == Int[]
  @test p[:preferenceMethod] == :specialist
  @test p[:cost] == .0
  @test p[:costMat] == right_cm
  @test (p[:specialistPref] == right_pref_1) | (p[:specialistPref] == right_pref_2)

  # Test that an empty vector p[:extinctions] is returned when using Staniczenko's rewiring method
  extinctions = Int[]
  p = model_parameters(correct_network, rewire_method = :stan)
  @test extinctions == p[:extinctions]

end

module TestUpdateParameters
  using BioEnergeticFoodWebs
  using Base.Test

  A = [0 0 1 ; 0 0 0 ; 0 0 0] #species 1 (herbivore) feed on 3 (producer)
  b = [0.2, 0.3, 0.0] #extinction of species 3

  # Test with ADBM rewiring method
  RWmethod = :ADBM
  p = model_parameters(A, rewire_method = RWmethod)
  old_p = copy(p)
  BioEnergeticFoodWebs.update_rewiring_parameters(p, b)

  #check that all links from and to 3 are gone
  @test p[:A] == Int.(zeros(A))
  #check that the parameters have been updated
  #species 1 was an herbivore ...
  @test BioEnergeticFoodWebs.get_herbivores(old_p) == [true, false, false]
  #...but not anymore
  @test BioEnergeticFoodWebs.get_herbivores(p) == [false, false, false]
  # it is still a consumer though
  @test p[:is_producer] == old_p[:is_producer] == [false, true, true]
  #preferences have been updated
  @test BioEnergeticFoodWebs.getW_preference(old_p) == float.([0 0 1 ; 0 0 0 ; 0 0 0])
  @test BioEnergeticFoodWebs.getW_preference(p) == zeros(A)
  #efficiency have been updated
  @test BioEnergeticFoodWebs.get_efficiency(old_p) == float.([0 0 old_p[:e_herbivore] ; 0 0 0 ; 0 0 0])
  @test BioEnergeticFoodWebs.get_efficiency(p) == zeros(A)

  # Test with Gilljam rewiring method
  A = [0 0 1 0 ; 0 0 1 1 ; 0 0 0 0 ; 0 0 0 0]
  b = [0.2, 0.3, 0.0, 0.5] #extinction of species 3
  RWmethod = :Gilljam
  p = model_parameters(A, rewire_method = RWmethod)
  old_p = copy(p)
  BioEnergeticFoodWebs.update_rewiring_parameters(p, b)

  #check that all links from and to 3 are gone
  @test p[:A][:,3] ==  p[:A][3,:] == zeros(4)
  @test p[:extinctions] == [3]
  @test BioEnergeticFoodWebs.get_herbivores(p) == [true, true, false, false]
  @test p[:is_producer] == old_p[:is_producer] == [false, false, true, true]
  eff = float.(zeros(p[:A]))
  eff[find(p[:A] .> 0)] = p[:e_herbivore]
  @test BioEnergeticFoodWebs.get_efficiency(p) == eff
  pref = float.(p[:A])
  @test BioEnergeticFoodWebs.getW_preference(p) == pref

  #with specialists
  p_specialists = model_parameters(A, rewire_method = RWmethod, preferenceMethod = :specialist)
  p_specialists[:A] = p[:A]
  p_specialists[:extinctions] = p[:extinctions]
  BioEnergeticFoodWebs.update_specialist_preference(p_specialists)
  @test p_specialists[:specialistPref] == [4, 4, 0, 0]

  # Test with Staniczenko rewiring method
  A = [0 0 1 0 ; 0 0 1 1 ; 0 0 0 0 ; 0 0 0 0]
  b = [0.2, 0.3, 0.0, 0.5]
  RWmethod = :stan
  p = model_parameters(A, rewire_method = RWmethod)
  old_p = copy(p)
  BioEnergeticFoodWebs.update_rewiring_parameters(p, b)
  #no released prey => no new link
  @test p[:A][:,3] ==  p[:A][3,:] == zeros(4)
  # 1 is not an herbivore anymore (no resource)
  @test BioEnergeticFoodWebs.get_herbivores(p) == [false, true, false, false]
  pref = float.(p[:A])
  @test BioEnergeticFoodWebs.getW_preference(p) == pref
  eff = float.(zeros(p[:A]))
  eff[find(p[:A] .> 0)] = p[:e_herbivore]
  @test BioEnergeticFoodWebs.get_efficiency(p) == eff

end

# Nutrient Intake model - parameters

module TestUpdateParameters
  using BioEnergeticFoodWebs
  using Base.Test

  # Test that the parameters can be passed
  A = [0 1 1 ; 0 0 0 ; 0 0 0]
  k1 = [0, 0.1, 0.2]
  k2 = [0, 0.2, 0.1]
  turnover_rate = 0.3
  s = [3.0, 4.0]
  content = [0.8, 0.6]
  p = model_parameters(A, productivity = :nutrients, K1 = k1, K2 = k2, D = turnover_rate, supply = s, υ = content)
  @test p[:K1] == k1
  @test p[:K2] == k2
  @test p[:D] == turnover_rate
  @test p[:supply] == s
  @test p[:υ] == content

  # Test that the NP parameters are not returned when the function is called with productivity != :nutrient
  p = model_parameters(A, K1 = k1, K2 = k2, D = turnover_rate, supply = s, υ = content)
  @test_throws KeyError p[:K1]
  @test_throws KeyError p[:K2]
  @test_throws KeyError p[:D]
  @test_throws KeyError p[:supply]
  @test_throws KeyError p[:υ]

  # Test that there is an error when the vectors length is incorrect
  k1 = [0.1, 0.2]
  @test_throws ErrorException model_parameters(A, productivity = :nutrients, K1 = k1)
  k2 = [0.2, 0.1]
  @test_throws ErrorException model_parameters(A, productivity = :nutrients, K2 = k2)
  s = [3.0, 2.0, 4.0]
  @test_throws ErrorException model_parameters(A, productivity = :nutrients, supply = s)
  content = [1.0]
  @test_throws ErrorException model_parameters(A, productivity = :nutrients, υ = content)

  # Producer metabolic rates
  p = model_parameters(A, productivity = :nutrients)
  @test p[:x] == [0.314, 0.138, 0.138]

end
