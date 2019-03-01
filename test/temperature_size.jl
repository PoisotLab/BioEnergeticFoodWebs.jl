module TestNoEffectTempSize
    using BioEnergeticFoodWebs
    using Test

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
    p_dm = model_parameters(EC, TSR_type = :no_response, dry_mass_293 = dm)
    expected_mass_dm = dm .* 6.5
    @test p_dm[:bodymass] == expected_mass_dm
end

module TestEffectTempSize
    using BioEnergeticFoodWebs
    using Statistics
    using Test

    EC = [0 0 1 ; 0 0 1 ; 0 0 0]
    dm = [1.0, 0.8, 0.2]
    wm = dm .* 6.5
    temp = 295.0
    temp_c = temp-273.15
    temp2 = 285.0
    temp2_c = temp2-273.15

    # MEAN AQUATIC
    # dry mass
    p_aqua_1 = model_parameters(EC, TSR_type = :mean_aquatic, dry_mass_293 = dm, T = temp)
    pcm_aqua_1 = -3.90 .- 0.53 .* log10.(dm)
    TSr_aqua_1 = log.(pcm_aqua_1 ./ 100 .+ 1)
    expected_bm_aqua = (dm .* 6.5) .* exp.(TSr_aqua_1 .* (temp_c-20))
    @test p_aqua_1[:bodymass] == expected_bm_aqua
    p_aqua_2 = model_parameters(EC, TSR_type = :mean_aquatic, dry_mass_293 = dm, T = temp2)
    @test p_aqua_2[:bodymass] > p_aqua_1[:bodymass]
    # wet mass
    p_aquawm = model_parameters(EC, TSR_type = :mean_aquatic, bodymass = wm, T = temp)
    pcm_aquawm = -3.90 .- 0.53 .* log10.(dm)
    TSr_aquawm = log.(pcm_aquawm ./ 100 .+ 1)
    expected_bm_aquawm = wm .* exp.(TSr_aquawm .* (temp_c-20))
    @test p_aquawm[:bodymass] == expected_bm_aqua == expected_bm_aquawm
    # Z
    p_aqua_z = model_parameters(EC, TSR_type = :mean_aquatic, Z = 10.0, T = temp)
    pcm_aqua_z = -3.90 .- 0.53 .* log10.([10.0, 10.0, 1.0] ./ 6.5)
    TSr_aqua_z = log.(pcm_aqua_z ./ 100 .+ 1)
    expected_bm_aqua_z = [10.0, 10.0, 1.0] .* exp.(TSr_aqua_z .* (temp_c-20))
    @test p_aqua_z[:bodymass] == expected_bm_aqua_z

    # MEAN TERRESTRIAL
    # dry mass
    p_terr_1 = model_parameters(EC, TSR_type = :mean_terrestrial, dry_mass_293 = dm, T = temp)
    pcm_terr_1 = -1.72 .+ 0.54 .* log10.(dm)
    TSr_terr_1 = log.(pcm_terr_1 ./ 100 .+ 1)
    expected_bm_terr = (dm .* 6.5) .* exp.(TSr_terr_1 .* (temp_c-20))
    @test p_terr_1[:bodymass] == expected_bm_terr
    p_terr_2 = model_parameters(EC, TSR_type = :mean_terrestrial, dry_mass_293 = dm, T = temp2)
    @test p_terr_2[:bodymass] > p_terr_1[:bodymass]
    # wet mass
    p_terrwm = model_parameters(EC, TSR_type = :mean_terrestrial, bodymass = wm, T = temp)
    pcm_terrwm = -1.72 .+ 0.54 .* log10.(dm)
    TSr_terrwm = log.(pcm_terrwm ./ 100 .+ 1)
    expected_bm_terrwm = wm .* exp.(TSr_terrwm .* (temp_c-20))
    @test p_terrwm[:bodymass] == expected_bm_terr == expected_bm_terrwm
    # Z
    p_terr_z = model_parameters(EC, TSR_type = :mean_terrestrial, Z = 10.0, T = temp)
    pcm_terr_z = -1.72 .+ 0.54 .* log10.([10.0, 10.0, 1.0] ./ 6.5)
    TSr_terr_z = log.(pcm_terr_z ./ 100 .+ 1)
    expected_bm_terr_z = [10.0, 10.0, 1.0] .* exp.(TSr_terr_z .* (temp_c-20))
    @test p_terr_z[:bodymass] == expected_bm_terr_z

    # MAXIMUM
    # dry mass
    p_max_1 = model_parameters(EC, TSR_type = :maximum, dry_mass_293 = dm, T = temp)
    pcm_max_1 = -8
    TSr_max_1 = log.(pcm_max_1 ./ 100 .+ 1)
    expected_bm_max = (dm .* 6.5) .* exp.(TSr_max_1 .* (temp_c-20))
    @test p_max_1[:bodymass] == expected_bm_max
    p_max_2 = model_parameters(EC, TSR_type = :maximum, dry_mass_293 = dm, T = temp2)
    @test p_max_2[:bodymass] > p_max_1[:bodymass]
    # wet mass
    p_maxwm = model_parameters(EC, TSR_type = :maximum, bodymass = wm, T = temp)
    pcm_maxwm = -8
    TSr_maxwm = log.(pcm_maxwm ./ 100 .+ 1)
    expected_bm_maxwm = wm .* exp.(TSr_maxwm .* (temp_c-20))
    @test p_maxwm[:bodymass] == expected_bm_max == expected_bm_maxwm
    # Z
    p_max_z = model_parameters(EC, TSR_type = :maximum, Z = 10.0, T = temp)
    pcm_max_z = -8
    TSr_max_z = log.(pcm_max_z ./ 100 .+ 1)
    expected_bm_max_z = [10.0, 10.0, 1.0] .* exp.(TSr_max_z .* (temp_c-20))
    @test p_max_z[:bodymass] == expected_bm_max_z

    # REVERSE
    # dry mass
    p_rev_1 = model_parameters(EC, TSR_type = :reverse, dry_mass_293 = dm, T = temp)
    pcm_rev_1 = 4
    TSr_rev_1 = log.(pcm_rev_1 ./ 100 .+ 1)
    expected_bm_rev = (dm .* 6.5) .* exp.(TSr_rev_1 .* (temp_c-20))
    @test p_rev_1[:bodymass] == expected_bm_rev
    p_rev_2 = model_parameters(EC, TSR_type = :reverse, dry_mass_293 = dm, T = temp2)
    @test p_rev_2[:bodymass] < p_rev_1[:bodymass]
    # wet mass
    p_revwm = model_parameters(EC, TSR_type = :reverse, bodymass = wm, T = temp)
    pcm_revwm = 4
    TSr_revwm = log.(pcm_revwm ./ 100 .+ 1)
    expected_bm_revwm = wm .* exp.(TSr_revwm .* (temp_c-20))
    @test p_revwm[:bodymass] == expected_bm_rev == expected_bm_revwm
    # Z
    p_rev_z = model_parameters(EC, TSR_type = :reverse, Z = 10.0, T = temp)
    pcm_rev_z = 4
    TSr_rev_z = log.(pcm_rev_z ./ 100 .+ 1)
    expected_bm_rev_z = [10.0, 10.0, 1.0] .* exp.(TSr_rev_z .* (temp_c-20))
    @test p_rev_z[:bodymass] == expected_bm_rev_z

end
