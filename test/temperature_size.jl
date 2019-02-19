module TestNoEffectTempSize
    using BioEnergeticFoodWebs
    using Base.Test

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

end

# module TestEffectTempSize
#     using BioEnergeticFoodWebs
#     using Base.Test
#
# end
