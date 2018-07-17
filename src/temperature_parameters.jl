#=
**Define parameters of thermal dependence functions**

We included different functions of temperature dependence : 1) Extended Eppley function
                                                            2) Quadratic function
                                                            3) Exponential Boltzmann-Arrhenius function
                                                            4) Extended Boltzmann-Arrhenius function (Johnson-Lewin)
                                                            5) Gaussian (inverted Gaussian) function

Here we define the parameters for each of these functions

=#

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

p0_metabolicRate_producer=2e10
p0_metabolicRate_herbivore=2e10
p0_metabolicRate_carnivore=2e10

p0_metabolicRate=zeros(S)
p0_metabolicRate[p[:is_producer]]=p0_metabolicRate_producer
p0_metabolicRate[p[:is_herbivore]]=p0_metabolicRate_herbivore
p0_metabolicRate[(.!p[:is_herbivore]) .& (.!p[:is_producer])]=p0_metabolicRate_carnivore

E_metabolicRate_producer=0.65
E_metabolicRate_herbivore=0.65
E_metabolicRate_carnivore=0.65

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

p0_growthRate=-15.68
E_growthRate=-0.31
beta_growthRate=-0.25

p0_growthRate_producer=repmat([p0_growthRate],length(p[:is_producer]))
E_growthRate_producer=repmat([E_growthRate],length(p[:is_producer]))
beta_growthRate_producer=repmat([beta_growthRate],length(p[:is_producer]))

# Functional response

# Attack rate

p0_attackRate_herbivore=-13.1
p0_attackRate_carnivore=-13.1

p0_attackRate=zeros(S)

p0_attackRate[p[:is_herbivore]]=p0_attackRate_herbivore
p0_attackRate[(.!p[:is_herbivore]) .& (.!p[:is_producer])]=p0_attackRate_carnivore

E_attackRate_herbivore=-0.38
E_attackRate_carnivore=-0.38

E_attackRate=zeros(S)

E_attackRate[p[:is_herbivore]]=E_attackRate_herbivore
E_attackRate[(.!p[:is_herbivore]) .& (.!p[:is_producer])]=E_attackRate_carnivore

beta_attackRate_herbivore=0.25
beta_attackRate_carnivore=0.25

beta_attackRate=zeros(S)

beta_attackRate[p[:is_herbivore]]=beta_attackRate_herbivore
beta_attackRate[(.!p[:is_herbivore]) .& (.!p[:is_producer])]=beta_attackRate_carnivore

# Handling time

p0_handlingTime_herbivore=9.66
p0_handlingTime_carnivore=9.66

p0_handlingTime=zeros(S)
p0_handlingTime[p[:is_herbivore]]=p0_handlingTime_herbivore
p0_handlingTime[(.!p[:is_herbivore]) .& (.!p[:is_producer])]=p0_handlingTime_carnivore

E_handlingTime_herbivore=0.26
E_handlingTime_carnivore=0.26

E_handlingTime=zeros(S)
E_handlingTime[p[:is_herbivore]]=E_handlingTime_herbivore
E_handlingTime[(.!p[:is_herbivore]) .& (.!p[:is_producer])]=E_handlingTime_carnivore

beta_handlingTime_herbivore=-0.45
beta_handlingTime_carnivore=-0.45

beta_handlingTime=zeros(S)

beta_handlingTime[p[:is_herbivore]]=beta_handlingTime_herbivore
beta_handlingTime[(.!p[:is_herbivore]) .& (.!p[:is_producer])]=beta_handlingTime_carnivore

para_exponential_BA_r = hcat(p0_metabolicRate, E_metabolicRate, beta_metabolicRate)
