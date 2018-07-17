"""
**Functions of thermal performance curve for model parameters**

We included different functions of temperature dependence : 1) Extended Eppley function
                                                            2) Quadratic function
                                                            3) Exponential Boltzmann-Arrhenius function
                                                            4) Extended Boltzmann-Arrhenius function (Johnson-Lewin)
                                                            5) Gaussian (inverted Gaussian) function

In each case, the function returns the biological rate value at a given temperature.

"""

"""

**Option 1 : Extended Eppley function**

| Parameter    | Meaning                                                           |
|:-------------|:------------------------------------------------------------------|
| temp         | temperature range (Celsius degree)                                |
| a            | parameter from the Eppley curve for the growth phase              |
| b            | parameter from the Eppley curve for the growth phase              |
| z            | location of the maximum of the quadratic portion of the function  |
| w            | thermal breadth                                                   |
| p[:bodymass] | body mass                                                         |
| beta         | allometric exponent                                               |


No temperature effect :

a=1
b=0
z=18
w=35
p[:bodymass]=1
beta=-0.25

To account for a temperature effect, the parameters are for instance :
    a=0.81
    b=0.0631 (parameters from the Eppley curve)
    z=18
    w=35
    p[:bodymass]=1
    beta=-0.25
"""

function extended_eppley(para_extended_eppley, T, p)
    temp=para_extended_eppley[1]
    a=para_extended_eppley[2]
    b=para_extended_eppley[3]
    z=para_extended_eppley[4]
    w=para_extended_eppley[5]
    beta=para_extended_eppley[6]

    return p[:bodymass]^beta*a.*exp.(b.*temp).*(1-((temp-z)./(w/2)).^2)

end

# """
# **Option 2 : Quadratic function**
#
# | Parameter    | Meaning                                                                                  |
# |:-------------|:-----------------------------------------------------------------------------------------|
# | temp         | temperature range (Kelvin)                                                               |
# | b            | fitted parameter from Englund et al (2011), determines the shape of the thermal response |
# | q            | fitted parameter from Englund et al (2011), determines the shape of the thermal response |
# | c            | fitted parameter from Englund et al (2011)                                               |
# | p[:bodymass] | body mass                                                                                |
# | beta         | allometric exponent                                                                      |
# | k            | Boltzmann constant (k=8.617e-5)                                                          |                                                            |
#
# Parameters are for instance (parametrization to revise):
#
# c=0.2
# q=-0.5
# b=-1.6537077869328072e6
# p[:bodymass]=1
# beta=-0.25
# """
#
# function quadratic(para_quadratic)
#     temp=para_quadratic[1]
#     c=para_quadratic[2]
#     b=para_quadratic[3]
#     q=para_quadratic[4]
#     beta=para_quadratic[5]
#     k=8.617e-5
#     return p[:bodymass]^beta*c*exp(b*(-1/k*temp)+q*(-1/k*temp)^2)
#
# end

"""
**Option 3 : Exponential Boltzmann-Arrhenius function**

| Parameter    | Meaning                               |
|:-------------|:--------------------------------------|
| temp         | temperature range (Kelvin)            |
| p0           | scaling coefficient                   |
| E            | activation energy                     |
| p[:bodymass] | body mass                             |
| beta         | allometric exponent                   |
| k            | Boltzmann constant (k=8.617e-5)       |

Parameters are for instance:

p0=0.2e11
E=0.65
m=1
beta=-0.25

"""

function exponential_BA(para_exponential_BA, temp,p;direction=:increase)
    p0=para_exponential_BA[1]
    E=para_exponential_BA[2]
    beta=para_exponential_BA[3]
    k=8.617e-5 # Boltzmann constant

    if direction==:increase
        return p0.*((p[:bodymass].^beta).*exp.(-E./(k*temp)))
    elseif direction==:decrease
        return p0.*((p[:bodymass].^beta).*exp.(E./(k*temp)))
    else
        error("Direction should one of :increase or :decrease")
    end
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
Ed=0.72
topt=295
p[:bodymass]=1
beta=-0.25


"""

function extended_BA(para_extended_BA, temp, p)
    temp=para_extended_BA[1]
    p0=para_extended_BA[2]
    E=para_extended_BA[3]
    Ed=para_extended_BA[4]
    topt=para_extended_BA[5]
    beta=para_extended_BA[6]
    k=8.617e-5 # Boltzmann constant
                                             |

    lT=1/(1+exp(-1/(k*temp)*(Ed-(Ed/topt+k*log(E/(Ed-E)))*temp)))
    return p0*p[:bodymass]^beta*exp(-E/(k*temp))*lT

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

function gaussian(para_gaussian, temp, p; shape = :hump)
    p0=para_gaussian[1]
    s=para_gaussian[2]
    topt=para_gaussian[3]
    beta=para_gaussian[4]

    if shape = :hump
        return p[:bodymass].^beta.*p0.*exp.(-(temp-topt)^2/(2*s^2))
    elseif shape = :U
        return  p[:bodymass].^beta.*p0.*exp.((temp-topt)^2/(2*s^2))
    end
end

"""
**TODO**
"""

function temperature_parameters(T::Float64, handlingtime_fun::Symbol, metabolicrate_fun::Symbol, growthrate_fun::Symbol, handlingtime_fun::Symbol, parameters::Dict{Symbol, Any} ; direction = :increase, shape = :hump)

    @assert shape ∈ [:U, :hump]
    @assert direction ∈ [:increase, :decrease]
    # TODO assert
    # TODO assert
    # TODO assert
    # TODO assert

    TC = T-273.15
    TK = T

    E_BA_a = 0.65
    E_BA_x = 0.65
    E_BA_r = 0.65
    E_BA_h = 0.65

    p0_BA_a = 0.2e11
    p0_BA_x = 0.2e11
    p0_BA_r = 0.2e11
    p0_BA_h = 0.2e11

    β_a = -0.25
    β_x = -0.25
    β_r = -0.25
    β_h = -0.25

    a_eppley_a = 0.81
    a_eppley_x = 0.81
    a_eppley_r = 0.81
    a_eppley_h = 0.81

    b_eppley_a = 0.0631
    b_eppley_x = 0.0631
    b_eppley_r = 0.0631
    b_eppley_h = 0.0631

    z_eppley_a = 18
    z_eppley_x = 18
    z_eppley_r = 18
    z_eppley_h = 18

    w_eppley_a = 35
    w_eppley_x = 35
    w_eppley_r = 35
    w_eppley_h = 35

    # b_quad_a = -1.65
    # b_quad_x = -1.65
    # b_quad_r = -1.65
    # b_quad_h = -1.65
    #
    # q_quad_a
    # q_quad_x
    # q_quad_r
    # q_quad_h
    #
    # c_quad_a
    # c_quad_x
    # c_quad_r
    # c_quad_h

    p0_gauss_a = 0.5
    p0_gauss_x = 0.5
    p0_gauss_r = 0.5
    p0_gauss_h = 0.5

    s_gauss_a = 20
    s_gauss_x = 20
    s_gauss_r = 20
    s_gauss_h = 20

    topt_a = 295
    topt_x = 295
    topt_r = 295
    topt_h = 295

    p0_extBA_a = 0.2e12
    p0_extBA_x = 0.2e12
    p0_extBA_r = 0.2e12
    p0_extBA_h = 0.2e12

    E_extBA_a = 0.65
    E_extBA_x = 0.65
    E_extBA_r = 0.65
    E_extBA_h = 0.65

    Ed_extBA_a = 0.72
    Ed_extBA_x = 0.72
    Ed_extBA_r = 0.72
    Ed_extBA_h = 0.72

    if handlingtime_fun == :BAexp
        par = [p0_BA_a, E_BA_a, β_a]
        a = exponential_BA(par, TK, p; direction = direction)
    elseif handlingtime_fun == :BAext
        par = [p0_extBA_a, E_extBA_a, Ed_extBA_a, topt_a, β_a]
        a = extended_BA(par, TK, p)
    elseif handlingtime_fun == :gauss
        par = [p0_gauss_a, s_gauss_a, topt_a, β_a]
        a = gaussian(par, TC, p; shape = shape)
    elseif handlingtime_fun == :eppley
        par = [a_eppley_a, b_eppley_a, z_eppley_a, w_eppley_a, β_a]
        a = gaussian(par, TC, p)
    else
        error("handlingtime_fun should be one of :BAexp, :BAext, :gauss or :eppley")
    end

    if metabolicrate_fun == :BAexp
        par = [p0_BA_x, E_BA_x, β_x]
        a = exponential_BA(par, TK, p; direction = direction)
    elseif metabolicrate_fun == :BAext
        par = [p0_extBA_x, E_extBA_x, Ed_extBA_x, topt_x, β_x]
        a = extended_BA(par, TK, p)
    elseif metabolicrate_fun == :gauss
        par = [p0_gauss_x, s_gauss_x, topt_x, β_x]
        a = gaussian(par, TC, p; shape = shape)
    elseif metabolicrate_fun == :eppley
        par = [a_eppley_x, b_eppley_x, z_eppley_x, w_eppley_x, β_x]
        a = gaussian(par, TC, p)
    else
        error("metabolicrate_fun should be one of :BAexp, :BAext, :gauss or :eppley")
    end

    if growthrate_fun == :BAexp
        par = [p0_BA_r, E_BA_r, β_r]
        a = exponential_BA(par, TK, p; direction = direction)
    elseif growthrate_fun == :BAext
        par = [p0_extBA_r, E_extBA_r, Ed_extBA_r, topt_r, β_r]
        a = extended_BA(par, TK, p)
    elseif growthrate_fun == :gauss
        par = [p0_gauss_r, s_gauss_r, topt_r, β_r]
        a = gaussian(par, TC, p; shape = shape)
    elseif growthrate_fun == :eppley
        par = [a_eppley_r, b_eppley_r, z_eppley_r, w_eppley_r, β_r]
        a = gaussian(par, TC, p)
    else
        error("growthrate_fun should be one of :BAexp, :BAext, :gauss or :eppley")
    end

    if handlingtime_fun == :BAexp
        par = [p0_BA_h, E_BA_h, β_h]
        a = exponential_BA(par, TK, p; direction = direction)
    elseif handlingtime_fun == :BAext
        par = [p0_extBA_h, E_extBA_h, Ed_extBA_h, topt_h, β_h]
        a = extended_BA(par, TK, p)
    elseif handlingtime_fun == :gauss
        par = [p0_gauss_h, s_gauss_h, topt_h, β_h]
        a = gaussian(par, TC, p; shape = shape)
    elseif handlingtime_fun == :eppley
        par = [a_eppley_h, b_eppley_h, z_eppley_h, w_eppley_h, β_h]
        a = gaussian(par, TC, p)
    else
        error("handlingtime_fun should be one of :BAexp, :BAext, :gauss or :eppley")
    end

end
