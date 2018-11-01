### Temperature Size Rule, following Forster et al 2012 ###

# Args:
# dry_mass_20 temperature in Kelvin degrees, DM20 dry mass at 20 degrees

function temperature_size_rule(dry_mass_20, temperature_K, TSR_type)

    temperature_C = temperature_K - 273.15

    if TSR_type == :mean_aquatic
        PCM = -3.90-0.53*log10(dry_mass_20)     # PCM = Percentage change in body-mass per degrés C

    elseif TSR_type == :mean_terrestrial
        PCM = -1.72+0.54*log10(dry_mass_20)

    elseif TSR_type == :maximum
        PCM = -8

    elseif TSR_type == :reverse
        PCM = 4

    elseif TSR_type == :no_response
        PCM = 0

    else
        println("TSR_type should be one of : mean_aquatic, mean_terrestrial, maximum, reverse or no_response")

    end

    convert_dfmass = 6.5
    TS_response = log(PCM/100+1)               # Sign and magnitude of TS response
    fresh_mass = convert_dfmass*dry_mass_20*exp(TS_response*(temperature_C-20))  # dry mass converted to fresh mass

    return fresh_mass
end
