#=
TODO
=#

"""
No effect of temperature
TODO
"""

function NoEffectTemperature(rate_affected::Symbol; parameters_tuple...)
    if rate_affected ∉ [:growth, :r, :metabolism, :x, :handlingtime, :attackrate]
        error("rate_affected should be eighter :growth (alternatively :r or :growthrate), :metabolism (alternatively :x or :metabolicrate),
        :handlingtime or :attackrate")
    end
    if rate_affected ∈ [:growth, :r, :growthrate]
        if length(parameters_tuple) != 0
            pt = parameters_tuple[:parameters_tuple]
            no_effect_r(passed_temp_parameters = parameters_tuple)
        else
            no_effect_r()
        end
    elseif rate_affected ∈ [:metabolism, :x, :metabolicrate]
        if length(parameters_tuple) != 0
            pt = parameters_tuple[:parameters_tuple]
            no_effect_x(passed_temp_parameters = parameters_tuple)
        else
            no_effect_x()
        end
    elseif rate_affected == :handlingtime
        if length(parameters_tuple) != 0
            pt = parameters_tuple[:parameters_tuple]
            no_effect_handlingt(passed_temp_parameters = parameters_tuple)
        else
            no_effect_handlingt()
        end
    elseif rate_affected == :attackrate
        if length(parameters_tuple) != 0
            pt = parameters_tuple[:parameters_tuple]
            no_effect_attackr(passed_temp_parameters = parameters_tuple)
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
    if rate_affected ∉ [:growth, :r, :metabolism, :x] ; error("rate_affected should be eighter :growth (alternatively :r or :growthrate) or :metabolism (alternatively :x or :metabolicrate)") ; end
    if rate_affected ∈ [:growth, :r, :growthrate]
        if length(parameters_tuple) != 0
            pt = parameters_tuple[:parameters_tuple]
            extended_eppley_r(passed_temp_parameters = parameters_tuple)
        else
            extended_eppley_r()
        end
    elseif rate_affected ∈ [:metabolism, :x, :metabolicrate]
        if length(parameters_tuple) != 0
            pt = parameters_tuple[:parameters_tuple]
            extended_eppley_x(passed_temp_parameters = parameters_tuple)
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
        error("rate_affected should be eighter :growth (alternatively :r or :growthrate), :metabolism (alternatively :x or :metabolicrate) or :functionalresponse")
    end
    if rate_affected ∈ [:growth, :r, :growthrate]
        if length(parameters_tuple) != 0
            pt = parameters_tuple[:parameters_tuple]
            exponential_BA_r(passed_temp_parameters = parameters_tuple)
        else
            exponential_BA_r()
        end
    elseif rate_affected ∈ [:metabolism, :x, :metabolicrate]
        if length(parameters_tuple) != 0
            pt = parameters_tuple[:parameters_tuple]
            exponential_BA_x(passed_temp_parameters = parameters_tuple)
        else
            exponential_BA_x()
        end
    elseif rate_affected == :functionalresponse
        if length(parameters_tuple) != 0
            pt = parameters_tuple[:parameters_tuple]
            exponential_BA_functionalr(passed_temp_parameters = parameters_tuple)
        else
            exponential_BA_functionalr()
        end
    end
end

"""
Extended Boltzmann-Arrhenius
TODO
"""

function ExtendedBA(rate_affected::Symbol; parameters_tuple...)
    if rate_affected ∉ [:growth, :r, :metabolism, :x, :attackrate]
        error("rate_affected should be eighter :growth (alternatively :r or :growthrate), :metabolism (alternatively :x or :metabolicrate), or :attackrate")
    end
    if rate_affected ∈ [:growth, :r, :growthrate]
        if length(parameters_tuple) != 0
            pt = parameters_tuple[:parameters_tuple]
            extended_BA_r(passed_temp_parameters = parameters_tuple)
        else
            extended_BA_r()
        end
    elseif rate_affected ∈ [:metabolism, :x, :metabolicrate]
        if length(parameters_tuple) != 0
            pt = parameters_tuple[:parameters_tuple]
            extended_BA_x(passed_temp_parameters = parameters_tuple)
        else
            extended_BA_x()
        end
    elseif rate_affected == :attackrate
        if length(parameters_tuple) != 0
            pt = parameters_tuple[:parameters_tuple]
            extended_BA_attackr(passed_temp_parameters = parameters_tuple)
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
        error("rate_affected should be eighter :growth (alternatively :r or :growthrate), :metabolism (alternatively :x or :metabolicrate) or :functionalresponse")
    end
    if rate_affected ∈ [:growth, :r, :growthrate]
        if length(parameters_tuple) != 0
            pt = parameters_tuple[:parameters_tuple]
            gaussian_r(passed_temp_parameters = parameters_tuple)
        else
            gaussian_r()
        end
    elseif rate_affected ∈ [:metabolism, :x, :metabolicrate]
        if length(parameters_tuple) != 0
            pt = parameters_tuple[:parameters_tuple]
            gaussian_x(passed_temp_parameters = parameters_tuple)
        else
            gaussian_x()
        end
    elseif rate_affected == :functionalresponse
        if length(parameters_tuple) != 0
            pt = parameters_tuple[:parameters_tuple]
            gaussian_functionalr(passed_temp_parameters = parameters_tuple)
        else
            gaussian_functionalr()
        end
    end
end
