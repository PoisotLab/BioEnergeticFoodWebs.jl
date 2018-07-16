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

"""
**Option 3 : Exponential Boltzmann-Arrhenius function**

| Parameter     | Meaning                               |
|:--------------|:--------------------------------------|
| temp          | temperature range (Kelvin)            |
| p0            | scaling coefficient                   |
| E             | activation energy                     |
| p[:bodymass]  | body mass                             |
| beta          | allometric exponent                   |
| k             | Boltzmann constant (k=8.617e-5)       |

Parameters are for instance:

p0=0.2e11
E=0.65
m=1
beta=-0.25

"""

# Metabolic rate

p0_metabolicRate_producer=-16.54
p0_metabolicRate_herbivore=-16.54
p0_metabolicRate_carnivore=-16.54

p0_metabolicRate=zeros(S)
p0_metabolicRate[p[:is_producer]]=p0_metabolicRate_producer
p0_metabolicRate[p[:is_herbivore]]=p0_metabolicRate_herbivore
p0_metabolicRate[(.!p[:is_herbivore]) .& (.!p[:is_producer])]=p0_metabolicRate_carnivore

E_metabolicRate_producer=-0.69
E_metabolicRate_herbivore=-0.69
E_metabolicRate_carnivore=-0.69

E_metabolicRate=zeros(S)
E_metabolicRate[p[:is_producer]]=E_metabolicRate_producer
E_metabolicRate[p[:is_herbivore]]=E_metabolicRate_herbivore
E_metabolicRate[(.!p[:is_herbivore]) .& (.!p[:is_producer])]=E_metabolicRate_carnivore

beta_metabolicRate_producer=-0.31
beta_metabolicRate_herbivore=-0.31
beta_metabolicRate_carnivore=-0.31

beta_metabolicRate=zeros(S)

beta_metabolicRate[p[:is_producer]]=beta_metabolicRate_producer
beta_metabolicRate[p[:is_herbivore]]=beta_metabolicRate_herbivore
beta_metabolicRate[(.!p[:is_herbivore]) .& (.!p[:is_producer])]=beta_metabolicRate_carnivore

# Growth rate

# Functional response
