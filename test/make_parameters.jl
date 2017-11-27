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
  p   = model_parameters(correct_network)
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

  # Test the ADBM_par function:
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
  BioEnergeticFoodWebs.adbm_par(p, test_e, test_a_adbm, test_ai, test_aj, test_b, test_h_adbm, test_hi, test_hj, test_n, test_ni, test_Hmethod, test_Nmethod)
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

  # Tests for the gilljam_par function:
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

    # Test the internal getSpeciaistPref function:

      # Test that the preferences returned are empty if test_preferenceMethod = :generalist
  pm = :generalist
  pr = BioEnergeticFoodWebs.preference_parameters(test_cost, test_specialistPrefMag, correct_network, pm)
  right_pref = zeros(Int64, S)
  pref = BioEnergeticFoodWebs.getSpeciaistPref(pr, correct_network)
  @test right_pref == pref

      # Test that the preferences returned are correct when test_preferenceMethod = :specialist
  pm = :specialist
  pr = BioEnergeticFoodWebs.preference_parameters(test_cost, test_specialistPrefMag, correct_network, pm)
  pref = BioEnergeticFoodWebs.getSpeciaistPref(pr, correct_network)
  right_pref_1 = [2,4,0,0]
  right_pref_2 = [2,3,0,0]
  @test (pref == right_pref_1) | (pref == right_pref_2)

    # Test the gilljam_par function:

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
