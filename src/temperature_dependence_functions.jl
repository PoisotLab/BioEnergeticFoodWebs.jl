#=
Functions for biological rates :
     - metabolic rate
     - growth rate
     - handling time
     - attack rate

When temperature is not included, the functions :
    - no_effect_x for metabolic rate
    - no_effect_r for growth rate
    - no_effect_handlingt for handling time
    - no_effect_attackr for attack rate

return the default values for temperature independent rates.

When temperature is included, they are 4 different functions of temperature dependence :

1) Extended Eppley function
2) Exponential Boltzmann-Arrhenius function
3) Extended Boltzmann-Arrhenius function (Johnson-Lewin)
4) Gaussian (inverted Gaussian) function

That can be changed in the following way:

A = [0 1 1 ; 0 0 0 ; 0 0 0]
p = model_parameters(A, T = 295, bodymass = 1, metabolicrate = extended_BA(@NT(T_parameters))

where:
- T is the temperature in Kelvin,
- bodymass is the species bodymass,
- T_parameters are the parameters associated with the extended_BA function.

This allows to directly specify the function to use for each rate and the set of parameters associated with this function within the parameters.
Internally the metabolicrate function (whichever is chosen) takes 3 arguments:

- species body mass (standardized by the smaller producer species),
- the temperature T,
- the set of parameters p.

model_parameters still returns a Dict, containing:

- x, the metabolic rate (unchanged)
- r, the intrinsic producer's growth rate, which is now specified for each species
- y, the maximum consumption rate, which is 1/ht, with ht being the handling time
- Γ, the half saturation density, which is 1/(ar * ht), with ar being the attack rate

=#

"""
**No effect of temperature on metabolic rate**

This function is by default called as an argument in `model_parameters` to define a temperature independent metabolic rate.
It returns the default values of metabolic rate when there is no effect of temperature (see Delmas et al 2017).
The function accounts for different metabolic rate according to the type of species (vertebrate, invertebrate, producer)

| Parameter       | Meaning             | Default values | Reference                       |
|:----------------|:--------------------|:---------------|:--------------------------------|
| a_vertebrate    | allometric constant | 0.88           | Brose, Williams & Martinez 2006 |
| a_invertebrate  | allometric constant | 0.3141         | Brose, Williams & Martinez 2006 |
| a_producer      | allometric constant | 0.138          | Brose, Williams & Martinez 2006 |

Internally the function takes 3 arguments:

- species body mass (standardized by the smaller producer species),
- the temperature T,
- the set of parameters p.

"""

function no_effect_x(T_param)
    return (bodymass, T, p) ->  (T_param.a_vertebrate .* (p[:vertebrates] .& .!p[:is_producer]) + T_param.a_invertebrate * (.!p[:vertebrates] .& .!p[:is_producer]) + T_param.a_producer .* p[:is_producer]) .* (bodymass.^-0.25)
end

"""
**No effect of temperature on growth rate**

This function is by default called as an argument in `model_parameters` to define a temperature independent growth rate.
It returns a default value for growth rate when there is no effect of temperature (see Delmas et al 2017).

| Parameter       | Meaning             | Default values | Reference                       |
|:----------------|:--------------------|:---------------|:--------------------------------|
| r               | growth rate         | 1              | Brose, Williams & Martinez 2006 |

Internally the function takes 3 arguments (unused in this case):

- species body mass (standardized by the smaller producer species),
- the temperature T,
- the set of parameters p.

"""

function no_effect_r(T_param)
    return (bodymass, T, p) -> T_param.r
end

"""
**No effect of temperature on handling time**

This function is by default called as an argument in `model_parameters` to define a temperature independent handling time.
It returns a default value for handling time which is defined by 1/y, y being the maximum consumption rate.
The function accounts for different maximum consumption rate values according to the type of species (vertebrate or invertebrate).

| Parameter       | Meaning                                    | Default values | Reference                       |
|:----------------|:-------------------------------------------|:---------------|:--------------------------------|
| y_vertebrate    | maximum consumption rate for vertebrates   | 4.0            | Brose, Williams & Martinez 2006 |
| y_invertebrate  | maximum consumption rate for invertebrates | 8.0            | Brose, Williams & Martinez 2006 |

Internally the function takes 3 arguments (unused in this case):

- species body mass (standardized by the smaller producer species),
- the temperature T,
- the set of parameters p.

"""

function no_effect_handlingt(T_param)
     return (bodymass, T, p) ->  1 ./ (T_param.y_vertebrate .* (p[:vertebrates] .& .!p[:is_producer]) + T_param.y_invertebrate * (.!p[:vertebrates] .& .!p[:is_producer]))
end

"""
**No effect of temperature on attack rate**

This function is by default called as an argument in `model_parameters` to define a temperature independent attack rate.
It returns a default value for handling time which is defined by 1/(Γ*h), Γ being the half saturation density.

| Parameter  | Meaning                   | Default values | Reference                       |
|:-----------|:--------------------------|:---------------|:--------------------------------|
| Γ          | half-saturation density   | 0.5            | Brose, Williams & Martinez 2006 |

Internally the function takes 3 arguments (unused in this case):

- species body mass (standardized by the smaller producer species),
- the temperature T,
- the set of parameters p.

"""

function no_effect_attackr(T_param)
    return (bodymass, T, p) -> 1 ./ (T_param.Γ .* p[:ht])
end


"""
**Option 1 : Extended Eppley function**

This function can be called as an argument in `model_parameters` to define an extended Eppley funtion (Eppley 1972, Thomas et al. 2012) for one of:
    - metabolic rate
    - producers growth rate
    - attack rate
    - handling time (not recommended as it is a hump-shaped curve)


| Parameter       | Meaning                                                           | Default values| Reference            |
|:----------------|:------------------------------------------------------------------|:--------------|:---------------------|
| maxrate_0       | Maximum rate at 273.15 degrees Kelvin                             | 0.81          | Eppley 1972          |
| eppley_exponent | Exponential rate of increase                                      | 0.0631        | Eppley 1972          |
| T_opt           | location of the maximum of the quadratic portion of the function  | 298.15        | NA                   |
| range           | thermal breadth                                                   | 35            | NA                   |
| β               | allometric exponent                                               | -0.25         | Gillooly et al. 2002 |

Default values are given as an example for growth rate r.

Example:
growthrate=extended_eppley(@NT(maxrate_0=0.81, eppley_exponent=0.0631,T_opt=298.15, range = 35, β = -0.25))
"""

function extended_eppley(T_param)
    topt = T_param.T_opt - 273.15
    return (bodymass, T, p) -> bodymass.^T_param.β .* T_param.maxrate_0 .* exp(T_param.eppley_exponent .* (T.-273.15)) * (1 .- (((T.-273.15) .- topt) ./ (T_param.range./2)).^2)
end

"""
**Option 2 : Exponential Boltzmann-Arrhenius function**

This function can be called as an argument in `model_parameters` to define an exponential Boltzmann-Arrhénius function (Gillooly et al. 2001, Brown et al. 2004) for one of:
    - metabolic rate
    - producers growth rate
    - attack rate
    - handling time (not recommended as it is a hump-shaped curve)


| Parameter         | Meaning                               | Default values | Reference                             |
|:------------------|:--------------------------------------|:---------------|:--------------------------------------|
| norm_constant     | scaling coefficient                   | -16.54         | Ehnes et al. 2011, Binzer et al. 2012 |
| activation_energy | activation energy                     | -0.69          | Ehnes et al. 2011, Binzer et al. 2012 |
| T0                | normalization temperature (K)         | 293.15         | Binzer et al. 2012, Binzer et al. 2012|
| β                 | allometric exponent                   | -0.31          | Ehnes et al. 2011                     |

Default values are given as an example for metabolic rate x.

Example:
metabolicrate=exponential_BA(@NT(norm_constant = -16.54, activation_energy = -0.69, T0 = 293.15, β = -0.31))

"""

function exponential_BA(T_param)
    k=8.617e-5
    return (bodymass, T, p) -> T_param.norm_constant .* (bodymass .^T_param.β) .* exp.(T_param.activation_energy .* (T .- T_param.T0) ./ (k * T .* T_param.T0))
end

"""
**Option 3 : Extended Boltzmann-Arrhenius function**


| Parameter          | Meaning                                               | Default values | Reference            |
|:-------------------|:------------------------------------------------------|:---------------|----------------------|
| norm_constant      | scaling coefficient                                   | 3e8            | NA                   |
| activation_energy  | activation energy                                     | 0.53           | Dell et al 2011      |
| deactivation_energy| deactivation energy                                   | 1.15           | Dell et al 2011      |
| T_opt              | temperature at which trait value is maximal           | 298.15         | NA                   |
| β                  | allometric exponent                                   | -0.25          | Gillooly et al. 2002 |

Default values are given as an example for growth rate r.

Example:
growthrate=extended_BA(@NT(norm_constant = 3e8, activation_energy = 0.53, deactivation_energy = 1.15, T_opt = 298.15, β = -0.25))


"""

function extended_BA(T_param)
    k = 8.617e-5 # Boltzmann constant
    Δenergy = T_param.deactivation_energy .- T_param.activation_energy
    return(bodymass, T, p) -> T_param.norm_constant .* bodymass .^(T_param.β) .* exp.(.-T_param.activation_energy ./ (k * T)) .* (1 ./ (1 + exp.(-1 / (k * T) .* (T_param.deactivation_energy .- (T_param.deactivation_energy ./ T_param.T_opt .+ k .* log(T_param.activation_energy ./ Δenergy)).*T))))
end


"""
**Option 4 : Gaussian function**

| Parameter    | Meaning                                        | Default values | Reference            |
|:-------------|:-----------------------------------------------|:---------------|:---------------------|
| shape        | hump-shaped (:hump) or U-shaped (:U) curve     | :hump          | Amarasekare 2015     |
| norm_constant| minimal/maximal trait value                    | 0.5            | NA                   |
| range        | performance breath (width of function)         | 20             | Amarasekare 2015     |
| T_opt        | temperature at which trait value is maximal    | 295            | Amarasekare 2015     |
| β            | allometric exponent                            | -0.25          | Gillooly et al 2002  |

Default values are given as an example for growth rate r.

Example:
growthrate=gaussian(@NT(shape = :hump, norm_constant = 0.5, range = 20, T_opt = 295, β = -0.25))

"""

function gaussian(T_param)
    if T_param.shape == :hump
        return(bodymass, T, p) -> bodymass.^T_param.β .* T_param.norm_constant .* exp(.-(T .- T_param.T_opt).^2 ./ (2 .*T_param.range.^2))
    elseif T_param.shape == :U
        return(bodymass, T, p) -> bodymass.^T_param.β .* T_param.norm_constant .* exp((T .- T_param.T_opt).^2 ./ (2 .*T_param.range.^2))
    end
end
