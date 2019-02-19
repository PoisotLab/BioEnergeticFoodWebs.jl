module TestNoEffectTempSize
    using BioEnergeticFoodWebs
    using Base.Test

    # WET MASS (default)
    EC = [0 0 1 ; 0 0 1 ; 0 0 0]
    LFC = [0 1 0 ; 0 0 1 ; 0 0 0]
    bsize_ratio = 10.0 #consumers are 10 times larger than their resource
    p_ec = model_parameters(EC, Z = bsize_ratio)
    p_lfc = model_parameters(LFC, Z = bsize_ratio)
    #body sizes are CR ratio ^ (trophic rank - 1)
    expected_mass_ec = [10.0, 10.0, 1.0]
    @test p_ec[:bodymass] == expected_mass_ec
    expected_mass_lfc = [100.0, 10.0, 1.0]
    @test p_lfc[:bodymass] == expected_mass_lfc

    #if body masses are provided, it overwrites Z
    bm = [12.3, 2.3, 1.0]
    p_bm = model_parameters(EC, Z = bsize_ratio, bodymass = bm)
    @test p_bm[:bodymass] == bm

    # DRY MASS
    dm = [6.3, 5.2, 1.2]
    p_dm = model_parameters(EC, TSR_type = :no_response_DM, dry_mass_293 = dm)
    expected_mass_dm = dm .* 6.5
    @test p_dm[:bodymass] == expected_mass_dm
end

module TestEffectTempSize
    using BioEnergeticFoodWebs
    using Base.Test

    EC = [0 0 1 ; 0 0 1 ; 0 0 0]
    LFC = [0 1 0 ; 0 0 1 ; 0 0 0]
    dm = [1.0, 0.8, 0.2]
    temp = 295.0
    temp_c = temp-273.15
    temp2 = 285.0
    temp2_c = temp2-273.15

    # MEAN AQUATIC
    p_aqua_1 = model_parameters(EC, TSR_type = :mean_aquatic, dry_mass_293 = dm, T = temp)
    pcm_aqua_1 = -3.90 .- 0.53 .* log10.(dm)
    TSr_aqua_1 = log.(pcm_aqua_1 ./ 100 .+ 1)
    expected_bm_aqua = (dm .* 6.5) .* exp.(TSr_aqua_1 .* (temp_c-20))
    @test p_aqua_1[:bodymass] == expected_bm_aqua
    p_aqua_2 = model_parameters(EC, TSR_type = :mean_aquatic, dry_mass_293 = dm, T = temp2)
    @test p_aqua_2[:bodymass] > p_aqua_1[:bodymass]
    
    # MEAN TERRESTRIAL

    # MAXIMUM

end
