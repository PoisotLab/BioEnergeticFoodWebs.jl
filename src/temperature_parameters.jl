"""
**Define parameters of thermal dependence functions**

We included different functions of temperature dependence : 1) Extended Eppley function
                                                            2) Quadratic function
                                                            3) Exponential Boltzmann-Arrhenius function
                                                            4) Extended Boltzmann-Arrhenius function (Johnson-Lewin)
                                                            5) Gaussian (inverted Gaussian) function

Here we define the parameters for each of these functions

"""

"""
**Option 1 : Extended Eppley function**

| Parameter | Meaning                                                           |
|:----------|:------------------------------------------------------------------|
| temp      | temperature (Celsius degree)                                      |
| a         | parameter from the Eppley curve for the growth phase              |
| b         | parameter from the Eppley curve for the growth phase              |
| z         | location of the maximum of the quadratic portion of the function  |
| w         | thermal breadth                                                   |

"""

a=Array{Float64,1}(S)
