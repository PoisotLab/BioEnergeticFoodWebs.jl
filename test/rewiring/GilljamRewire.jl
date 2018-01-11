module TestGilljamRewire
    using BioEnergeticFoodWebs
    using Base.Test

    srand(1)
    S = 3
    A = [0 0 0 ;
         1 0 0 ;
         1 1 1 ]
    biomass = [1.0,1.0,1.0]
    p = model_parameters(A, rewire_method = :Gilljam)

#testing Gilljam no extinctions
    GilljamTest = BioEnergeticFoodWebs.Gilljam(S,p,biomass)
    @test GilljamTest[1] == A
    @test GilljamTest[2] == p
#Testing with extinction
    p[:extinctions] = 1
    GilljamTest = BioEnergeticFoodWebs.Gilljam(S,p,biomass)
    @test GilljamTest[1] == [0 0 0; 0 1 0; 0 1 1]
    p[:costMat][2,2] = 0.0
    @test GilljamTest[2] == p
end
