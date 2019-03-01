module TestMakeParameters
  using BioEnergeticFoodWebs
  using Test

  # Test the keyword interface
  correct_network = [0 1 0 0; 0 0 1 1; 0 0 0 0; 0 0 0 0]
  parameters = model_parameters(correct_network, Z=2.0)
  @test parameters[:Z] == 2.0

  # Test that producers, etc, are identified
  @test parameters[:is_producer][4] == true
  @test parameters[:is_producer][3] == true
  @test parameters[:is_producer][2] == false
  @test parameters[:is_producer][1] == false

  @test parameters[:is_herbivore][4] == false
  @test parameters[:is_herbivore][3] == false
  @test parameters[:is_herbivore][2] == true
  @test parameters[:is_herbivore][1] == false

  # Test the direct interface
  correct_network = [0 1 0 0; 0 0 1 1; 0 0 0 0; 0 0 0 0]
  parameters = BioEnergeticFoodWebs.model_parameters(correct_network, Z=2.0)
  @test parameters[:Z] == 2.0

  # Test that there is an exception if the vertebrates is of the wrong size
  wrong_vert = vec([true true true false false true true true false false])
  @test_throws ErrorException model_parameters(correct_network, vertebrates=wrong_vert)

  # Test that there the vertebrates can be passed
  right_vert = vec([true false true false])
  parameters = model_parameters(correct_network, vertebrates=right_vert)
  @test right_vert == parameters[:vertebrates]

  # Test that there is an exception if the body masses is of the wrong size
  wrong_bs = rand(100)
  @test_throws ErrorException model_parameters(correct_network, bodymass=wrong_bs)

  # Test that there the bodymasses can be passed
  right_bs = rand(4)
  parameters = model_parameters(correct_network, bodymass=right_bs)
  @test right_bs == parameters[:bodymass]

  # Test that the metabolic rates are calculated from bodymass
  p = model_parameters(correct_network)
  p_b = model_parameters(correct_network, bodymass = p[:bodymass])
  @test p[:x] == p_b[:x]

  # Test that there is an exception if the wrong productivity is used
  wrong_pr = :global
  @test_throws ErrorException model_parameters(correct_network, productivity=wrong_pr)

  # Test that there the productivity can be passed
  right_pr = :system
  parameters = model_parameters(correct_network, productivity=right_pr)
  @test right_pr == parameters[:productivity]

  # Test that there is an exception if the wrong rewiring method is used
  wrong_rm = :Rewire
  @test_throws ErrorException model_parameters(correct_network, rewire_method=wrong_rm)

  # Test that the rewire method can be passed
  right_rm = :ADBM
  parameters = model_parameters(correct_network, rewire_method=right_rm)
  @test right_rm == parameters[:rewire_method]

  # Test the adbm_parameters function:
  # Test that the parameters can be passed
  parameters = model_parameters(correct_network, rewire_method=:none)
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
  BioEnergeticFoodWebs.adbm_parameters(parameters, test_e, test_a_adbm, test_ai, test_aj, test_b, test_h_adbm, test_hi, test_hj, test_n, test_ni, test_Hmethod, test_Nmethod)
  @test test_e == parameters[:e]
  @test test_a_adbm == parameters[:a_adbm]
  @test test_ai == parameters[:ai]
  @test test_aj == parameters[:aj]
  @test test_b == parameters[:b]
  @test test_h_adbm == parameters[:h_adbm]
  @test test_hi == parameters[:hi]
  @test test_hj == parameters[:hj]
  @test test_n == parameters[:n]
  @test test_ni == parameters[:ni]
  @test test_Hmethod == parameters[:Hmethod]
  @test test_Nmethod == parameters[:Nmethod]

  # Test that there is an exception if the wrong Nmethod is passed
  wrong_Nmethod = :logbiomass
  @test_throws ErrorException model_parameters(correct_network, rewire_method=:ADBM, Nmethod=wrong_Nmethod)

  # Test that there is an exception if the wrong Hmethod is passed
  wrong_Hmethod = :sum
  @test_throws ErrorException model_parameters(correct_network, rewire_method=:ADBM, Hmethod=wrong_Hmethod)

  # Test that a cost matrix (each cost = 1.0) of size (S, S) is added to p
  S = size(correct_network, 1)
  right_cm = ones(S,S)
  @test right_cm == parameters[:costMat]

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
  parameters = model_parameters(correct_network, rewire_method = :Gilljam, preferenceMethod = :specialist)
  @test parameters[:similarity] == n1_simIndex
  @test parameters[:specialistPrefMag] == .9
  @test parameters[:extinctions] == Int[]
  @test parameters[:preferenceMethod] == :specialist
  @test parameters[:cost] == .0
  @test parameters[:costMat] == right_cm
  @test (parameters[:specialistPref] == right_pref_1) | (parameters[:specialistPref] == right_pref_2)

  # Test that an empty vector parameters[:extinctions] is returned when using Staniczenko's rewiring method
  extinctions = Int[]
  p = model_parameters(correct_network, rewire_method = :stan)
  @test extinctions == parameters[:extinctions]

end

module TestUpdateParameters
  using BioEnergeticFoodWebs
  using Test

  A = [0 0 1 ; 0 0 0 ; 0 0 0] #species 1 (herbivore) feed on 3 (producer)
  b = [0.2, 0.3, 0.0] #extinction of species 3

  # Test with ADBM rewiring method
  RWmethod = :ADBM
  parameters = model_parameters(A, rewire_method = RWmethod)
  old_p = copy(parameters)
  BioEnergeticFoodWebs.update_rewiring_parameters(parameters, b)

  #check that all links from and to 3 are gone
  @test parameters[:A] == Int.(zero(A))
  #check that the parameters have been updated
  #species 1 was an herbivore ...
  @test BioEnergeticFoodWebs.get_herbivores(old_p) == [true, false, false]
  #...but not anymore
  @test BioEnergeticFoodWebs.get_herbivores(parameters) == [false, false, false]
  # it is still a consumer though
  @test parameters[:is_producer] == old_p[:is_producer] == [false, true, true]
  #preferences have been updated
  @test BioEnergeticFoodWebs.getW_preference(old_p) == float.([0 0 1 ; 0 0 0 ; 0 0 0])
  @test BioEnergeticFoodWebs.getW_preference(parameters) == zero(A)
  #efficiency have been updated
  @test BioEnergeticFoodWebs.get_efficiency(old_p) == float.([0 0 old_p[:e_herbivore] ; 0 0 0 ; 0 0 0])
  @test BioEnergeticFoodWebs.get_efficiency(parameters) == zero(A)

  # Test with Gilljam rewiring method
  A = [0 0 1 0 ; 0 0 1 1 ; 0 0 0 0 ; 0 0 0 0]
  b = [0.2, 0.3, 0.0, 0.5] #extinction of species 3
  RWmethod = :Gilljam
  parameters = model_parameters(A, rewire_method = RWmethod)
  old_p = copy(parameters)
  BioEnergeticFoodWebs.update_rewiring_parameters(parameters, b)

  #check that all links from and to 3 are gone
  @test parameters[:A][:,3] ==  parameters[:A][3,:] == zeros(4)
  @test parameters[:extinctions] == [3]
  @test BioEnergeticFoodWebs.get_herbivores(parameters) == [true, true, false, false]
  @test parameters[:is_producer] == old_p[:is_producer] == [false, false, true, true]
  eff = float.(zero(parameters[:A]))
  eff[parameters[:A] .> 0] .= parameters[:e_herbivore]
  @test BioEnergeticFoodWebs.get_efficiency(parameters) == eff
  pref = float.(parameters[:A])
  @test BioEnergeticFoodWebs.getW_preference(parameters) == pref

  #with specialists
  p_specialists = model_parameters(A, rewire_method = RWmethod, preferenceMethod = :specialist)
  p_specialists[:A] = parameters[:A]
  p_specialists[:extinctions] = parameters[:extinctions]
  BioEnergeticFoodWebs.update_specialist_preference(p_specialists)
  @test p_specialists[:specialistPref] == [4, 4, 0, 0]

  # Test with Staniczenko rewiring method
  A = [0 0 1 0 ; 0 0 1 1 ; 0 0 0 0 ; 0 0 0 0]
  b = [0.2, 0.3, 0.0, 0.5]
  RWmethod = :stan
  parameters = model_parameters(A, rewire_method = RWmethod)
  old_p = copy(parameters)
  BioEnergeticFoodWebs.update_rewiring_parameters(parameters, b)
  #no released prey => no new link
  @test parameters[:A][:,3] ==  parameters[:A][3,:] == zeros(4)
  # 1 is not an herbivore anymore (no resource)
  @test BioEnergeticFoodWebs.get_herbivores(parameters) == [false, true, false, false]
  pref = float.(parameters[:A])
  @test BioEnergeticFoodWebs.getW_preference(parameters) == pref
  eff = float.(zero(parameters[:A]))
  eff[parameters[:A] .> 0] .= parameters[:e_herbivore]
  @test BioEnergeticFoodWebs.get_efficiency(parameters) == eff

end

# Nutrient Intake model - parameters

module TestNIParameters
  using BioEnergeticFoodWebs
  using Test

  # Test that the parameters can be passed
  A = [0 1 1 ; 0 0 0 ; 0 0 0]
  k1 = [0, 0.1, 0.2]
  k2 = [0, 0.2, 0.1]
  turnover_rate = 0.3
  s = [3.0, 4.0]
  content = [0.8, 0.6]
  parameters = model_parameters(A, productivity = :nutrients, K1 = k1, K2 = k2, D = turnover_rate, supply = s, υ = content)
  @test parameters[:K1] == k1
  @test parameters[:K2] == k2
  @test parameters[:D] == turnover_rate
  @test parameters[:supply] == s
  @test parameters[:υ] == content

  # Test that the NP parameters are not returned when the function is called with productivity != :nutrient
  parameters = model_parameters(A, K1 = k1, K2 = k2, D = turnover_rate, supply = s, υ = content)
  @test_throws KeyError parameters[:K1]
  @test_throws KeyError parameters[:K2]
  @test_throws KeyError parameters[:D]
  @test_throws KeyError parameters[:supply]
  @test_throws KeyError parameters[:υ]

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
  parameters = model_parameters(A, productivity = :nutrients)
  @test parameters[:x] == [0.3141, 0.138, 0.138]

end
