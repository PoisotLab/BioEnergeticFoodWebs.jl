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

"""

function no_effect_x(T_param)
    return (bodymass, T, p) ->  (T_param.a_vertebrate .* (p[:vertebrates] .& .!p[:is_producer]) + T_param.a_invertebrate * (.!p[:vertebrates] .& .!p[:is_producer]) + T_param.a_producer .* p[:is_producer]) .* (bodymass.^-0.25)
end

"""
**No effect of temperature on growth rate**
TODO
"""

function no_effect_r(T_param)
    return (bodymass, T, p) -> T_param.r
end

"""
**No effect of temperature on handling time**
TODO
"""

function no_effect_handlingt(T_param)
     return (bodymass, T, p) ->  1 ./ (T_param.y_vertebrate .* (p[:vertebrates] .& .!p[:is_producer]) + T_param.y_invertebrate * (.!p[:vertebrates] .& .!p[:is_producer]))
end

"""
**No effect of temperature on attack rate**
TODO
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


| Parameter       | Meaning                                                           | Default values| Reference               |
|:----------------|:------------------------------------------------------------------|:--------------|:------------------------|
| maxrate_0       | Maximum rate at 273.15 degrees Kelvin                             | 0.81          |    Eppley 1972          |
| eppley_exponent | Exponential rate of increase                                      | 0.0631        |    Eppley 1972          |
| T_opt           | location of the maximum of the quadratic portion of the function  | 298.15        |    NA                   |
| range           | thermal breadth                                                   | 35            |    NA                   |
| β               | allometric exponent                                               | -0.25         |    Gillooly et al. 2002 |

Default values are given for growth rate r.

Example:
growthrate=extended_eppley(@NT(maxrate_0=0.81, eppley_exponent=0.0631,T_opt=298.15, range = 35, β = -0.25)
"""

function extended_eppley(T_param)
    topt = T_param.T_opt - 273.15
    return (bodymass, T, p) -> bodymass.^T_param.β .* T_param.maxrate_0 .* exp(T_param.eppley_exponent .* (T.-273.15)) * (1 .- (((T.-273.15) .- topt) ./ (T_param.range./2)).^2)
end

"""
**Option 3 : Exponential Boltzmann-Arrhenius function**

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

Default values are given for metabolic rate x.

Example:
metabolicrate=exponential_BA(@NT(norm_constant = -16.54, activation_energy = -0.69, T0 = 293.15, β = -0.31)

"""

function exponential_BA(T_param)
    k=8.617e-5
    return (bodymass, T, p) -> T_param.norm_constant .* (bodymass .^T_param.β) .* exp.(T_param.activation_energy .* (T .- T_param.T0) ./ (k * T .* T_param.T0))
end

"""
**Option 4 : Extended Boltzmann-Arrhenius function**


| Parameter     | Meaning                                               | Default values | Reference    |
|:--------------|:------------------------------------------------------|:---------------|--------------|
| p0            | scaling coefficient                                   |
| E             | activation energy                                     |
| Ed            | deactivation energy                                   |
| topt          | temperature at which trait value is maximal           |
| beta          | allometric exponent                                   |


p0=0.2e12
E=0.65
Ed=1.15
topt=295
p[:bodymass]=1
beta=-0.25
"""

function extended_BA(T_param)
    k = 8.617e-5 # Boltzmann constant
    Δenergy = T_param.deactivation_energy .- T_param.activation_energy
    return(bodymass, T, p) -> T_param.norm_constant .* bodymass .^(T_param.β) .* exp.(.-T_param.activation_energy ./ (k * T)) .* (1 ./ (1 + exp.(-1 / (k * T) .* (T_param.deactivation_energy .- (T_param.deactivation_energy ./ T_param.T_opt .+ k .* log(T_param.activation_energy ./ Δenergy)).*T))))
end


"""
**Option 5 : Gaussian function**

| Parameter    | Meaning                                        |
|:-------------|:-----------------------------------------------|
| temp         | temperature range (Kelvin)                     |
| p0           | minimal/maximal trait value                    |
| s            | performance breath (width of function)         |
| topt         | temperature at which trait value is maximal    |
| p[:bodymass] | body mass                                      |
| beta         | allometric exponent                            |

Parameters are for instance:

p0=0.5
s=20
topt=295
p[:bodymass]=1
beta=-0.25

"""

function gaussian(T_param)
    if T_param.shape == :hump
        return(bodymass, T, p) -> bodymass.^T_param.β .* T_param.norm_constant .* exp(.-(T .- T_param.T_opt).^2 ./ (2 .*T_param.range.^2))
    elseif T_param.shape == :U
        return(bodymass, T, p) -> bodymass.^T_param.β .* T_param.norm_constant .* exp((T .- T_param.T_opt).^2 ./ (2 .*T_param.range.^2))
    end
end
