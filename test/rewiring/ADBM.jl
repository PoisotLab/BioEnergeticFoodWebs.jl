module TestADBM
    using BioEnergeticFoodWebs
    using Base.Test

    #testing getADBM_Terms
    S = 3
    A = [0 0 0 ;
         1 1 0 ;
         0 1 1 ]
    biomass = [0.0,1.0,1.0]
    p = model_parameters(A, rewire_method = :ADBM , Z = 10.0) #change Z to change bodymass
    ADBMterms = BioEnergeticFoodWebs.getADBM_Terms(S,p,biomass)

    #test keys
    @test collect(keys(ADBMterms)) == [:H,:λ,:E]

    #test values
    H = [Inf Inf Inf; 2.70726 Inf Inf; 2.51359 3.32226 Inf]
    @test all(isapprox.(ADBMterms[:H],H,atol = 0.001))
    λ = [0.0189 0.000259993 1.49266e-5; 0.00379282 5.21749e-5 2.99545e-6; 0.00130006 1.78839e-5 1.02674e-6]
    @test all(isapprox.(ADBMterms[:λ],λ,atol = 0.001))
    E = [1.0, 31.6228, 316.228]
    @test all(isapprox.(ADBMterms[:E],E,atol = 0.001))


    #Testing ADBM
    S = 5
    A = [0 0 0 0 0; 0 1 0 0 0; 0 0 0 0 0; 0 1 1 0 0; 0 1 1 1 1]
    biomass = [1.0,1.0,1.0,0.0,1.0]

    #ratio method
    p = model_parameters(A, rewire_method = :ADBM, Hmethod = :ratio, Z = 10.0)
    ADBMTest = BioEnergeticFoodWebs.ADBM(S,p,biomass)
    @test ADBMTest == [0 0 0 0 0; 0 0 0 0 0; 0 0 0 0 0; 1 1 1 0 0; 1 1 1 1 0]

    #power method
    p = model_parameters(A, rewire_method = :ADBM, Hmethod = :power, Z = 10.0)
    ADBMTest = BioEnergeticFoodWebs.ADBM(S,p,biomass)
    @test ADBMTest == [0 0 0 0 0; 1 1 1 1 1; 0 0 0 0 0; 1 1 1 1 1; 1 1 1 1 1]

    #biomass Based
    p = model_parameters(A, rewire_method = :ADBM, Nmethod = :biomass, Z = 10.0)
    ADBMTest = BioEnergeticFoodWebs.ADBM(S,p,biomass)
    @test ADBMTest == [0 0 0 0 0; 0 0 0 0 0; 0 0 0 0 0; 1 1 1 0 0; 1 1 1 1 0]

end
