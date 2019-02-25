# Temperature dependence

Both organisms biological rates and body sizes can be set to be temperature dependent, using repectively different temperature dependence functions for biological rates and different temperature size rules for body sizes. This effect of temperature can be integrated in the bioenergetic model using one of the functions described below. However, note **that these functions should only be used when the user has a good understanding of the system modelled** as some functions, under certain conditions, can lead to an erratic behavior of the bioenergetic model (instability, negative rates, etc.).

## Temperature dependence for biological rates

The default behavior of the model will always be to assume that none of the biological rates are affected by temperature -- see (TODO) for details on how to control the parameters values in this case. If you wish to implement temperature dependence however, you can use one of the following functions:
- extended Eppley function
- exponential Boltzmann Arrhenius function
- extended Boltzmann Arrhenius function
- Gaussian function
-
These functions determine the shape of the thermal curves used to scale the biological rates with temperature.

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

$$
q_i(T) = M_i^\beta * m0 * exp(b * T) * (1 - (\frac{T - T_{\text{opt}}}{\text{range}/2})^2)
$$

Where $M_i$ is the body mass of species $i$ and T is the temperature in degrees Kelvin. The default parameters values are described for each rate below.


#### Growth rate

For the growth rate, the parameters values are set to:

| Parameter        | Keyword           | Meaning                                                                    | Default values | References           |
| ---------------- | ----------------- | -------------------------------------------------------------------------- | -------------- | -------------------- |
| $β$              | `β`               | allometric exponent                                                        | -0.25          | Gillooly et al. 2002 |
| $m0$             | `maxrate_0`       | maximum growth rate observed at 273.15 K                                   | 0.81           | Eppley 1972          |
| $b$              | `eppley_exponent` | exponential rate of increase                                               | 0.0631         | Eppley 1972          |
| $T_{\text{opt}}$ | `T_opt`           | location of the maximum of the quadratic portion of the function (Kelvins) | 298.15         | NA                   |
| $\text{range}$   | `range`           | thermal breadth (range within which the rate is positive)                  | 35             | NA                   |

To use this function initialize `model_parameters()` with `ExtendedEppley(:growthrate)` for the keyword `growthrate`:

```julia
A = [0 1 0 ; 0 0 1 ; 0 0 0] #linear food chain
p = model_parameters(A, growthrate = ExtendedEppley(:growthrate), T = 290.0) #default parameters values
# change the parameters values for the allometric exponent using a named tuple
p_newvalues = model_parameters(A, growthrate = ExtendedEppley(:growthrate, parameters_tuple = (β = -0.21,)), T = 290.0)
```

#### Metabolic rate

We use the same function as above for the metabolic rate, with the added possibility to have different parameters values for producers, vertebrates and invertebrates. The defaults are initially set to the same for all metabolic types (see table above), but can be change independently (see example below).

```julia
A = [0 1 0 ; 0 0 1 ; 0 0 0] #linear food chain
p = model_parameters(A, metabolicrate = ExtendedEppley(:metabolicrate), T = 290.0) #default parameters values
# change the parameters values for the allometric exponent using a named tuple
p_newvalues = model_parameters(A, metabolicrate = ExtendedEppley(:metabolicrate, parameters_tuple = (range_producer = 30, range_invertebrate = 40, range_vertebrate = 25)), T = 290.0)
```

### Exponential Boltzmann Arrhenius

The Boltzmann Arrhenius model, following the Metabolic Theory in Ecology, describes the scaling of a biological rate ($q$) with temperature by:

$$
q_i(T) = exp(q_0) * M^\beta_i * exp(E-\frac{T_0 - T}{kT_0T})
$$

Where $q_0$ is the organisms state-dependent scaling coefficient, calculated for 1g at 20 degrees Celsius (273.15 degrees Kelvin), β is the rate specific allometric scaling exponent, $E$ is the activation energy in $eV$ (electronvolts) of the response, $T_0$ is the normalization temperature and $k$ is the Boltzmann constant ($8.617 10^{-5} eV.K^{-1}$). As for all other equations, $T$ is the temperature and $M_i$ is the typical adult body mass of species $i$.

#### Growth rate

For the growth rate, the parameters values are set to:

| Parameter | Keyword             | Meaning                              | Default values | References                             |
| --------- | ------------------- | ------------------------------------ | -------------- | -------------------------------------- |
| $r_0$     | `norm_constant`     | growth dependent scaling coefficient | -16.54         | Ehnes et al. 2011, Binzer et al. 2012  |
| $\beta_i$ | `β`                 | allometric exponent                  | -0.31          | Ehnes et al. 2011                      |
| $E$       | `activation_energy` | activation energy                    | -0.69          | Ehnes et al. 2011, Binzer et al. 2012  |
| $T_0$     | `T0`                | normalization temperature (Kelvins)  | 293.15         | Binzer et al. 2012, Binzer et al. 2012 |

To use this function initialize `model_parameters()` with `ExponentialBA(:growthrate)` for the keyword `growthrate`:

```julia
A = [0 1 0 ; 0 0 1 ; 0 0 0] #linear food chain
p = model_parameters(A, growthrate = ExponentialBA(:growthrate), T = 290.0) #default parameters values
# change the parameters values for the allometric exponent using a named tuple
p_newvalues = model_parameters(A, growthrate = ExponentialBA(:growthrate, parameters_tuple = (β = -0.21,)), T = 290.0)
```

#### Metabolic rate

For the metabolic rate, the parameters values can be different for each metabolic types (producers, invertebrates and vertebrates). The defaults are initially set to the same value for all metabolic types (see table above), but can be change independently (see example below).

```julia
A = [0 1 0 ; 0 0 1 ; 0 0 0] #linear food chain
p = model_parameters(A, metabolicrate = ExponentialBA(:metabolicrate), T = 290.0) #default parameters values
# change the parameters values for the allometric exponent using a named tuple
p_newvalues = model_parameters(A, metabolicrate = ExponentialBA(:metabolicrate, parameters_tuple = (T0_producer = 293.15, T0_invertebrate = 300.15, T0_vertebrate = 300.15)), T = 290.0)
```

#### Attack rate

The attack rate is defined not for each species but for each interacting pair. As such, the body-mass scaling depends on the masses of both the consumer and its resource and the allometric exponent can be different for producers, vertebrates and invertebrates. However, the temperature scaling affects only the consumers, thus, the parameters involved can be defined differently only for vertebrates and invertebrates. For more details, see the table below.

Note: The body-mass allometric scaling (originally defined as $M_i^\beta$) becomes $M_j^{\beta} * M_k^{\beta}$ where $j$ is the consumer and $k$ its resource.

| Parameter | Keyword                          | Meaning                              | Default values | References                             |
| --------- | -------------------------------- | ------------------------------------ | -------------- | -------------------------------------- |
| $r_0$     | `norm_constant_invertebrate`     | growth dependent scaling coefficient | -16.54         | Ehnes et al. 2011, Binzer et al. 2012  |
| $r_0$     | `norm_constant_vertebrate`       | growth dependent scaling coefficient | -16.54         | Ehnes et al. 2011, Binzer et al. 2012  |
| $\beta_i$ | `β_producer`                     | allometric exponent                  | -0.31          | Ehnes et al. 2011                      |
| $\beta_i$ | `β_invertebrate`                 | allometric exponent                  | -0.31          | Ehnes et al. 2011                      |
| $\beta_i$ | `β_vertebrate`                   | allometric exponent                  | -0.31          | Ehnes et al. 2011                      |
| $E$       | `activation_energy_invertebrate` | activation energy                    | -0.38          | Ehnes et al. 2011, Binzer et al. 2012  |
| $E$       | `activation_energy_vertebrate`   | activation energy                    | -0.38          | Ehnes et al. 2011, Binzer et al. 2012  |
| $T_0$     | `T0_invertebrate`                | normalization temperature (Kelvins)  | 293.15         | Binzer et al. 2012, Binzer et al. 2012 |
| $T_0$     | `T0_vertebrate`                  | normalization temperature (Kelvins)  | 293.15         | Binzer et al. 2012, Binzer et al. 2012 |

```julia
A = [0 1 0 ; 0 0 1 ; 0 0 0] #linear food chain
p = model_parameters(A, metabolicrate = ExponentialBA(:attackrate), T = 290.0) #default parameters values
# change the parameters values for the allometric exponent using a named tuple
p_newvalues = model_parameters(A, metabolicrate = ExponentialBA(:attackrate, parameters_tuple = (T0_invertebrate = 300.15, T0_vertebrate = 300.15)), T = 290.0)
```

#### Handling time

The handling time is defined not for each species but for each interacting pair. As such, the body-mass scaling depends on the masses of both the consumer and its resource and the allometric exponent can be different for producers, vertebrates and invertebrates. However, the temperature scaling affects only the consumers, thus, the parameters involved can be defined differently only for vertebrates and invertebrates. For more details, see the table below.

Note: The body-mass allometric scaling (originally defined as $M_i^β$) becomes $M_j^\beta_j * M_k^\beta_k$ where $j$ is the consumer and $k$ its resource.

| Parameter | Keyword                          | Meaning                              | Default values | References                             |
| --------- | -------------------------------- | ------------------------------------ | -------------- | -------------------------------------- |
| $r_0$     | `norm_constant_invertebrate`     | growth dependent scaling coefficient | 9.66           | Ehnes et al. 2011, Binzer et al. 2012  |
| $r_0$     | `norm_constant_vertebrate`       | growth dependent scaling coefficient | 9.66           | Ehnes et al. 2011, Binzer et al. 2012  |
| $\beta_i$ | `β_producer`                     | allometric exponent                  | -0.45          | Ehnes et al. 2011                      |
| $\beta_i$ | `β_invertebrate`                 | allometric exponent                  | 0.47           | Ehnes et al. 2011                      |
| $\beta_i$ | `β_vertebrate`                   | allometric exponent                  | -0.47          | Ehnes et al. 2011                      |
| $E$       | `activation_energy_invertebrate` | activation energy                    | 0.26           | Ehnes et al. 2011, Binzer et al. 2012  |
| $E$       | `activation_energy_vertebrate`   | activation energy                    | 0.26           | Ehnes et al. 2011, Binzer et al. 2012  |
| $T_0$     | `T0_invertebrate`                | normalization temperature (Kelvins)  | 293.15         | Binzer et al. 2012, Binzer et al. 2012 |
| $T_0$     | `T0_vertebrate`                  | normalization temperature (Kelvins)  | 293.15         | Binzer et al. 2012, Binzer et al. 2012 |


```julia
A = [0 1 0 ; 0 0 1 ; 0 0 0] #linear food chain
p = model_parameters(A, metabolicrate = ExponentialBA(:handlingtime), T = 290.0) #default parameters values
# change the parameters values for the allometric exponent using a named tuple
p_newvalues = model_parameters(A, metabolicrate = ExponentialBA(:handlingtime, parameters_tuple = (T0_vertebrate = 300.15, β_producer = -0.25)), T = 290.0)
```

### Extended Boltzmann Arrhenius

#### Growth rate

#### Metabolic rate

#### Attack rate

### Gaussian

#### Growth rate

#### Metabolic rate

#### Attack rate

#### Handling time

## Temperature dependence for body sizes

# References
