module TestMakeParameters
  using BioEnergeticFoodWebs
  using Base.Test

  correct_network = [0 1 0 0; 0 0 1 1; 0 0 0 0; 0 0 0 0]
  parameters = model_parameters(correct_network, vertebrates = [true, false, true, false])

  @test parameters[:x] == [0.88, 0.314, 0.138, 0.138]
  @test parameters[:r] == 1.0
  @test parameters[:ht] == [1/4.0 , 1/8.0, Inf, Inf]
  @test parameters[:ar] == 1./(0.5 .* parameters[:ht])

end
