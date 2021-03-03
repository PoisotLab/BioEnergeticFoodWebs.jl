module TestADBM_Nmethod
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

    #density
    p_dn = model_parameters(A, rewire_method = :ADBM , Z = 10.0, Nmethod = :density) #change Z to change bodymass
    N = biomass ./ p_dn[:bodymass]
    ADBMterms_dn = BioEnergeticFoodWebs.get_adbm_terms(S,p_dn,biomass)
    #test keys
    @test collect(keys(ADBMterms_dn)) == [:H,:λ,:E]
    H_dn = [Inf Inf Inf; 2.70726 Inf Inf; 2.51359 3.32226 Inf]
    @test all(isapprox.(ADBMterms_dn[:H],H_dn,atol = 0.001))
    λ_dn = (p_dn[:a_adbm] * (p_dn[:bodymass].^p_dn[:aj]) * (p_dn[:bodymass].^p_dn[:ai])') .* N'
    @test all(isapprox.(ADBMterms_dn[:λ],λ_dn,atol = 0.001))
    E_dn = [1.0, 31.6228, 316.228]
    @test all(isapprox.(ADBMterms_dn[:E],E_dn,atol = 0.001))

    #biomass
    p_bm = model_parameters(A, rewire_method = :ADBM , Z = 10.0, Nmethod = :biomass) #change Z to change bodymass
    N = biomass
    ADBMterms_bm = BioEnergeticFoodWebs.get_adbm_terms(S,p_bm,biomass)
    #test keys
    @test collect(keys(ADBMterms_bm)) == [:H,:λ,:E]
    H_bm = [Inf Inf Inf; 2.70726 Inf Inf; 2.51359 3.32226 Inf]
    @test all(isapprox.(ADBMterms_bm[:H],H_bm,atol = 0.001))
    A_bm = (p_bm[:a_adbm] * (p_bm[:bodymass].^p_bm[:aj]) * (p_bm[:bodymass].^p_bm[:ai])') ./ (p_bm[:bodymass]') 
    λ_bm = A_bm .* N'
    @test all(isapprox.(ADBMterms_bm[:λ],λ_bm,atol = 0.001))
    E_bm = [1.0, 31.6228, 316.228]
    @test all(isapprox.(ADBMterms_bm[:E],E_bm,atol = 0.001))
end

module TestADBM_equivalence
    using BioEnergeticFoodWebs
    using Test

    # Test: some methods should give the same adbm terms

    #Growth rate (producers)
    function ScaleGrowth(M, T)
        r0 = exp(-15.68)
        βr = -0.25
        Er = -0.84
        T0 = 293.15 #20 celsius
        k = 8.617e-5
        return r0 .* (M .^ βr) .* exp(Er .* ((T0 .- T) ./ (k .* T .* T0)))
    end

    #Metabolic rate
    function ScaleMetabolism(M, T)
        x0 = exp(-16.54)
        sx = -0.31
        Ex = -0.69
        T0 = 293.15
        k = 8.617e-5
        return x0 .* (M .^ sx) .* exp(Ex .* ((T0 .- T) ./ (k .* T .* T0)))
    end

    #Handling time
    function ScaleHandling(m, T)
        h0 = exp(9.66)
        βres = -0.45
        βcons = 0.47
        Eh = 0.26
        T0 = 293.15
        k = 8.617E-5
        boltz = exp(Eh * ((T0-T)/(k*T*T0)))
        hij = zeros(length(m), length(m))
        for i in eachindex(m) #i = rows => consumers
          for j in eachindex(m) #j = cols => resources
            mcons = m[i] ^ βcons #mass scaled for cons
            mres = m[j] ^ βres #mass scaled for res
            hij[i,j] = h0 * mres * mcons * boltz
          end
        end
        return hij
    end

    #Attack rate
    function ScaleAttack(m, T)
        a0 = exp(-13.1)
        βres = 0.25 #resource
        βcons = -0.8 #consumer
        Ea = -0.38
        T0 = 293.15
        k = 8.617E-5
        boltz = exp(Ea * ((T0-T)/(k*T*T0)))
        aij = zeros(length(m), length(m))
        for i in eachindex(m) #i = rows => consumers
          for j in eachindex(m) #j = cols => resources
            mcons = m[i] ^ βcons #mass scaled for cons
            mres = m[j] ^ βres #mass scaled for res
            aij[i,j] = a0 * mres * mcons * boltz
          end
        end
        return aij
    end    

    #Carrying capacity
    function carrying(m, k0, T)
        βk = 0.28
        Ek = 0.71 
        return k0 .* (m .^ βk) .* exp.(Ek .* (293.15 .- T ) ./ (8.617e-5 .* T .* 293.15))
    end

    Atest = [0 0 1 0 ; 0 0 1 1 ; 0 0 0 0 ; 0 0 0 0]
    Mtest = [10.0, 5.0, 2.0, 1.0]
    Stest = size(Atest, 1)
    Ntest = Mtest .^ -0.75
    Btest = Ntest .* Mtest
            
    pa = BioEnergeticFoodWebs.model_parameters(Atest, bodymass = Mtest, rewire_method = :ADBM, consrate_adbm = :adbm, Nmethod = :allometric)
    ta = BioEnergeticFoodWebs.get_adbm_terms(Stest, pa, Btest)
    Ha, La, Ea = ta[:H], ta[:λ], ta[:E]
    
    pn = BioEnergeticFoodWebs.model_parameters(Atest, bodymass = Mtest, rewire_method = :ADBM, consrate_adbm = :adbm, Nmethod = :density)
    tn = BioEnergeticFoodWebs.get_adbm_terms(Stest, pn, Btest)
    Hn, Ln, En = tn[:H], tn[:λ], tn[:E]
    
    pb = BioEnergeticFoodWebs.model_parameters(Atest, bodymass = Mtest, rewire_method = :ADBM, consrate_adbm = :adbm, Nmethod = :biomass)
    tb = BioEnergeticFoodWebs.get_adbm_terms(Stest, pb, Btest)
    Hb, Lb, Eb = tb[:H], tb[:λ], tb[:E]
    
    @test Hn == Ha == Hb
    @test Ln == La == Lb
    @test En == Ea == Eb
    
    isP_test = pn[:is_producer]
    t1 = 273.15+20
    K_test = carrying(Mtest, 10.0, t1) #carrying capacity at T for M
    K_test[.!vec(isP_test)] .= 0.0
    #growth rate
    growth_test = ScaleGrowth(Mtest, t1)
    growth_test[.!vec(isP_test)] .= 0.0
    #metabolic rate
    metabolism_test = ScaleMetabolism(Mtest, t1)
    metabolism_test[vec(isP_test)] .= 0.0
    #feeding rates
    h_test = ScaleHandling(Mtest, t1)
    a_test = ScaleAttack(Mtest, t1)
    
    paB = BioEnergeticFoodWebs.model_parameters(Atest, bodymass = Mtest, rewire_method = :ADBM, consrate_adbm = :befwm, Nmethod = :allometric)
    paB[:ar] = a_test
    paB[:K] = K_test
    paB[:ht] = h_test
    paB[:r] = growth_test
    paB[:x] = metabolism_test
    taB = BioEnergeticFoodWebs.get_adbm_terms(Stest, paB, Btest)
    HaB, LaB, EaB = taB[:H], taB[:λ], taB[:E]
    
    pnB = BioEnergeticFoodWebs.model_parameters(Atest, bodymass = Mtest, rewire_method = :ADBM, consrate_adbm = :befwm, Nmethod = :density)
    pnB[:ar] = a_test
    pnB[:K] = K_test
    pnB[:ht] = h_test
    pnB[:r] = growth_test
    pnB[:x] = metabolism_test
    tnB = BioEnergeticFoodWebs.get_adbm_terms(Stest, pnB, Btest)
    HnB, LnB, EnB = tnB[:H], tnB[:λ], tnB[:E]
    
    pbB = BioEnergeticFoodWebs.model_parameters(Atest, bodymass = Mtest, rewire_method = :ADBM, consrate_adbm = :befwm, Nmethod = :biomass)
    pbB[:ar] = a_test
    pbB[:K] = K_test
    pbB[:ht] = h_test
    pbB[:r] = growth_test
    pbB[:x] = metabolism_test
    tbB = BioEnergeticFoodWebs.get_adbm_terms(Stest, pbB, Btest)
    HbB, LbB, EbB = tbB[:H], tbB[:λ], tbB[:E]
    
    @test HnB == HaB == HbB
    @test LnB == LaB
    @test LnB ≈ LbB atol = 1e-10
    @test EnB == EaB == EbB    
end

module TestADBM_Hmethod
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

    #density 
    p_dn = model_parameters(A, rewire_method = :ADBM , Z = 10.0, Nmethod = :density, Hmethod = :power) #change Z to change bodymass
    N = biomass ./ p_dn[:bodymass]
    ADBMterms_dn = BioEnergeticFoodWebs.get_adbm_terms(S,p_dn,biomass)
    #test keys
    @test collect(keys(ADBMterms_dn)) == [:H,:λ,:E]
    H_dn = [1.0 31.6228 316.228 ; 31.6228 1000.0 10000.0 ; 316.228 10000.0 100000.0]
    @test all(isapprox.(ADBMterms_dn[:H],H_dn,atol = 0.001))
    λ_dn = (p_dn[:a_adbm] * (p_dn[:bodymass].^p_dn[:aj]) * (p_dn[:bodymass].^p_dn[:ai])') .* N'
    @test all(isapprox.(ADBMterms_dn[:λ],λ_dn,atol = 0.001))
    E_dn = [1.0, 31.6228, 316.228]
    @test all(isapprox.(ADBMterms_dn[:E],E_dn,atol = 0.001))
    
    #biomass
    p_bm = model_parameters(A, rewire_method = :ADBM , Z = 10.0, Nmethod = :biomass, Hmethod = :power) #change Z to change bodymass
    N = biomass
    ADBMterms_bm = BioEnergeticFoodWebs.get_adbm_terms(S,p_bm,biomass)
    #test keys
    @test collect(keys(ADBMterms_bm)) == [:H,:λ,:E]
    H_bm = p_bm[:h_adbm] * (p_bm[:bodymass].^p_bm[:hj]) * (p_bm[:bodymass].^p_bm[:hi])' # h * pred * prey
    @test all(isapprox.(ADBMterms_bm[:H],H_bm,atol = 0.001))
    A_bm = (p_bm[:a_adbm] * (p_bm[:bodymass].^p_bm[:aj]) * (p_bm[:bodymass].^p_bm[:ai])') ./ (p_bm[:bodymass]') 
    λ_bm = A_bm .* N'
    @test all(isapprox.(ADBMterms_bm[:λ],λ_bm,atol = 0.001))
    E_bm = [1.0, 31.6228, 316.228]
    @test all(isapprox.(ADBMterms_bm[:E],E_bm,atol = 0.001))
    
end

module TestADBM_power_ratio
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
    #p = model_parameters(A, rewire_method = :ADBM, Hmethod = :power, Z = 10.0)
    #ADBMTest = BioEnergeticFoodWebs.ADBM(S,p,biomass)
    #@test ADBMTest == [0 0 0 0 0; 1 1 1 1 1; 0 0 0 0 0; 0 0 0 0 0; 1 1 1 1 1]

    #biomass Based
    p = model_parameters(A, rewire_method = :ADBM, Nmethod = :biomass, Z = 10.0)
    ADBMTest = BioEnergeticFoodWebs.ADBM(S,p,biomass)
    @test ADBMTest == [0 0 0 0 0; 0 0 0 0 0; 0 0 0 0 0; 0 0 0 0 0; 1 1 1 0 0]

end

module TestADBM_interval
    using BioEnergeticFoodWebs
    using Test
    A = [0 1 0 ; 0 0 1 ; 0 0 0]
    b = [0.8, 0.0, 0.5]
    p = model_parameters(A, rewire_method = :ADBM, adbm_trigger = :interval, adbm_interval = 100)

    s = simulate(p, b, stop = 1000)

    @test p[:extinctions] == [1,2]
    @test p[:extinctionstime] == [(0.0, 2) , (100.0, 1)]
    @test p[:tmpA] == [convert(Array{Any, 2}, A)]
    @test length(p[:rewiretime]) != 0

    A = [0 1 0 0 ; 0 0 0 1 ; 0 0 0 1 ; 0 0 0 0]
    p = model_parameters(A, rewire_method = :ADBM, adbm_trigger = :interval, adbm_interval = 1, Z = 10.0)
    b = [0.2, 0, 0.2, 1.0]

    s = simulate(p, b, stop = 10)

    @test p[:extinctions] == [2]
    @test length(p[:extinctionstime]) != 0
    @test p[:extinctionstime] == [(0.0, 2)]
    @test p[:tmpA] == map(x -> convert(Array{Any, 2}, x),[A])
    @test length(p[:rewiretime]) != 0

end
