# Parameters

Below are presented all the model parameters, with their meaning, default values and how you can change them. The object containing all the parameters used tu run the model is created using the function `model_parameters`, the only argument that does not have a default value is `A` -- the interaction matrix.  

- `A` - Interaction matrix (`array{Int64, 2}`). Consumers ($i$) are in rows and eat resources ($j$) in columns. 

```julia
A = [0 1 0 ; 0 0 1 ; 0 0 0] #linear food chain
p = model_parameters(A) #default parameters values
```

This returns a dictionnary object, all values can be accessed by name: 

```julia
p[:x] #metabolic rates
p[:A] #interaction matrix
```

## Calculating the biological rates 

### Body mass

Body mass is important in this model, as it uses allometric scaling for calculating the biological rates (growth, maximum consumption and metabolism). Different alternatives can be used to attribute a body mass $M_i$ to each population $i$: 

- `bodymass` - Populations body masses (type: `array{Float64, 1}`). If a vector (of size S, where S is the number of populations in the interaction matrix A) is provided, the populations' biological rates will be calculated using their respective body mass. If not, body-masses will be calculated using `Z` 
- `dry_mass_293` - Populations dry body masses at 20 degrees (Celsius) (type: `array{Float64, 1}`). If a vector (of size S, where S is the number of populations in the interaction matrix A) is provided, the populations' biological rates will be calculated using their respective body mass, calculated from their dry body masses. If not, body-masses will be calculated using `Z` 
- `Z` (default = `1.0`, type: `Float64`) - Average consumer-resource body-mass ratio. If the body masses ($M_i$) are not provided, they are calculated from populations trophic levels ($TL_i$) as follow $M_i = Z^{TL_i}$.
- `TSR_type` (default = `:no_response` - type: `Symbol`). Temperature size rule, see more details on the [appropriate section of the documentation][tsr].

```julia
A = [0 1 0 ; 0 0 1 ; 0 0 0] #linear food chain
M = [20243.1, 545.4, 374.2] #species body mass
p = model_parameters(A, body_mass = M) #biological rates will be calculated using M
p[:x] #see that the values for x are not the same as the ones obtained from the example above
```

### Metabolic type

Another important trait for calculating biological rates is populations' metabolic type, as invertebrates and vertebrates will not have the same parameters for allometric scaling. 

- `vertebrates` (default = `[false]`, type: `array{Bool,1}`) - Populations metabolic type (all ectotherm vertebrates if `[true]`, all invertebrates if `[false]`). If a vector of size S (where S is the number of populations) is provided, you can specify the metabolic class of each species.

```julia
A = [0 1 0 ; 0 0 1 ; 0 0 0] #linear food chain
isvertebrate = [true, false, false] #species body mass
p = model_parameters(A, vertebrates = isvertebrate) #biological rates will be calculated using M
p[:x] #see that the values for x are not the same as the ones obtained from the examples above
```

### Allometric parameters

- y_invertebrate 
- y_vertebrate

### Temperature effect 

### System time-scale

- scale_bodymass
- scale_growth
- scale_metabolism
- scale_maxcons

## Productivity 

Biomass enters the food webs at the basal level. Multiple productivity functions can be used:

- `productivity` (default = `:species`, type: `Symbol`) - Function used to calculate basal species productivity. For more details, see the the [Basal species productivity section][prod] of the documentation. Alternatives are: 
    - `:species`: each species has an independant carrying capacity equal to `K`
    - `:system`: the carrying capacity is `K` divided by the number of primary producers
    - `:competitive`: the species compete with themselves at rate `1.0`, and with one another at rate `α`
    - `:nutrients`: a nutrient intake model is used
- `K` (default = `[1.0]`, type: `Array{Float64,1}`) - Carrying capacity of basal species. If productivity is set to `:species` you can provide a vector of size S (values correponding to consumer positions will be discarded), if only one value is provided, it will be the same for all basal species. If productivity is set to `:system` or `:competitive`, only one vale needs to be provided (system-wide carrying capacity).
- `α` (default = 1.0): strength of interspecific competition relatively to intraspecific competition
- `r`

### Nutrient intake model 

- `D`
- `ν` 
- K1
- K2

## Density-dependent mortality

- dc
- dp

## Consumption

### Functional response

- c
- h
- functional_response
- Γ

### Assimilation efficiency

- e_carnivore
- e_herbivore

## Rewiring (diet switch)

- rewire_method

### Allometric Diet Breatdh model

- adbm_trigger
- adbm_interval 
- e
- a_adbm
- ai
- aj
- b
- h_adbm
- hi
- hj
- n
- ni
- Hmethod
- Nmethod

### Diet Overlap model 

No parameters are needed for this method.

### Diet Similarity model

- cost
- specialistPrefMag
- preferenceMethod


[prod]: https://poisotlab.github.io/BioEnergeticFoodWebs.jl/latest/man/productivity/
[tsr]: https://poisotlab.github.io/BioEnergeticFoodWebs.jl/latest/man/temperature/#Temperature-dependence-for-body-sizes-1