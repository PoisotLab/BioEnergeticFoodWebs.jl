# Temperature dependence

Both organisms biological rates and body sizes can be set to be temperature dependent, using repectively different temperature dependence functions for biological rates and different temperature size rules for body sizes. This effect of temperature can be integrated in the bioenergetic model using one of the functions described below. However, note **that these functions should only be used when the user has a good understanding of the system modelled** as some functions, under certain conditions, can lead to an erratic behavior of the bioenergetic model.

## Temperature dependence for biological rates

The defaut behavior of the model will always be to assume that none of the biological rates are affected by temperature -- see (TODO) for details on how to control the parameters values in this case. If you wish to implement temperature dependence however, you can use one of the following functions:
- extended Eppley function
- exponential Boltzmann Arrhenius function
- extended Boltzmann Arrhenius function
- Gaussian function
These functions determine the shape of the thermal curves used to relate temperature with biological rates.

### General example

Each of the biological rates (growth, metabolism, attack rate and handling time) is defined as a keyword in `model_parameters`. Simply specify the function you want to use as the corresponding value (and the temperature of the system):

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

#### Growth rate

Bernhardt et al. (2018) proposed an extension of the original model of Eppley (1972), following this extension the thermal performance curve of the growth rate $r_i$ of species $i$ is defined by the equation:

$$
r_i = M_i^β * m0 * exp(b * T) * (1 - (\frac{T - T_{\text{opt}}}{\text{range}/2})^2)
$$

Where $M_i$ is the body mass of species $i$ and T is the temperature. The parameters values are described in the table below:

| Parameter        | Keyword            | Meaning                                                                    | Default values | References           |
| ---------------- | ------------------ | -------------------------------------------------------------------------- | -------------- | -------------------- |
| $β$              | `β`               | allometric exponent                                                        | -0.25          | Gillooly et al. 2002 |
| $m0$             | `maxrate_0`       | maximum growth rate observed at 273.15 K                                   | 0.81           | Eppley 1972          |
| $b$              | `eppley_exponent` | exponential rate of increase                                               | 0.0631         | Eppley 1972          |
| $T_{\text{opt}}$ | `T_opt`           | location of the maximum of the quadratic portion of the function (Kelvins) | 298.15         | NA                   |
| $\text{range}$   | `range`           | thermal breadth (range within which the rate is positive)                  | 35             | NA                   |

To use this function initialize `model_parameters()` with `ExtendedEppley(:growthrate)` for the keyword `growthrate`:

```julia-repl
A = [0 1 0 ; 0 0 1 ; 0 0 0] #linear food chain
p = model_parameters(A, growthrate = ExtendedEppley(:growthrate), T = 290.0) #default parameters values
# change the parameters values for the allometric exponent using a named tuple
p_newvalues = model_parameters(A, growthrate = ExtendedEppley(:growthrate, parameters_tuple = (β = -0.21,)), T = 290.0)
```

#### Metabolic rate

We use the same function as above for the metabolic rate, with the added possibility to have different parameters values for producers, vertebrates and invertebrates. The defaults are initially set to the same for all metabolic types (se table above), but can be change independently (see example below).

```julia-repl
A = [0 1 0 ; 0 0 1 ; 0 0 0] #linear food chain
p = model_parameters(A, metabolicrate = ExtendedEppley(:metabolicrate), T = 290.0) #default parameters values
# change the parameters values for the allometric exponent using a named tuple
p_newvalues = model_parameters(A, metabolicrate = ExtendedEppley(:metabolicrate, parameters_tuple = (range_producer = 30, range invertebrate = 40, range_verebrate = 25)), T = 290.0)
```

### Exponential Boltzmann Arrhenius

#### Growth rate

#### Metabolic rate

#### Attack rate

#### Handling time

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
