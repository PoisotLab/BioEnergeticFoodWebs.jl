#=
Functions for temperature dependence of biological rates :

- NoEffectTemperature : temperature is not included
- ExtendedEppley : Extended (hump-shaped) Eppley function
- ExponentialBA : Exponential Boltzmann-Arrhénius function
- ExtendedBA : Extended (hump-shaped) Boltzmann-Arrhénius function
- Gaussian : Gaussian, or inverse Gaussian, function

These functions take as argument :
- rate_affected : the type of biological rate (metabolic, growth, attack rate or handling time) specified with a key (symbol)
- parameters_tuple : optionnal, a tuple with the parameters corresponding to the specified temperature dependence function

If no parameters are specified, default parameters are provided. However, as the parameters for temperature dependence functions can be quite specific,
we encourage to specify parameters corresponding to your study system.
All parameters can be changed or just a few of them.

The functions are called in model parameters as, for instance :

growthrate = NoEffectTemperature(:growthrate) -> no effect of temperature for growth rate
metabolicrate = ExtendedEppley(:metabolicrate) -> Extended Eppley function for metabolic rate
attackrate = ExponentialBA(:attackrate, parameters_tuple = parameters) -> Exponental BA function for attack rate, parameters are specified in the tuple 'parameters'

According to the 'rate_affected' parameter, each function calls the specified temperature dependence function defined in temperature_dependence_functions.jl
For instance : when metabolicrate = ExtendedEppley(:metabolicrate), the function extended_eppley_x from temperature_dependence_functions.jl is used to define the metabolic rate

The functions return either a value, a vector or a matrix for the value of the biological rate, depending on which biological rate is chosen.
=#

"""
**No effect of temperature on biological rates**
This function is called by default in model_parameters to define temperature independent biological rates.
It takes as argument:
- rate_affected : may be :growth, :r, :metabolism, :x, :handlingtime, :attackrate
- parameters_tuple : to specify parameters but default parameters are provided (see temperature_dependence_functions.jl)

It calls the functions defined in temperature_dependence_functions.jl, according to which affected rate is specified
    - if :growth, :r -> no_effect_r
    - if :metabolism, :x -> no_effect_x
    - if :attackrate -> no_effect_attackr
    - if :handlingtime -> no_effect_handlingt

It returns the default values of biological rates when there is no effect of temperature (see Delmas et al 2017).

Example :

p = model_parameters(A, metabolicrate = NoEffectTemperature(:x))

"""

function NoEffectTemperature(rate_affected::Symbol; parameters_tuple...)
    if rate_affected ∉ [:growth, :r, :metabolism, :x, :handlingtime, :attackrate]
        error("rate_affected should be either :growth (alternatively :r or :growthrate), :metabolism (alternatively :x or :metabolicrate),
        :handlingtime or :attackrate")
    end
    if rate_affected ∈ [:growth, :r, :growthrate]
        if length(parameters_tuple) != 0
            pt = parameters_tuple[:parameters_tuple]
            no_effect_r(passed_temp_parameters = pt)
        else
            no_effect_r()
        end
    elseif rate_affected ∈ [:metabolism, :x, :metabolicrate]
        if length(parameters_tuple) != 0
            pt = parameters_tuple[:parameters_tuple]
            no_effect_x(passed_temp_parameters = pt)
        else
            no_effect_x()
        end
    elseif rate_affected == :handlingtime
        if length(parameters_tuple) != 0
            pt = parameters_tuple[:parameters_tuple]
            no_effect_handlingt(passed_temp_parameters = pt)
        else
            no_effect_handlingt()
        end
    elseif rate_affected == :attackrate
        if length(parameters_tuple) != 0
            pt = parameters_tuple[:parameters_tuple]
            no_effect_attackr(passed_temp_parameters = pt)
        else
            no_effect_attackr()
        end
    end
end

"""
**Extended Eppley**

This function can be called in model_parameters to define a temperature dependent biological rate that follows an Eppley function.
It takes as argument:
- rate_affected : may be :growth, :r, :metabolism, :x
- parameters_tuple : to specify parameters, default parameters are provided (see temperature_dependence_functions.jl)

It calls the functions defined in temperature_dependence_functions.jl, according to which affected rate is specified
    - if :growth, :r -> extended_eppley_r
    - if :metabolism, :x -> extended_eppley_x

It returns the values of biological rates as defined by the Eppley function.

Example : to define a metabolic rate following an Eppley function

p = model_parameters(A, metabolicrate = ExtendedEppley(:x))

Parameters can be specified as follows :

p = model_parameters(A, metabolicrate = ExtendedEppley(:x, parameters_tuple = @NT(maxrate_0_producer = 0.81, maxrate_0_invertebrate = 0.81, maxrate_0_vertebrate = 0.81,
                                     eppley_exponent_producer = 0.0631, eppley_exponent_invertebrate = 0.0631, eppley_exponent_vertebrate = 0.0631,
                                     T_opt_producer = 310.15, T_opt_invertebrate = 310.15, T_opt_vertebrate = 298.15,
                                     range_producer = 35, range_invertebrate = 35, range_vertebrate = 35,
                                     β_producer = -0.25, β_invertebrate = -0.25, β_vertebrate = -0.25))


"""

function ExtendedEppley(rate_affected::Symbol; parameters_tuple...)
    if rate_affected ∉ [:growth, :growthrate, :r, :metabolism, :x, :metabolicrate] ; error("rate_affected should be either :growth (alternatively :r or :growthrate) or :metabolism (alternatively :x or :metabolicrate)") ; end
    if rate_affected ∈ [:growth, :r, :growthrate]
        if length(parameters_tuple) != 0
            pt = parameters_tuple[:parameters_tuple]
            extended_eppley_r(passed_temp_parameters = pt)
        else
            extended_eppley_r()
        end
    elseif rate_affected ∈ [:metabolism, :x, :metabolicrate]
        if length(parameters_tuple) != 0
            pt = parameters_tuple[:parameters_tuple]
            extended_eppley_x(passed_temp_parameters = pt)
        else
            extended_eppley_x()
        end
    end
end

"""
**Exponential Boltzmann-Arrhenius**

This function can be called in model_parameters to define a temperature dependent biological rate that follows an exponential Boltzmann-Arrhenius function.
It takes as argument:
- rate_affected : may be :growth, :r, :metabolism, :x, :handlingtime, :attackrate
- parameters_tuple : to specify parameters, default parameters are provided (see temperature_dependence_functions.jl)

It calls the functions defined in temperature_dependence_functions.jl, according to which affected rate is specified
    - if :growth, :r -> exponential_BA_r
    - if :metabolism, :x -> exponential_BA_x
    - if :attackrate -> exponential_BA_attackr
    - if :handlingtime -> exponential_BA_handlingt

It returns the values of biological rates as defined by the exponential BA function.

Example : to define a growth rate following an exponential BA function

p = model_parameters(A, growthrate = ExponentialBA(:r))

Parameters can be specified as follows :

p = model_parameters(A, growthrate = ExponentialBA(:r, parameters_tuple = @NT(norm_constant = -16.54, activation_energy = -0.55, T0 = 293.15, β = -0.31))

"""

function ExponentialBA(rate_affected::Symbol; parameters_tuple...)
    if rate_affected ∉ [:growth, :r, :metabolism, :x, :handlingtime, :attackrate]
        error("rate_affected should be either :growth (alternatively :r or :growthrate), :metabolism (alternatively :x or :metabolicrate), :attackrate or :handlingtime")
    end
    if rate_affected ∈ [:growth, :r, :growthrate]
        if length(parameters_tuple) != 0
            pt = parameters_tuple[:parameters_tuple]
            exponential_BA_r(passed_temp_parameters = pt)
        else
            exponential_BA_r()
        end
    elseif rate_affected ∈ [:metabolism, :x, :metabolicrate]
        if length(parameters_tuple) != 0
            pt = parameters_tuple[:parameters_tuple]
            exponential_BA_x(passed_temp_parameters = pt)
        else
            exponential_BA_x()
        end
    elseif rate_affected == :attackrate
        if length(parameters_tuple) != 0
            pt = parameters_tuple[:parameters_tuple]
            exponential_BA_attackr(passed_temp_parameters = pt)
        else
            exponential_BA_attackr()
        end
    elseif rate_affected == :handlingtime
        if length(parameters_tuple) != 0
            pt = parameters_tuple[:parameters_tuple]
            exponential_BA_handlingt(passed_temp_parameters = pt)
        else
            exponential_BA_handlingt()
        end
    end
end

"""
**Extended  Boltzmann-Arrhenius**

This function can be called in model_parameters to define a temperature dependent biological rate that follows an extended (hump-shaped) Boltzmann-Arrhenius function.
It takes as argument:
- rate_affected : may be :growth, :r, :metabolism, :x, :attackrate
- parameters_tuple : to specify parameters, default parameters are provided (see temperature_dependence_functions.jl)

It calls the functions defined in temperature_dependence_functions.jl, according to which affected rate is specified
    - if :growth, :r -> extended_BA_r
    - if :metabolism, :x -> extended_BA_x
    - if :attackrate -> extended_BA_attackr

It returns the values of biological rates as defined by the extended BA function.

Example : to define a growth rate following an exponential BA function

p = model_parameters(A, growthrate = ExtendedBA(:r))

Parameters can be specified as follows :

p = model_parameters(A, growthrate = ExtendedBA(:r, parameters_tuple = @NT(norm_constant = 3e8, activation_energy = 0.53, deactivation_energy = 1.15, T_opt = 298.15, β = -0.25))

"""


function ExtendedBA(rate_affected::Symbol; parameters_tuple...)
    if rate_affected ∉ [:growth, :r, :metabolism, :x, :attackrate]
        error("rate_affected should be either :growth (alternatively :r or :growthrate), :metabolism (alternatively :x or :metabolicrate), or :attackrate")
    end
    if rate_affected ∈ [:growth, :r, :growthrate]
        if length(parameters_tuple) != 0
            pt = parameters_tuple[:parameters_tuple]
            extended_BA_r(passed_temp_parameters = pt)
        else
            extended_BA_r()
        end
    elseif rate_affected ∈ [:metabolism, :x, :metabolicrate]
        if length(parameters_tuple) != 0
            pt = parameters_tuple[:parameters_tuple]
            extended_BA_x(passed_temp_parameters = pt)
        else
            extended_BA_x()
        end
    elseif rate_affected == :attackrate
        if length(parameters_tuple) != 0
            pt = parameters_tuple[:parameters_tuple]
            extended_BA_attackr(passed_temp_parameters = pt)
        else
            extended_BA_attackr()
        end
    end
end

"""
**Gaussian**

This function can be called in model_parameters to define a temperature dependent biological rate that follows a Gaussian function.
It takes as argument:
- rate_affected : may be :growth, :r, :metabolism, :x, :handlingtime, :attackrate
- parameters_tuple : to specify parameters, default parameters are provided (see temperature_dependence_functions.jl)

It calls the functions defined in temperature_dependence_functions.jl, according to which affected rate is specified
    - if :growth, :r -> gaussian_r
    - if :metabolism, :x -> gaussian_x
    - if :attackrate -> gaussian_attackr
    - if :handlingtime -> gaussian_handlingt

It returns the values of biological rates as defined by the Gaussian function.

Example : to define a handling time following a Gaussian function

p = model_parameters(A, handlingtime = Gaussian(:handlingtime))

Parameters can be specified as follows :

p = model_parameters(A, handlingtime = Gaussian(:handlingtime, parameters_tuple = @NT(norm_constant_invertebrate = 0.5, norm_constant_vertebrate = 0.5,
                        range_invertebrate = 20, range_vertebrate = 20,
                        T_opt_invertebrate = 295, T_opt_vertebrate = 295,
                        β_producer = -0.25, β_invertebrate = -0.25, β_vertebrate = -0.25))

"""


function Gaussian(rate_affected::Symbol; parameters_tuple...)
    if rate_affected ∉ [:growth, :r, :metabolism, :x, :handlingtime, :attackrate]
        error("rate_affected should be either :growth (alternatively :r or :growthrate), :metabolism (alternatively :x or :metabolicrate) or :functionalresponse")
    end
    if rate_affected ∈ [:growth, :r, :growthrate]
        if length(parameters_tuple) != 0
            pt = parameters_tuple[:parameters_tuple]
            gaussian_r(passed_temp_parameters = pt)
        else
            gaussian_r()
        end
    elseif rate_affected ∈ [:metabolism, :x, :metabolicrate]
        if length(parameters_tuple) != 0
            pt = parameters_tuple[:parameters_tuple]
            gaussian_x(passed_temp_parameters = pt)
        else
            gaussian_x()
        end
    elseif rate_affected ∈ [:attackrate]
        if length(parameters_tuple) != 0
            pt = parameters_tuple[:parameters_tuple]
            gaussian_attackr(passed_temp_parameters = pt)
        else
            gaussian_attackr()
        end
    elseif rate_affected ∈ [:handlingtime]
        if length(parameters_tuple) != 0
            pt = parameters_tuple[:parameters_tuple]
            gaussian_handlingt(passed_temp_parameters = pt)
        else
            gaussian_handlingt()
        end
    end
end
