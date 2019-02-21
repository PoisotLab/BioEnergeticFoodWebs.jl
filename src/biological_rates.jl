#=
Functions for temperature dependence of biological rates :

- NoEffectTemperature : temperature is not included
- ExtendedEppley : Extended (hump-shaped) Eppley function
- ExponentialBA : Exponential Boltzmann-Arrhénius function
- ExtendedBA : Extended (hump-shaped) Boltzmann-Arrhénius function
- Gaussian : Gaussian, or inverse Gaussian, function

These functions take as argument :
- rate_affected : the type of biological rate (metabolic, growth, attack rate or handling time) specified with a key (symbol)
- parameters_tuple : optionnal, a tuple with the parameters (default parameters are also provided)

The functions are called in model parameters as, for instance :

growthrate = NoEffectTemperature(:growthrate) -> no effect of temperature for growth rate
metabolicrate = ExtendedEppley(:metabolicrate) -> Extended Eppley function for metabolic rate
attackrate = ExponentialBA(:attackrate, parameters_tuple = parameters) -> Exponental BA function for attack rate, parameters are specified in the tuple 'parameter'

According to the 'rate_affected' parameter, each function calls the specified temperature dependence function defined in temperature_dependence_functions.jl
For instance : when metabolicrate = ExtendedEppley(:metabolicrate), the function extended_eppley_x from temperature_dependence_functions.jl is used to define the metabolic rate

The functions return either a value, a vector or a matrix for the value of the biological rate, depending on which biological rate is chosen.
=#

"""
No effect of temperature
TODO
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
Extended Eppley
TODO
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
Exponential Boltzmann-Arrhenius
TODO
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
Extended Boltzmann-Arrhenius
TODO
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
Gaussian
TODO
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
