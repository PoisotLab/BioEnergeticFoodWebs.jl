#=
**Functions of thermal performance curve for model parameters**

We included different functions for temperature dependence :
1) Extended Eppley function
2) Exponential Boltzmann-Arrhenius function
3) Extended Boltzmann-Arrhenius function (Johnson-Lewin)
4) Gaussian (inverted Gaussian) function

In each case, the function returns the biological rate value at a given temperature.
=#

"""
****
TODO
"""

function no_effect_x(T_param)
    return (bodymass, T, p) ->  (T_param.a_vertebrate .* (p[:vertebrates] .& .!p[:is_producer]) + T_param.a_invertebrate * (.!p[:vertebrates] .& .!p[:is_producer]) + T_param.a_producer .* p[:is_producer]) .* (bodymass.^-0.25)
end

"""
****
TODO
"""

function no_effect_r(T_param)
    return (bodymass, T, p) -> T_param.r
end

"""
****
TODO
"""

function no_effect_handlingt(T_param)
     return (bodymass, T, p) ->  1 ./ (T_param.y_vertebrate .* (p[:vertebrates] .& .!p[:is_producer]) + T_param.y_invertebrate * (.!p[:vertebrates] .& .!p[:is_producer]))
end

"""
****
TODO
"""

function no_effect_attackr(T_param)
    return (bodymass, T, p) -> 1 ./ (T_param.Γ .* p[:ht])
end


"""
**Option 1 : Extended Eppley function**

This function can be called as an argument in `model_parameters` to define an extended Eppley funtion (ref) for one of:
    - metabolic rate
    - producers growth rate
    - handling time
    - attack rate

| Parameter       | Meaning                                                           | Default values| Reference |
|:----------------|:------------------------------------------------------------------|:--------------|:----------|
| maxrate_0       | Maximum rate at 273.15 degrees Kelvin                             | 0.81          |    TODO   |
| eppley_exponent | Exponential rate of increase                                      | 0.0631        |    TODO   |
| T_opt           | location of the maximum of the quadratic portion of the function  | 298.15        |    TODO   |
| range           | thermal breadth                                                   | 35            |    TODO   |
| β               | allometric exponent                                               | -0.25         |    TODO   |

Example:
TODO
"""

function extended_eppley(T_param)
    topt = T_param.T_opt - 273.15
    return (bodymass, T, p) -> bodymass.^T_param.β .* T_param.maxrate_0 .* exp(T_param.eppley_exponent .* (T.-273.15)) * (1 .- (((T.-273.15) .- topt) ./ (T_param.range./2)).^2)
end

"""
**Option 3 : Exponential Boltzmann-Arrhenius function**

| Parameter         | Meaning                               | Default values | Reference |
|:------------------|:--------------------------------------|----------------|-----------|
| norm_constant     | scaling coefficient                   | 0.2e11         |           |
| activation_energy | activation energy                     | 0.65           |           |
| β                 | allometric exponent                   | -0.25          |           |
| k                 | Boltzmann constant (k=8.617e-5)       | NA             |           |

"""

function exponentialBA(T_param)
    k=8.617e-5
    return (bodymass, T, p) -> T_param.norm_constant.*((bodymass.^T_param.β).*exp.(.-T_param.activation_energy./(k*T)))
end

"""
**Option 4 : Extended Boltzmann-Arrhenius function**

| Parameter     | Meaning                                               |
|:--------------|:------------------------------------------------------|
| temp          | temperature range (Kelvin)                            |
| p0            | scaling coefficient                                   |
| E             | activation energy                                     |
| Ed            | deactivation energy                                   |
| topt          | temperature at which trait value is maximal           |
| p[:bodymass]  | body mass                                             |
| beta          | allometric exponent                                   |
| k             | Boltzmann constant (k=8.617e-5)                       |

Parameters are for instance:

p0=0.2e12
E=0.65
Ed=1.15
topt=295
p[:bodymass]=1
beta=-0.25
"""

function extended_BA(T_param)
    k = 8.617e-5 # Boltzmann constant
    kt = k * T
    pwr = T_param.β.*exp(.-T_param.activation_energy./kt)
    Δenergy = T_param.deactivation_energy .- T_param.activation_energy
    lt = 1 ./ (1 + exp.(-1 / kt .* (T_param.deactivation_energy .- (T_param.deactivation_energy ./ T_param.T_opt .+ k .* log(T_param.activation_energy ./ Δenergy)).*T)))
    return(bodymass, T, p) -> T_param.norm_const .* (bodymass.^pwr) .* lt
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
        return(bodymass, T, p) -> bodymass.^T_param.β .* T_param.norm_const .* exp(.-(T .- T_param.T_opt).^2 ./ (2 .*T_param.range.^2))
    elseif T_param.shape == :U
        return(bodymass, T, p) -> bodymass.^T_param.β .* T_param.norm_const .* exp((T .- T_param.T_opt).^2 ./ (2 .*T_param.range.^2))
    end
end
