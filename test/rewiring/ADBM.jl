module TestADBM_ratio
    using BioEnergeticFoodWebs
    using Test

    #testing get_adbm_terms
    S = 3
    A = [0 0 0 ;
         1 1 0 ;
         0 1 1 ]
    biomass = [0.0,1.0,1.0]

    #original
    p = model_parameters(A, rewire_method = :ADBM , Z = 10.0, Nmethod = :original) #change Z to change bodymass
    ADBMterms = BioEnergeticFoodWebs.get_adbm_terms(S,p,biomass)
    #test keys
    @test collect(keys(ADBMterms)) == [:H,:λ,:E]
    #test values
    H = [Inf Inf Inf; 2.70726 Inf Inf; 2.51359 3.32226 Inf]
    @test all(isapprox.(ADBMterms[:H],H,atol = 0.001))
    λ = [0.0189 0.000259993 1.49266e-5; 0.00379282 5.21749e-5 2.99545e-6; 0.00130006 1.78839e-5 1.02674e-6]
    @test all(isapprox.(ADBMterms[:λ],λ,atol = 0.001))
    E = [1.0, 31.6228, 316.228]

    @test all(isapprox.(ADBMterms[:E],E,atol = 0.001))
    #biomass
    p_bm = model_parameters(A, rewire_method = :ADBM , Z = 10.0, Nmethod = :biomass) #change Z to change bodymass
    ADBMterms_bm = BioEnergeticFoodWebs.get_adbm_terms(S,p_bm,biomass)
    #test keys
    @test collect(keys(ADBMterms_bm)) == [:H,:λ,:E]
    H_bm = [Inf Inf Inf; 2.70726 Inf Inf; 2.51359 3.32226 Inf]
    @test all(isapprox.(ADBMterms_bm[:H],H_bm,atol = 0.001))
    λ_bm = [0.0 0.0035 0.0011 ; 0.0 0.001 0.0002 ; 0.0 0.0002 7e-5]
    @test all(isapprox.(ADBMterms_bm[:λ],λ_bm,atol = 0.001))
    E_bm = [1.0, 31.6228, 316.228]
    @test all(isapprox.(ADBMterms_bm[:E],E_bm,atol = 0.001))

end

module TestADBM_power
    using BioEnergeticFoodWebs
    using Test

    #testing get_adbm_terms
    S = 3
    A = [0 0 0 ;
         1 1 0 ;
         0 1 1 ]
    biomass = [0.0,1.0,1.0]

    #original
    p = model_parameters(A, rewire_method = :ADBM , Z = 10.0, Nmethod = :original, Hmethod = :power) #change Z to change bodymass
    ADBMterms = BioEnergeticFoodWebs.get_adbm_terms(S,p,biomass)
    #test keys
    @test collect(keys(ADBMterms)) == [:H,:λ,:E]
    #test values
    H = [1.0 31.6228 316.228 ; 31.6228 1000.0 10000.0 ; 316.228 10000.0 100000.0]
    @test all(isapprox.(ADBMterms[:H],H,atol = 0.001))
    λ = [0.0189 0.000259993 1.49266e-5; 0.00379282 5.21749e-5 2.99545e-6; 0.00130006 1.78839e-5 1.02674e-6]
    @test all(isapprox.(ADBMterms[:λ],λ,atol = 0.001))
    E = [1.0, 31.6228, 316.228]
    @test all(isapprox.(ADBMterms[:E],E,atol = 0.001))

    #biomass
    p_bm = model_parameters(A, rewire_method = :ADBM , Z = 10.0, Nmethod = :biomass, Hmethod = :power) #change Z to change bodymass
    ADBMterms_bm = BioEnergeticFoodWebs.get_adbm_terms(S,p_bm,biomass)
    #test keys
    @test collect(keys(ADBMterms_bm)) == [:H,:λ,:E]
    H_bm = [1.0 31.6228 316.228 ; 31.6228 1000.0 10000.0 ; 316.228 10000.0 100000.0]
    @test all(isapprox.(ADBMterms_bm[:H],H_bm,atol = 0.001))
    λ_bm = [0.0 0.0035 0.0011 ; 0.0 0.001 0.0002 ; 0.0 0.0002 7e-5]
    @test all(isapprox.(ADBMterms_bm[:λ],λ_bm,atol = 0.001))
    E_bm = [1.0, 31.6228, 316.228]
    @test all(isapprox.(ADBMterms_bm[:E],E_bm,atol = 0.001))

end

module TestADBM_power
    using BioEnergeticFoodWebs
    using Test

    #Testing ADBM
    S = 5
    A = [0 0 0 0 0; 0 1 0 0 0; 0 0 0 0 0; 0 1 1 0 0; 0 1 1 1 1]
    biomass = [1.0,1.0,1.0,0.0,1.0]

    #ratio method
    p = model_parameters(A, rewire_method = :ADBM, Hmethod = :ratio, Z = 10.0)
    ADBMTest = BioEnergeticFoodWebs.ADBM(S,p,biomass)
    @test ADBMTest == [0 0 0 0 0; 0 0 0 0 0; 0 0 0 0 0; 0 0 0 0 0; 1 1 1 0 0]

    #power method
    p = model_parameters(A, rewire_method = :ADBM, Hmethod = :power, Z = 10.0)
    ADBMTest = BioEnergeticFoodWebs.ADBM(S,p,biomass)
    @test ADBMTest == [0 0 0 0 0; 1 1 1 1 1; 0 0 0 0 0; 0 0 0 0 0; 1 1 1 1 1]

    #biomass Based
    p = model_parameters(A, rewire_method = :ADBM, Nmethod = :biomass, Z = 10.0)
    ADBMTest = BioEnergeticFoodWebs.ADBM(S,p,biomass)
    @test ADBMTest == [0 0 0 0 0; 0 0 0 0 0; 0 0 0 0 0; 0 0 0 0 0; 1 1 1 0 0]

end
