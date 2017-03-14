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

  # Test that there the vertebrates can be passed
  right_bs = rand(4)
  p = model_parameters(correct_network, bodymass=right_bs)
  @test right_bs == p[:bodymass]

  # Test that there is an exception if the wrong productivity is used
  wrong_pr = :global
  @test_throws ErrorException model_parameters(correct_network, productivity=wrong_pr)

  # Test that there the productivity can be passed
  right_pr = :system
  p = model_parameters(correct_network, productivity=right_pr)
  @test right_pr == p[:productivity]

end
