module TestGilljamRewire
    using BioEnergeticFoodWebs
    using Test
    using Random

    Random.seed!(1)
    S = 3
    A = [0 0 0 ;
         1 0 0 ;
         1 1 1 ]
    biomass = [1.0,1.0,1.0]
    parameters = BioEnergeticFoodWebs.model_parameters(A, rewire_method = :DS)

#testing Gilljam no extinctions
    GilljamTest = BioEnergeticFoodWebs.Gilljam(S,parameters,biomass)
    @test GilljamTest[1] == A
    @test GilljamTest[2] == parameters
#Testing with extinction
    parameters[:extinctions] = 1
    GilljamTest = BioEnergeticFoodWebs.Gilljam(S,parameters,biomass)
    @test (GilljamTest[1] == [0 0 0; 0 1 0; 0 1 1]) | (GilljamTest[1] == ([0 0 0; 0 0 1; 0 1 1]))
    p1 = deepcopy(parameters)
    p2 = deepcopy(parameters)
    p1[:costMat][2,2] = 0.0
    p2[:costMat][2,3] = 0.0
    @test (GilljamTest[2] == p1) | (GilljamTest[2] == p2)
end
