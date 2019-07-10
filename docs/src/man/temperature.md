# Temperature dependence

Both organisms biological rates and body sizes can be set to be temperature dependent, using respectively different temperature dependence functions for biological rates and different temperature size rules for body sizes. This effect of temperature can be integrated in the bioenergetic model using one of the functions described below. However, note **that these functions should only be used when the user has a good understanding of the system modelled** as some functions, under certain conditions, can lead to an erratic behavior of the bioenergetic model (instability, negative rates, etc.).

## Temperature dependence for biological rates

The default behavior of the model will always be to assume that none of the biological rates are affected by temperature. If you wish to implement temperature dependence however, you can use one of the following functions:

- extended Eppley function (Bernhardt et al., 2018)
- exponential Boltzmann Arrhenius function
- extended Boltzmann Arrhenius function
- Gaussian function

These functions determine the shape of the thermal curves used to scale the biological rates with temperature.

*Nota* The exponential Boltzmann Arrhenius function is the most documented in the litterature, hence parameters have been measured for the different biological rates (conversely to other functions that are less used, or more specific to a type of organism). We thus encourage to choose the Boltzmann Arrhenius function when using the default parameters provided in the package, as parameters are better supported in the litterature.

### General example

Each of the biological rates (growth, metabolism, attack rate and handling time) is defined as a keyword in `model_parameters`. Simply specify the function you want to use as the corresponding value (and the temperature of the system in degrees Kelvin):

```julia
A = [0 1 0 ; 0 0 1 ; 0 0 0]
p = model_parameters(A, T = 290.0,
                     growthrate = ExtendedEppley(:growth),
                     metabolicrate = Gaussian(:metabolism),
                     handlingtime = ExponentialBA(:handlingtime),
                     attackrate = ExtendedBA(:attackrate))
```

### Extended Eppley

Note that rates can be negative (outside of the thermal range) when using the extended Eppley function.

Bernhardt et al. (2018) proposed an extension of the original model of Eppley (1972). Following this extension the thermal performance curve of rate $q_i$ of species $i$ is defined by the equation:

$q_i(T) = M_i^\beta * m0 * exp(b * T) * (1 - (\frac{T - T_{\text{opt}}}{\text{range}/2})^2)$

Where $M_i$ is the body mass of species $i$ and T is the temperature in degrees Kelvin. The default parameters values are described for each rate below.

Note that this function has originially been documented for phytoplankton growth rate in Eppley 1972. Although its shape is general and may be used for other organisms, parameters should be changed accordingly.

#### Growth rate

For the growth rate, the parameters values are set to:

| Parameter      | Keyword           | Meaning                                                   | Default values | References           |
| -------------- | ----------------- | --------------------------------------------------------- | -------------- | -------------------- |
| $β$            | `β`               | allometric exponent                                       | -0.25          | Gillooly et al. 2002 |
| $m0$           | `maxrate_0`       | maximum growth rate observed at 273.15 K                  | 0.81           | Eppley 1972          |
| $b$            | `eppley_exponent` | exponential rate of increase                              | 0.0631         | Eppley 1972          |
| $z$            | `z`               | location of the inflexion point of the function           | 298.15         | NA                   |
| $\text{range}$ | `range`           | thermal breadth (range within which the rate is positive) | 35             | NA                   |

To use this function, initialize `model_parameters()` with `ExtendedEppley(:growthrate)` for the keyword `growthrate`:

```julia
A = [0 1 0 ; 0 0 1 ; 0 0 0] #linear food chain
p = model_parameters(A, growthrate = ExtendedEppley(:growthrate), T = 290.0) #default parameters values
# change the parameters values for the allometric exponent using a named tuple
p_newvalues = model_parameters(A, growthrate = ExtendedEppley(:growthrate, parameters_tuple = (β = -0.21,)), T = 290.0)
```

#### Metabolic rate

We use the same function as above for the metabolic rate, with the added possibility to have different parameters values for producers, vertebrates and invertebrates. The defaults are initially set to the same values for all metabolic types (see table above), but can be changed independently (see example below).


```julia
A = [0 1 0 ; 0 0 1 ; 0 0 0] #linear food chain
p = model_parameters(A, metabolicrate = ExtendedEppley(:metabolicrate), T = 290.0) #default parameters values
# change the parameters values for the allometric exponent using a named tuple
p_newvalues = model_parameters(A, metabolicrate = ExtendedEppley(:metabolicrate, parameters_tuple = (range_producer = 30, range_invertebrate = 40, range_vertebrate = 25)), T = 290.0)
```

### Exponential Boltzmann Arrhenius

The Boltzmann Arrhenius model, following the Metabolic Theory in Ecology, describes the scaling of a biological rate ($q$) with temperature by:

$q_i(T) = q_0 * M^\beta_i * exp(E-\frac{T_0 - T}{kT_0T})$

Where $q_0$ is the organisms state-dependent scaling coefficient, calculated for 1g at 20 degrees Celsius (273.15 degrees Kelvin), β is the rate specific allometric scaling exponent, $E$ is the activation energy in $eV$ (electronvolts) of the response, $T_0$ is the normalization temperature and $k$ is the Boltzmann constant ($8.617 10^{-5} eV.K^{-1}$). As for all other equations, $T$ is the temperature and $M_i$ is the typical adult body mass of species $i$.

*Nota* In many papers, the **logarithm** of the scaling constant $q_0$ is provided. When using those parameters, you should then give the **exponential** of $q_0$ (exp($q_0$)) in the parameters.

#### Growth rate

For the growth rate, the parameters values are set to:

| Parameter | Keyword             | Meaning                              | Default values | References                             |
| --------- | ------------------- | ------------------------------------ | -------------- | -------------------------------------- |
| $r_0$     | `norm_constant`     | growth dependent scaling coefficient | -exp(15.68)    | Savage et al. 2004, Binzer et al. 2012 |
| $\beta_i$ | `β`                 | allometric exponent                  | -0.25          | Savage et al. 2004, Binzer et al. 2012 |
| $E$       | `activation_energy` | activation energy                    | -0.84          | Savage et al. 2004, Binzer et al. 2012 |
| $T_0$     | `T0`                | normalization temperature (Kelvins)  | 293.15         | Binzer et al. 2012                     |

To use this function, initialize `model_parameters()` with `ExponentialBA(:growthrate)` for the keyword `growthrate`:

```julia
A = [0 1 0 ; 0 0 1 ; 0 0 0] #linear food chain
p = model_parameters(A, growthrate = ExponentialBA(:growthrate), T = 290.0) #default parameters values
# change the parameters values for the allometric exponent using a named tuple
p_newvalues = model_parameters(A, growthrate = ExponentialBA(:growthrate, parameters_tuple = (β = -0.21,)), T = 290.0)
```

#### Metabolic rate

For the metabolic rate, the parameters values can be different for each metabolic types (producers, invertebrates and vertebrates). The defaults are initially set to the same value for all metabolic types (see table below), but can be changed independently (see example below).

For the metabolic rate, the parameters values are set to:


| Parameter | Keyword                          | Meaning                              | Default values | References                            |
| --------- | -------------------------------- | ------------------------------------ | -------------- | ------------------------------------- |
| $r_0$     | `norm_constant_invertebrate`     | growth dependent scaling coefficient | -exp(16.54)    | Ehnes et al. 2011, Binzer et al. 2012 |
| $r_0$     | `norm_constant_vertebrate`       | growth dependent scaling coefficient | -exp(16.54)    | Ehnes et al. 2011, Binzer et al. 2012 |
| $\beta_i$ | `β_invertebrate`                 | allometric exponent                  | -0.31          | Ehnes et al. 2011                     |
| $\beta_i$ | `β_vertebrate`                   | allometric exponent                  | -0.31          | Ehnes et al. 2011                     |
| $E$       | `activation_energy_invertebrate` | activation energy                    | -0.69          | Ehnes et al. 2011, Binzer et al. 2012 |
| $E$       | `activation_energy_vertebrate`   | activation energy                    | -0.69          | Ehnes et al. 2011, Binzer et al. 2012 |
| $T_0$     | `T0_invertebrate`                | normalization temperature (Kelvins)  | 293.15         | Binzer et al. 2012                    |
| $T_0$     | `T0_vertebrate`                  | normalization temperature (Kelvins)  | 293.15         | Binzer et al. 2012                    |

```julia
A = [0 1 0 ; 0 0 1 ; 0 0 0] #linear food chain
p = model_parameters(A, metabolicrate = ExponentialBA(:metabolicrate), T = 290.0) #default parameters values
# change the parameters values for the allometric exponent using a named tuple
p_newvalues = model_parameters(A, metabolicrate = ExponentialBA(:metabolicrate, parameters_tuple = (T0_producer = 293.15, T0_invertebrate = 300.15, T0_vertebrate = 300.15)), T = 290.0)
```

#### Attack rate

The attack rate is defined not for each species but for each interacting pair. As such, the body-mass scaling depends on the masses of both the consumer and its resource and the allometric exponent can be different for producers, vertebrates and invertebrates. However, the temperature scaling affects only the consumers, thus, the parameters involved can be defined differently only for vertebrates and invertebrates. For more details, see the table below.

Note: The body-mass allometric scaling (originally defined as $M_i^\beta$) becomes $M_{j}^{\beta_{j}} * M_{k}^{\beta_{k}}$ where $j$ is the consumer and $k$ its resource.

| Parameter | Keyword                          | Meaning                              | Default values | References                           |
| --------- | -------------------------------- | ------------------------------------ | -------------- | ------------------------------------ |
| $r_0$     | `norm_constant_invertebrate`     | growth dependent scaling coefficient | -exp(13.1)     | Rall et al. 2012, Binzer et al. 2016 |
| $r_0$     | `norm_constant_vertebrate`       | growth dependent scaling coefficient | -exp(13.1)     | Rall et al. 2012, Binzer et al. 2016 |
| $\beta_i$ | `β_producer`                     | allometric exponent                  | 0.25           | Rall et al. 2012, Binzer et al. 2016 |
| $\beta_i$ | `β_invertebrate`                 | allometric exponent                  | -0.8           | Rall et al. 2012, Binzer et al. 2016 |
| $\beta_i$ | `β_vertebrate`                   | allometric exponent                  | -0.8           | Rall et al. 2012, Binzer et al. 2016 |
| $E$       | `activation_energy_invertebrate` | activation energy                    | -0.38          | Rall et al. 2012, Binzer et al. 2016 |
| $E$       | `activation_energy_vertebrate`   | activation energy                    | -0.38          | Rall et al. 2012, Binzer et al. 2016 |
| $T_0$     | `T0_invertebrate`                | normalization temperature (Kelvins)  | 293.15         | Rall et al. 2012, Binzer et al. 2016 |
| $T_0$     | `T0_vertebrate`                  | normalization temperature (Kelvins)  | 293.15         | Rall et al. 2012, Binzer et al. 2016 |

To use this function, initialize `model_parameters()` with `ExponentialBA(:attackrate)` for the keyword `attackrate`:

```julia
A = [0 1 0 ; 0 0 1 ; 0 0 0] #linear food chain
p = model_parameters(A, attackrate = ExponentialBA(:attackrate), T = 290.0) #default parameters values
# change the parameters values for the allometric exponent using a named tuple
p_newvalues = model_parameters(A, attackrate = ExponentialBA(:attackrate, parameters_tuple = (T0_invertebrate = 300.15, T0_vertebrate = 300.15)), T = 290.0)
```

#### Handling time

The handling time is defined not for each species but for each interacting pair. As such, the body-mass scaling depends on the masses of both the consumer and its resource and the allometric exponent can be different for producers, vertebrates and invertebrates. However, the temperature scaling affects only the consumers, thus, the parameters involved can be defined differently only for vertebrates and invertebrates. For more details, see the table below.

Note: The body-mass allometric scaling (originally defined as $M_i^\beta$) becomes $M_{j}^{\beta_{j}} * M_{k}^{\beta_{k}}$ where $j$ is the consumer and $k$ its resource.

| Parameter | Keyword                          | Meaning                              | Default values | References                           |
| --------- | -------------------------------- | ------------------------------------ | -------------- | ------------------------------------ |
| $r_0$     | `norm_constant_invertebrate`     | growth dependent scaling coefficient | exp(9.66)      | Rall et al. 2012, Binzer et al. 2016 |
| $r_0$     | `norm_constant_vertebrate`       | growth dependent scaling coefficient | exp(9.66)      | Rall et al. 2012, Binzer et al. 2016 |
| $\beta_i$ | `β_producer`                     | allometric exponent                  | -0.45          | Rall et al. 2012, Binzer et al. 2016 |
| $\beta_i$ | `β_invertebrate`                 | allometric exponent                  | 0.47           | Rall et al. 2012, Binzer et al. 2016 |
| $\beta_i$ | `β_vertebrate`                   | allometric exponent                  | 0.47           | Rall et al. 2012, Binzer et al. 2016 |
| $E$       | `activation_energy_invertebrate` | activation energy                    | 0.26           | Rall et al. 2012, Binzer et al. 2016 |
| $E$       | `activation_energy_vertebrate`   | activation energy                    | 0.26           | Rall et al. 2012, Binzer et al. 2016 |
| $T_0$     | `T0_invertebrate`                | normalization temperature (Kelvins)  | 293.15         | Rall et al. 2012, Binzer et al. 2016 |
| $T_0$     | `T0_vertebrate`                  | normalization temperature (Kelvins)  | 293.15         | Rall et al. 2012, Binzer et al. 2016 |

To use this function, initialize `model_parameters()` with `ExponentialBA(:handlingtime)` for the keyword `handlingtime`:

```julia
A = [0 1 0 ; 0 0 1 ; 0 0 0] #linear food chain
p = model_parameters(A, handlingtime = ExponentialBA(:handlingtime), T = 290.0) #default parameters values
# change the parameters values for the allometric exponent using a named tuple
p_newvalues = model_parameters(A, handlingtime = ExponentialBA(:handlingtime, parameters_tuple = (T0_vertebrate = 300.15, β_producer = -0.25)), T = 290.0)
```

### Extended Boltzmann Arrhenius

To describe a more classical unimodal relationship of biological rates with temperature, one can also use the **extended** Boltzmann Arrhenius function. This is an extension based on the Johnson and Lewin model to describe the decrease in biological rates at higher temperatures (and is still based on chemical reaction kinetics).

$q_i(T) = exp(q_0) * M^\beta_i * exp(\frac{E}{kT * l(T)})$

Where $l(T)$ is :

$l(T) = \frac{1}{1 + exp[\frac{-1}{kT} + (\frac{E_D}{T_{opt}} + k * ln(\frac{E}{E_D - E}))]}$

#### Growth rate

For the growth rate, the parameters values are set to:

| Parameter | Keyword               | Meaning                                               | Default values       | References           |
| --------- | --------------------- | ----------------------------------------------------- | ------------------------ | -------------------- |
| $r_0$     | `norm_constant`       | growth dependent scaling coefficient                  | $1.8*10^9$     | NA     |
| $\beta_i$ | `β`                   | allometric exponent                                   | -0.25         | Gillooly et al. 2002 |
| $E$       | `activation_energy`   | activation energy                                     | 0.53         | Dell et al 2011      |
| $T_opt$   | `T_opt`               | temperature at which trait value is maximal (Kelvins) | 298.15       | NA                   |
| $E_D$     | `deactivation_energy` | deactivation energy                                   | 1.15         | Dell et al 2011      |

To use this function, initialize `model_parameters()` with `ExtendedBA(:growthrate)` for the keyword `growthrate`:

```julia
A = [0 1 0 ; 0 0 1 ; 0 0 0] #linear food chain
p = model_parameters(A, growthrate = ExtendedBA(:growthrate), T = 290.0) #default parameters values
# change the parameters values for the allometric exponent using a named tuple
p_newvalues = model_parameters(A, growthrate = ExtendedBA(:growthrate, parameters_tuple = (T_opt = 300.15, )), T = 290.0)
```

#### Metabolic rate

For the metabolic rate, the parameters values can be different for each metabolic types (producers, invertebrates and vertebrates). The defaults are initially set to the same value for all metabolic types, but can be changed independently (see example below).

For the metabolic rate, the parameters values are set to:

| Parameter | Keyword                            | Meaning                                                           | Default values | References           |
| --------- | ---------------------------------- | ----------------------------------------------------------------- | -------------- | -------------------- |
| $r_0$     | `norm_constant_producer`           | growth dependent scaling coefficient for producers                | $1.5*10^9$     | NA                   |
| $r_0$     | `norm_constant_invertebrate`       | growth dependent scaling coefficient for invertebrates            | $1.5*10^9$     | NA                   |
| $r_0$     | `norm_constant_vertebrate`         | growth dependent scaling coefficient for vertebrates              | $1.5*10^9$     | NA                   |
| $\beta_i$ | `β_producer`                       | allometric exponent for producers                                 | -0.25          | Gillooly et al. 2002 |
| $\beta_i$ | `β_invertebrate`                   | allometric exponent for invertebrates                             | -0.25          | Gillooly et al. 2002 |
| $\beta_i$ | `β_vertebrate`                     | allometric exponent for vertebrates                               | -0.25          | Gillooly et al. 2002 |
| $E$       | `activation_energy_producer`       | activation energy for producers                                   | 0.53           | Dell et al 2011      |
| $E$       | `activation_energy_invertebrate`   | activation energy for invertebrates                               | 0.53           | Dell et al 2011      |
| $E$       | `activation_energy_vertebrates`    | activation energy for vertebrates                                 | 0.53           | Dell et al 2011      |
| $T_opt$   | `T_opt_producer`                   | temperature at which trait value is maximal (K) for producers     | 298.15         | NA                   |
| $T_opt$   | `T_opt_invertebrate`               | temperature at which trait value is maximal (K) for invertebrates | 298.15         | NA                   |
| $T_opt$   | `T_opt_vertebrate`                 | temperature at which trait value is maximal (K) for vertebrates   | 298.15         | NA                   |
| $E_D$     | `deactivation_energy_producer`     | deactivation energy for producers                                 | 1.15           | Dell et al 2011      |
| $E_D$     | `deactivation_energy_invertebrate` | deactivation energy for invertebrates                             | 1.15           | Dell et al 2011      |
| $E_D$     | `deactivation_energy_vertebrate`   | deactivation energy for invertebrates                             | 1.15           | Dell et al 2011      |

```julia
A = [0 1 0 ; 0 0 1 ; 0 0 0] #linear food chain
p = model_parameters(A, metabolicrate = ExtendedBA(:metabolicrate), T = 290.0) #default parameters values
# change the parameters values for the allometric exponent using a named tuple
p_newvalues = model_parameters(A, metabolicrate = ExtendedBA(:metabolicrate, parameters_tuple = (deactivation_energy_vertebrate = 1.02, T_opt_invertebrate = 293.15)), T = 290.0)
```

#### Attack rate

The attack rate is defined not for each species but for each interacting pair. As such, the body-mass scaling depends on the masses of both the consumer and its resource and the allometric exponent can be different for producers, vertebrates and invertebrates. However, the temperature scaling affects only the consumers, thus, the parameters involved can be defined differently only for vertebrates and invertebrates. For more details, see the table below.

Note: The body-mass allometric scaling (originally defined as $M_i^\beta$) becomes $M_{j}^{\beta_{j}} * M_{k}^{\beta_{k}}$ where $j$ is the consumer and $k$ its resource.

| Parameter | Keyword                            | Meaning                              | Default values | References            |
| --------- | ---------------------------------- | ------------------------------------ | -------------- | --------------------- |
| $r_0$     | `norm_constant_invertebrate`       | growth dependent scaling coefficient | $5.10^{13}$       | Bideault et al 2019   |
| $r_0$     | `norm_constant_vertebrate`         | growth dependent scaling coefficient | $5.10^{13}$       | Bideault et al 2019   |
| $\beta_i$ | `β_producer`                       | allometric exponent                  | 0.25           | Gillooly et al., 2002 |
| $\beta_i$ | `β_invertebrate`                   | allometric exponent                  | 0.25           | Gillooly et al., 2002 |
| $\beta_i$ | `β_vertebrate`                     | allometric exponent                  | 0.25           | Gillooly et al., 2002 |
| $E$       | `activation_energy_invertebrate`   | activation energy                    | 0.8            | Dell et al 2011       |
| $E$       | `activation_energy_vertebrate`     | activation energy                    | 0.8            | Dell et al 2011       |
| $E_D$     | `deactivation_energy_invertebrate` | deactivation energy                  | 1.15           | Dell et al 2011       |
| $E_D$     | `deactivation_energy_vertebrate`   | deactivation energy                  | 1.15           | Dell et al 2011       |
| $T_opt$   | `T_opt_invertebrate`               | normalization temperature (Kelvins)  | 298.15         | NA                    |
| $T_opt$   | `T_opt_vertebrate`                 | normalization temperature (Kelvins)  | 298.15         | NA                    |

To use this function, initialize `model_parameters()` with `ExtendedBA(:attackrate)` for the keyword `attackrate`:

```julia
A = [0 1 0 ; 0 0 1 ; 0 0 0] #linear food chain
p = model_parameters(A, attackrate = ExtendedBA(:attackrate), T = 290.0) #default parameters values
# change the parameters values for the allometric exponent using a named tuple
p_newvalues = model_parameters(A, attackrate = ExtendedBA(:attackrate, parameters_tuple = (deactivation_energy_vertebrate = 1.02, T_opt_invertebrate = 293.15))), T = 290.0)
```

### Gaussian

A simple gaussian function (or inverted gaussian function depending on the rate) has also been used in studies to model the scaling of biological rates with temperature. This can be formalized by the following equation:

$q_i(T) = M_i^\beta * q_{opt} * exp[\pm (\frac{(T - T_{opt})^2}{2s_q^2})]$

#### Growth rate

For the organisms growth, the default parameters values are:

| Parameter | Keyword         | Meaning                                     | Default values | References          |
| --------- | --------------- | ------------------------------------------- | -------------- | ------------------- |
| $q_{opt}$ | 'norm_constant' | maximal trait value (at $T_{opt}$)          | 1.0            | NA                  |
| $T_{opt}$ | 'T_opt'         | temperature at which trait value is maximal | 298.15         | Amarasekare 2015    |
| $s_q$     | 'range'         | performance breath (width of function)      | 20             | Amarasekare 2015    |
| $\beta$   | 'β'             | allometric exponent                         | -0.25          | Gillooly et al 2002 |

To use this function initialize `model_parameters()` with `Gaussian(:growthrate)` for the keyword `growthrate`:

```julia
A = [0 1 0 ; 0 0 1 ; 0 0 0] #linear food chain
p = model_parameters(A, growthrate = Gaussian(:growthrate), T = 290.0) #default parameters values
# change the parameters values for the allometric exponent using a named tuple
p_newvalues = model_parameters(A, growthrate = Gaussian(:growthrate, parameters_tuple = (T_opt = 300.15, )), T = 290.0)
```

#### Metabolic rate

For the metabolic rate, the parameters values can be different for each metabolic types (producers, invertebrates and vertebrates). The defaults are initially set to the same value for all metabolic types, but can be changed independently (see example below).

For the metabolic rate, the default parameters values are:

| Parameter | Keyword                      | Meaning                                                       | Default values | References          |
| --------- | ---------------------------- | ------------------------------------------------------------- | -------------- | ------------------- |
| $q_{opt}$ | 'norm_constant_producer'     | maximal trait value (at $T_{opt}$) for producers              | 0.2            | NA                  |
| $q_{opt}$ | 'norm_constant_invertebrate' | maximal trait value (at $T_{opt}$) for invertebrates          | 0.35           | NA                  |
| $q_{opt}$ | 'norm_constant_vertebrate'   | maximal trait value (at $T_{opt}$) for vertebrates            | 0.9            | NA                  |
| $T_{opt}$ | 'T_opt_producer'             | temperature at which trait value is maximal for producers     | 298.15         | Amarasekare 2015    |
| $T_{opt}$ | 'T_opt_invertebrate'         | temperature at which trait value is maximal for invertebrates | 298.15         | Amarasekare 2015    |
| $T_{opt}$ | 'T_opt_vertebrate'           | temperature at which trait value is maximal for vertebrates   | 298.15         | Amarasekare 2015    |
| $s_q$     | 'range_producer'             | performance breath (width of function) for producers          | 20             | Amarasekare 2015    |
| $s_q$     | 'range_invertebrate'         | performance breath (width of function) for invertebrates      | 20             | Amarasekare 2015    |
| $s_q$     | 'range_vertebrate'           | performance breath (width of function) for vertebrates        | 20             | Amarasekare 2015    |
| $\beta$   | 'β_producer'                 | allometric exponent for producers                             | -0.25          | Gillooly et al 2002 |
| $\beta$   | 'β_invertebrate'             | allometric exponent for vertebrates                           | -0.25          | Gillooly et al 2002 |
| $\beta$   | 'β_vertebrate'               | allometric exponent for vertebrates                           | -0.25          | Gillooly et al 2002 |

To use this function initialize `model_parameters()` with `Gaussian(:metabolicrate)` for the keyword `metabolicrate`:

```julia
A = [0 1 0 ; 0 0 1 ; 0 0 0] #linear food chain
p = model_parameters(A, metabolicrate = Gaussian(:metabolicrate), T = 290.0) #default parameters values
# change the parameters values for the allometric exponent using a named tuple
p_newvalues = model_parameters(A, metabolicrate = Gaussian(:metabolicrate, parameters_tuple = (T_opt_producer = 293.15, β_invertebrate = -0.3)), T = 290.0)
```

#### Attack rate

The attack rate is defined not for each species but for each interacting pair. As such, the body-mass scaling depends on the masses of both the consumer and its resource and the allometric exponent can be different for producers, vertebrates and invertebrates. However, the temperature scaling affects only the consumers, thus, the parameters involved can be defined differently only for vertebrates and invertebrates.

Note: The body-mass allometric scaling (originally defined as $M_i^\beta$) becomes $M_{j}^{\beta_{j}} * M_{k}^{\beta_{k}}$ where $j$ is the consumer and $k$ its resource.

For the attack rate, the default parameters values are:

| Parameter | Keyword                      | Meaning                                                       | Default values | References          |
| --------- | ---------------------------- | ------------------------------------------------------------- | -------------- | ------------------- |
| $q_{opt}$ | 'norm_constant_invertebrate' | maximal trait value (at $T_{opt}$) for invertebrates          | 16           | NA                  |
| $q_{opt}$ | 'norm_constant_vertebrate'   | maximal trait value (at $T_{opt}$) for vertebrates            | 16            | NA                  |
| $T_{opt}$ | 'T_opt_invertebrate'         | temperature at which trait value is maximal for invertebrates | 298.15         | Amarasekare 2015    |
| $T_{opt}$ | 'T_opt_vertebrate'           | temperature at which trait value is maximal for vertebrates   | 298.15         | Amarasekare 2015    |
| $s_q$     | 'range_invertebrate'         | performance breath (width of function) for invertebrates      | 20             | Amarasekare 2015    |
| $s_q$     | 'range_vertebrate'           | performance breath (width of function) for vertebrates        | 20             | Amarasekare 2015    |
| $\beta$   | 'β_producer'                 | allometric exponent for producers                             | -0.25          | Gillooly et al 2002 |
| $\beta$   | 'β_invertebrate'             | allometric exponent for vertebrates                           | -0.25          | Gillooly et al 2002 |
| $\beta$   | 'β_vertebrate'               | allometric exponent for vertebrates                           | -0.25          | Gillooly et al 2002 |


To use this function initialize `model_parameters()` with `Gaussian(:attackrate)` for the keyword `attackrate`:

```julia
A = [0 1 0 ; 0 0 1 ; 0 0 0] #linear food chain
p = model_parameters(A, attackrate = Gaussian(:attackrate), T = 290.0) #default parameters values
# change the parameters values for the allometric exponent using a named tuple
p_newvalues = model_parameters(A, attackrate = Gaussian(:attackrate, parameters_tuple = (range_vertebrate = 25, range_invertebrate = 30)), T = 290.0)
```

#### Handling time

The handling time is defined not for each species but for each interacting pair. As such, the body-mass scaling depends on the masses of both the consumer and its resource and the allometric exponent can be different for producers, vertebrates and invertebrates. However, the temperature scaling affects only the consumers, thus, the parameters involved can be defined differently only for vertebrates and invertebrates. For more details, see the table below.

*Nota 1*: The body-mass allometric scaling (originally defined as $M_i^\beta$) becomes $M_{j}^{\beta_{j}} * M_{k}^{\beta_{k}}$ where $j$ is the consumer and $k$ its resource.

*Nota 2*: The handling time is the only rate for which an inverted gaussian is used (the handling time becomes more optimal by decreasing).

For the handing time, the default parameters values are:

| Parameter | Keyword                      | Meaning                                                       | Default values | References          |
| --------- | ---------------------------- | ------------------------------------------------------------- | -------------- | ------------------- |
| $q_{opt}$ | 'norm_constant_invertebrate' | maximal trait value (at $T_{opt}$) for invertebrates          | 0.125          | NA                  |
| $q_{opt}$ | 'norm_constant_vertebrate'   | maximal trait value (at $T_{opt}$) for vertebrates            | 0.125          | NA                  |
| $T_{opt}$ | 'T_opt_invertebrate'         | temperature at which trait value is maximal for invertebrates | 298.15         | Amarasekare 2015    |
| $T_{opt}$ | 'T_opt_vertebrate'           | temperature at which trait value is maximal for vertebrates   | 298.15         | Amarasekare 2015    |
| $s_q$     | 'range_invertebrate'         | performance breath (width of function) for invertebrates      | 20             | Amarasekare 2015    |
| $s_q$     | 'range_vertebrate'           | performance breath (width of function) for vertebrates        | 20             | Amarasekare 2015    |
| $\beta$   | 'β_producer'                 | allometric exponent for producers                             | -0.25          | Gillooly et al 2002 |
| $\beta$   | 'β_invertebrate'             | allometric exponent for vertebrates                           | -0.25          | Gillooly et al 2002 |
| $\beta$   | 'β_vertebrate'               | allometric exponent for vertebrates                           | -0.25          | Gillooly et al 2002 |

To use this function initialize `model_parameters()` with `ExponentialBA(:handlingtime)` for the keyword `handlingtime`:

```julia
A = [0 1 0 ; 0 0 1 ; 0 0 0] #linear food chain
p = model_parameters(A, handlingtime = Gaussian(:handlingtime), T = 290.0) #default parameters values
# change the parameters values for the allometric exponent using a named tuple
p_newvalues = model_parameters(A, handlingtime = Gaussian(:handlingtime, parameters_tuple = (T0_vertebrate = 300.15, β_producer = -0.25)), T = 290.0)
```

## Temperature dependence for body sizes

The default behavior of the model is to assume, as it does for biological rates, that typical adults body sizes are not affected by temperature. In this case, the bodymass vector can either:

- be provided to `model_parameters` through the keyword `bodymass`: `model_parameters(A, bodymass = [...])`
- be calculated by `model_parameters` as $Mi= Z^(TR_i-1)$ where $TR_i$ is the trophic level of species $i$ and $Z$ is the typical consumer-resource body mass ratio in the system. $Z$ can be passed to `model_parameters` by using the `Z` keyword: `model_parameters(A, Z = 10.0)`
- be a vector of dry masses (at 293.15 Kelvins) provided by the user: `model_parameters(A, dry_mass_293 = [...])`

If multiple keywords are provided, the model will use this order of priority: body masses, dry masses, Z.

To simulate the effect of temperature on body masses, the model uses the following general formula, following Forster and Hirst 2012:

$M_i(T) = m_i * exp(log_{10}(PCM / 100 + 1) * T - 293.15)$

Where $M_i$ is the body mass of species $i$, $T$ is the temperature (in Kelvins), $m_i$ is the body mass when there is no effect of temperature (provided by the user through `Z`, `bodymass` or `dry_mass_293`) and $PCM$ is the Percentage change in body-mass per degree Celsius. This percentage is calculated differently depending on the type of system or the type of response wanted (Forster and Hirst 2012, Sentis et al 2017):

- Mean Aquatic Response: $PCM = -3.90 - 0.53 * log_{10}(dm)$ where $dm$ is the dry mass (calculated in the model from Z or wet mass if not provided). Body size decreases with temperature.
- Mean Terrestrial Response: $PCM = -1.72 + 0.54 * log_{10}(dm)$ where $dm$ is the dry mass (calculated in the model from Z or wet mass if not provided). Body size decreases with temperature.
- Maximum Response: $PCM = -8$. Body size decreases with temperature.
- Reverse Response: $PCM = 4$. Body size **increases** with temperature.

To set the temperature size rule, use the `TSR` keyword in `model_parameters`:

``` julia
A = [0 1 1 ; 0 0 1 ; 0 0 0] #omnivory motif
p_aqua = model_parameters(A, T = 290.0, TSR = :mean_aquatic) #mean aquatic, wet and dry masses calculated from Z and trophic levels (Z default value is 1.0)
p_terr = model_parameters(A, T = 290.0, TSR = :mean_terrestrial, bodymass = [26.3, 15.2, 4.3]) #mean terrestrial, typical wet masses (at 20 degrees C) are provided and will we used to estimate dry masses and wet masses at T degrees K.
p_max = model_parameters(A, T = 290.0, TSR = :maximum, dry_mass_293 = [1.8, 0.7, 0.2]) #maximum, dry masses are provided and will be used by the temperature size rule to calculate wet masses at T degrees K.
p_rev =  model_parameters(A, T = 290.0, TSR = :maximum, Z = 10.0) #reverse - masses increase with T, wet and dry masses calculated from Z and trophic levels.
```

# References

Amarasekare, P. (2015). Effects of temperature on consumer–resource interactions. Journal of Animal Ecology, 84(3), 665-679.

Bideault, A., Loreau, M., & Gravel, D. (2019). Temperature modifies consumer-resource interaction strength through its effects on biological rates and body mass. Frontiers in Ecology and Evolution, 7, 45.

Bernhardt, J. R., Sunday, J. M., Thompson, P. L., & O'Connor, M. I. (2018). Nonlinear averaging of thermal experience predicts population growth rates in a thermally variable environment. Proceedings of the Royal Society B: Biological Sciences, 285(1886), 20181076.

Binzer, A., Guill, C., Brose, U., & Rall, B. C. (2012). The dynamics of food chains under climate change and nutrient enrichment. Philosophical Transactions of the Royal Society B: Biological Sciences, 367(1605), 2935-2944.

Binzer, A., Guill, C., Rall, B. C., & Brose, U. (2016). Interactive effects of warming, eutrophication and size structure: impacts on biodiversity and food‐web structure. Global change biology, 22(1), 220-227.

Brose, U., Williams, R. J., & Martinez, N. D. (2006). Allometric scaling enhances stability in complex food webs. Ecology letters, 9(11), 1228-1236.

Englund, G., Öhlund, G., Hein, C. L., & Diehl, S. (2011). Temperature dependence of the functional response. Ecology letters, 14(9), 914-921.

Eppley, R. W. (1972). Temperature and phytoplankton growth in the sea. Fish. bull, 70(4), 1063-1085.

Forster, J., & Hirst, A. G. (2012). The temperature‐size rule emerges from ontogenetic differences between growth and development rates. Functional Ecology, 26(2), 483-492.

Kremer, C. T., Thomas, M. K., & Litchman, E. (2017). Temperature‐and size‐scaling of phytoplankton population growth rates: Reconciling the Eppley curve and the metabolic theory of ecology. Limnology and Oceanography, 62(4), 1658-1670.

Rall, B. C., Brose, U., Hartvig, M., Kalinkat, G., Schwarzmüller, F., Vucic-Pestic, O., & Petchey, O. L. (2012). Universal temperature and body-mass scaling of feeding rates. Philosophical Transactions of the Royal Society B: Biological Sciences, 367(1605), 2923-2934.

Sentis, A., Binzer, A., & Boukal, D. S. (2017). Temperature‐size responses alter food chain persistence across environmental gradients. Ecology letters, 20(7), 852-862.
