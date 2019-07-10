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

    NoEffectTemperature(::Symbol; parameters_tuple...)

Calculates biological rates independently of temperature.

Called by default in `model_parameters` to define temperature independent biological rates. Default
parameters values are provided, but can be overwritten through the keyword argument `parameters_tuple`
(see example). See the complete documentation for the default values and more details.

Arguments:

- rate_affected : the biological rate that the function should calculate. May be :growth, :metabolism, :handlingtime, :attackrate
- parameters_tuple : a named tuple specifying parameters values. Note that if you provide a one-element tuple, it should end with a comma to avoid being treated as a vector.

# Example :
```julia-repl
# Metabolic rate with default parameters (this is the default behavior of model_parameters)
julia> p = model_parameters(A, metabolicrate = NoEffectTemperature(:x))
# Growth rate, changing the default parameters
julia> p = model_parameters(A, growthrate = NoEffectTemperature(:r, parameters_tuple = (r = 1.5,)))
```
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

    ExtendedEppley(::Symbol, parameters_tuple...)

Calculates biological rates using an Extended Eppley function.

Can be called in `model_parameters` (see example) to define temperature dependent biological rates. The Extended Eppley
function is only compatible with metabolic and growth rate and cannot be used to calculate handling time or attack rate.
Default parameters values are provided, but can be overwritten through the keyword argument `parameters_tuple`. See the
complete documentation for the default values, their sources and more details.

Arguments:
- rate_affected : the biological rate that the function should calculate. May be :growth, :metabolism
- parameters_tuple : a named tuple specifying parameters values. Note that if you provide a one-element tuple, it should end with a comma to avoid being treated as a vector.

# Example
```julia-repl
# Metabolic rate with default parameters values
p = model_parameters(A, metabolicrate = ExtendedEppley(:x))
# Metabolic rate, changing some of the default parameters values
p = model_parameters(A, metabolicrate = ExtendedEppley(:x,
                                                       parameters_tuple = (maxrate_0_producer = 0.7,
                                                                           maxrate_0_vertebrate = 0.9))

```
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

    ExponentialBA(::Symbol, parameters_tuple...)

Calculates biological rates using an Exponential Boltzmann Arrhenius function.

Can be called in `model_parameters` (see example) to define temperature dependent biological rates. Default
parameters values are provided, but can be overwritten through the keyword argument `parameters_tuple`. See
the complete documentation for the default values, their sources and more details.

Arguments:
- rate_affected : the biological rate that the function should calculate. May be :growth, :metabolism, :handlingtime, :attackrate
- parameters_tuple : a named tuple specifying parameters values. Note that if you provide a one-element tuple, it should end with a comma to avoid being treated as a vector.

# Example
```julia-repl
# Handling time with default parameters values
p = model_parameters(A, handlingtime = ExponentialBA(:handlingtime))
# Metabolic rate, changing some of the default parameters values
p = model_parameters(A, metabolicrate = ExponentialBA(:x, parameters_tuple = (T0 = 300.0,))
```
"""
function ExponentialBA(rate_affected::Symbol; parameters_tuple...)
    if rate_affected ∉ [:growth, :r, :growthrate, :metabolism, :x, :metabolicrate, :handlingtime, :attackrate]
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

    ExtendedBA(::Symbol, parameters_tuple...)

Calculates biological rates using an Extended Boltzmann Arrhenius function.

Can be called in `model_parameters` (see example) to define temperature dependent biological rates. Only compatible
with metabolic, growth and attack rates. Default parameters values are provided, but can be overwritten through the
keyword argument `parameters_tuple`. See the complete documentation for the default values, their sources and more details.

Arguments:
- rate_affected : the biological rate that the function should calculate. May be :growth, :metabolism, :attackrate
- parameters_tuple : a named tuple specifying parameters values. Note that is you provide a one-element tuple, it should end with a comma to avoid being treated as a vector.

# Example
```julia-repl
# Attack rate with default parameters values
p = model_parameters(A, attackrate = ExtendedBA(:attackrate))
# Metabolic rate, changing some of the default parameters values
p = model_parameters(A, metabolicrate = ExtendedBA(:x, parameters_tuple = (T_opt = 290.0, activation_energy = 0.47))
```
"""
function ExtendedBA(rate_affected::Symbol; parameters_tuple...)
    if rate_affected ∉ [:growth, :r, :growthrate, :metabolism, :x, :metabolicrate, :attackrate]
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

    Gaussian(::Symbol, parameters_tuple...)

Calculates biological rates using a Gaussian function.

Can be called in `model_parameters` (see example) to define temperature dependent biological rates. Default parameters
values are provided, but can be overwritten through the keyword argument `parameters_tuple`. See the complete documentation
for the default values, their sources and more details.

Arguments:
- rate_affected : the biological rate that the function should calculate. May be :growth, :metabolism, :handlingtime, :attackrate
- parameters_tuple : a named tuple specifying parameters values. Note that is you provide a one-element tuple, it should end with a comma to avoid being treated as a vector.

# Example
```julia-repl
# Growth rate with default parameters values
p = model_parameters(A, growthrate = Gaussian(:growthrate))
# Metabolic rate, changing some of the default parameters values
p = model_parameters(A, metabolicrate = ExtendedBA(:x, parameters_tuple = (range_invertebrate = 25.0, ))
```
"""
function Gaussian(rate_affected::Symbol; parameters_tuple...)
    if rate_affected ∉ [:growth, :r, :growthrate, :metabolism, :x, :metabolicrate, :handlingtime, :attackrate]
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
