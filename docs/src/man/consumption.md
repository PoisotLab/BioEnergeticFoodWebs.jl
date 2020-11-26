# Consumption 

In the bioenergetic model, species gain and/or lose biomass through consumption. Gains and losses depends on the focus species biomass, a functional response and an interaction-specific assimilation efficiency. 
In the original bio-energetic model (as developped by Yodzis and Innes, 1992), the functional response 
is function of consumer-specific maximum consumption rates and half-saturation densities. However, it is sometimes more convenient to be able to work with a more classical functional response with interaction-specific attack rates and handling times. You can switch between the two implementation by setting the argument `functional_response` (`model_parameters` function) to either `:bioenergetic` (default) or `:classical`. The function will take care of calculating the various rates using allometric scaling. You can still modify the arguments or modify the rates values afterwards if needed.

Here is a list of the parameters that are common to the two implementations: 
- `e_carnivore` is the carnivores assimilation efficiency (default = `0.85`)
- `e_herbivore` is the herbivores assimilation efficiency (default = `0.45`)
- `c` is the value of the predator interference. Either one value, common for all consumers or a vector of consumer-specific values can be passed (default = `0.0.)
- `h` is the Hill exponent. It controls the shape of the functional response (default = `1`.)
- `y_invertebrate`and `y_vertebrate` are the maximum consumption rates for the invertebrates and ectotherm vertebrates respectively. 
- `Γ` is the half saturation density ($B_0$)

If you chose a `:bioenergetic` functional response, the following equations are used: 

$$
gains_i = \sum_{j \in resources} B_i x_i y_i FR_{ij}
$$

$$
losses_i = \sum_{j \in consumers} \frac{B_j x_j y_j FR_{ji}{e_{ji}}}
$$

where 

$$
FR_{ij} = \frac {\omega_{ij}B_{j}^{h}}{B_{0}^{h}+c_iB_iB_{0}^{h}+\sum_{k=resources}\omega_{ik}B_{k}^{h}}
$$

$\omega_{ij}$ (`w`) is the consumer $i$ preference for resource $j$, by default it is calculated as $1/n$ where $n$ is the number of resource for $i$ (homogenous consumption effort).

```julia 
A = [0 1 0 0 ; 0 0 1 1 ; 0 0 0 0 ; 0 0 0 0]
p = model_parameters(A, functional_response = :bioenergetic, e_carnivore = 0.9)
#you can change consumer preference in the parameter object
p[:w] = [.0 1.0 .0 .0 ; .0 .0 .9 .1 ; .0 .0 .0 .0 ; .0 .0 .0 .0]
``` 

If a `:classical` functional response is more suited for your project, then the consumer-specific maximum consumption rate and half saturation density will be transformed into interaction-specific attack rates and handling times using the following substitutions: 

- $ht_{ij} = 1/y_{i}$
- $ar_{ij} = 1/(B_0 ht_{ij})$

And the following equations are used for gains and losses linked to consumption: 

$$
gains_i = \sum_{j \in resources} e_{ij} B_i FR_{ij}
$$

$$
losses_i = \sum_{j \in consumers} B_j FR_{ji} 
$$

with 

$$
FR_{ij} = \frac {ar_{ij} B_{j}^{h}} {1 + c_iB_i + \sum_{k=resources} ht_{ik} ar_{ik}B_{k}^{h}}
$$

you can also change the values for attack rates and handling time directly from the parameter object: 

```julia 
A = [0 1 0 0 ; 0 0 1 1 ; 0 0 0 0 ; 0 0 0 0]
p = model_parameters(A, functional_response = :classical)
#you can change consumer preference in the parameter object
p[:ar] = [.0 1e-6 .0 .0 ; .0 .0 2.5e-5 8.2e-5 ; .0 .0 .0 .0 ; .0 .0 .0 .0]
``` 
