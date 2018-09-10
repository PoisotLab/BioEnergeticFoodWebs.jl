module TestTemperature_dependence_functions
  using BioEnergeticFoodWebs
  using Base.Test

  correct_network = [0 1 0 0; 0 0 1 1; 0 0 0 0; 0 0 0 0]

  # Test default values when no effect of temperature
  parameters = model_parameters(correct_network, vertebrates = [true, false, true, false])

  @test parameters[:x] == [0.88, 0.314, 0.138, 0.138]
  @test parameters[:r] == 1.0
  @test parameters[:ht] == [1/4.0 , 1/8.0, Inf, Inf]
  @test parameters[:ar] == 1./(0.5 .* parameters[:ht])

  # Test default value when accounting for a temperature effect

  # parameters = model_parameters(correct_network, T = 295.15, metabolicrate = exponential_BA(@NT(norm_constant=0.2,activation_energy = 0.65, β = -0.25, T0 = 293.15)), handlingtime = gaussian(@NT(shape = :U, norm_constant = 0.5, range = 20, T_opt = 295, β = -0.25)) , attackrate = extended_BA(@NT(norm_constant = 3e8, activation_energy = 0.53, deactivation_energy = 1.15, T_opt = 298.15, β = -0.25)), growthrate = extended_eppley(@NT(maxrate_0=0.81, eppley_exponent=0.0631,T_opt=298.15, range = 35, β = -0.25)))
  #
  # @test round(parameters[:x]) == [0.88, 0.314, 0.138, 0.138]
  # @test parameters[:r] == 1.0
  # @test parameters[:ht] == [1/4.0 , 1/8.0, Inf, Inf]
  # @test parameters[:ar] == 1./(0.5 .* parameters[:ht])
  # 


end
