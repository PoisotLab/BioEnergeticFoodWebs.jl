module TestDefault
  using Base.Test
  using BioEnergeticFoodWebs

  food_chain = [0 0 0 ; 0 0 1; 1 0 0]
  metab_status = [false, true, false]
  p = model_parameters(food_chain, vertebrates = metab_status)

  # growth rates
  @test p[:r] == [1, 1, 1]
  # metabolic rates
  a_invertebrate = 0.3141
  a_vertebrate = 0.88
  a_producer = 0.138
  @test p[:x] == [a_producer, a_vertebrate, a_invertebrate]
  # maximum consumption rate
  y_vertebrate = 4.0
  y_invertebrate = 8.0
  y_producer = 0.0
  @test p[:y] == [y_producer, y_vertebrate, y_invertebrate]
  # handling time
  @test p[:ht] == 1 ./ p[:y]
  # # attack rate
  # ar =
  # # half saturation constant
  # hsc = a ./ (ar .* ht)
end
