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
        #TODO @assert ...
        isdefined(:parameters_tuple) ? no_effect_r(T_param = parameters_tuple) : no_effect_r()
    elseif rate_affected ∈ [:metabolism, :x, :metabolicrate]
        #TODO @assert ...
        isdefined(:parameters_tuple) ? no_effect_x(T_param = parameters_tuple) : no_effect_x()
    elseif rate_affected == :handlingtime
        #TODO @assert ...
        isdefined(:parameters_tuple) ? no_effect_handlingt(T_param = parameters_tuple) : no_effect_handlingt()
    elseif rate_affected == :attackrate
        #TODO @assert ...
        isdefined(:parameters_tuple) ? no_effect_attackr(T_param = parameters_tuple) : no_effect_attackr()
    end
end

"""
Extended Eppley
TODO
"""

function ExtendedEppley(rate_affected::Symbol; parameters_tuple...)
    if rate_affected ∉ [:growth, :r, :metabolism, :x] ; error("rate_affected should be eighter :growth (alternatively :r or :growthrate) or :metabolism (alternatively :x or :metabolicrate)") ; end
    if rate_affected ∈ [:growth, :r, :growthrate]
        #TODO @assert ...
        isdefined(:parameters_tuple) ? check_temperature_parameters(string(extended_eppley_r), parameters_tuple) : extended_eppley_r()
        isdefined(:parameters_tuple) ? extended_eppley_r(T_param = parameters_tuple) : extended_eppley_r()
    elseif rate_affected ∈ [:metabolism, :x, :metabolicrate]
        #TODO @assert ...
        isdefined(:parameters_tuple) ? extended_eppley_x(T_param = parameters_tuple) : extended_eppley_x()
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
        #TODO @assert ...
        isdefined(:parameters_tuple) ? exponential_BA_r(T_param = parameters_tuple) : exponential_BA_r()
    elseif rate_affected ∈ [:metabolism, :x, :metabolicrate]
        #TODO @assert ...
        isdefined(:parameters_tuple) ? exponential_BA_x(T_param = parameters_tuple) : exponential_BA_x()
    elseif rate_affected == :functionalresponse
        #TODO @assert ...
        isdefined(:parameters_tuple) ? exponential_BA_functionalr(T_param = parameters_tuple) : exponential_BA_functionalr()
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
        #TODO @assert ...
        isdefined(:parameters_tuple) ? extended_BA_r(T_param = parameters_tuple) : extended_BA_r()
    elseif rate_affected ∈ [:metabolism, :x, :metabolicrate]
        #TODO @assert ...
        isdefined(:parameters_tuple) ? extended_BA_x(T_param = parameters_tuple) : extended_BA_x()
    elseif rate_affected == :attackrate
        #TODO @assert ...
        isdefined(:parameters_tuple) ? extended_BA_attackr(T_param = parameters_tuple) : extended_BA_attackr()
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
        #TODO @assert ...
        isdefined(:parameters_tuple) ? gaussian_r(T_param = parameters_tuple) : gaussian_r()
    elseif rate_affected ∈ [:metabolism, :x, :metabolicrate]
        #TODO @assert ...
        isdefined(:parameters_tuple) ? gaussian_x(T_param = parameters_tuple) : gaussian_x()
    elseif rate_affected == :functionalresponse
        #TODO @assert ...
        isdefined(:parameters_tuple) ? gaussian_functionalr(T_param = parameters_tuple) : gaussian_functionalr()
    end
end
