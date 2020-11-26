# Extinctions

Extinctions often happen during simulations. You can control the biomass
threshold under which species will be considered as extinct using the 
`extinction_threshold` (default is `1e-6`): 

```julia 
A = [0 0 0 0 0 0 0 0 0 0; 
     0 1 0 0 0 0 0 0 0 0; 
     0 0 1 0 0 0 0 0 0 0; 
     0 1 1 1 1 1 1 0 0 0; 
     0 1 1 0 0 0 0 0 0 0; 
     1 1 1 1 1 1 1 1 0 0; 
     1 1 1 1 0 0 0 0 0 0; 
     0 0 1 1 1 1 1 0 0 0; 
     0 0 0 1 1 1 1 1 1 1; 
     0 0 0 0 0 0 0 1 0 0]
p = model_parameters(A)
b = rand(size(A, 1))

s = simulate(p, b, start=0, stop=100, extinction_threshold = 1e-12)
```

The identity of the extinct species are stored in the output as follow: 

```julia 
s[:p][:extinctions] #ordered set of extinct species 
s[:p][:extinctionstime] #each element contains a tuple describing an extinction event as follows:
                        #(time step, species identity)
s[:p][:tmpA] #after each extinction event, the interaction matrix is recalculated 
             #(removing interaction from and to extinct species or rewiring the matrix if rewiring is turned on)
s[:p][:A] #final state of the interaction matrix
```

It's important to note that for the model to run smoothly, the dimension of the
matrix doe not change, so if you want to analyze the structure of the emergent 
interaction matrix, you need to remove extinct species, as follows: 

```julia 
A_emergent = deepcopy(A)
id_extinct = s[:p][:extinctions] #ordered set of extinct species 
is_extinct = falses(size(A,1))
is_extinct[id_extinct] .= true
A_emergent = A_emergent[is_extinct, is_extinct]
```

## Rewiring (diet switch)

Simulations can be run with rewiring by using the `rewiring_method`
keyword in `model_parameters`.
This allows species to form new links following extinctions according to some
set of rules.
There are four options for the `rewiring_method` argument:

* `:none` - Default setting with no rewiring
* `:ADBM` - The allometric diet breadth model (ADBM) as described in Petchey et al. (2008). Based on optimal foraging theory.
* `:DS` - The rewiring mechanism used by Gilljam et al. (2015) based on diet similarity.
* `:DO` - The rewiring mechanism used by Staniczenko et al. (2010) based on diet overlap.

The `simulate` function will automatically perform the rewiring depending on
which option is chosen. Further arguments can also be supplied to
`model_parameters` to change the parameters of the rewiring models.

Simulations with rewiring are run in the same way as those without, for example using ADBM rewiring:

```julia
A = nichemodel(10, 0.3)
p = model_parameters(A,rewire_method = :ADBM)
b = rand(size(A, 1))

s = simulate(p, b, start=0, stop=50, steps=1000)
```

## Rewiring parameters

As for all other parameters, rewiring parameters can be passed to `model_parameters`. The parameters' default values follow the litterature (see references above). When no alternative value is provided, any value can be passed, as long as it is of the same type as the default value.

For more details on the parameters meaning and value, see the references

### Petchey's ADBM model

For this particular model, it is possible to chose how rewiring is triggered: on extinctions (default) or periodically (see example below the table).

| Name            | Meaning                                                    | Default value | Alternative value |
| --------------- | ---------------------------------------------------------- | ------------- | ----------------- |
| `adbm_trigger`  | Is rewiring triggered by extinctions or periodically?      | `:extinction` | `:interval`       |
| `adbm_interval` | Specifies the interval for periodical rewiring             | `100`         | Any `Int64`       |
| `Nmethod`       | Method used to calculate the resource density              | `:original`   | `:biomass`        |
| `Hmethod`       | Method used to calculate the handling time                 | `:ratio`      | `:power`          |
| `n`             | Scaling constant for the resource density                  | `1.0`         | Any `Float64`     |
| `ni`            | Species-specific scaling exponent for the resource density | `0.75`        | Any `Float64`     |
| `b`             | Scaling constant for handling time                         | `0.401`       | Any `Float64`     |
| `h_adbm`        | Scaling constant for handling time                         | `1.0`         | Any `Float64`     |
| `hi`            | Consumer specific scaling exponent for handling time       | `1.0`         | Any `Float64`     |
| `hj`            | Resource specific scaling constant for handling time       | `1.0`         | Any `Float64`     |
| `e`             | Scaling constant for the net energy gain                   | `1.0`         | Any `Float64`     |
| `a_adbm`        | Scaling constant for the attack rate                       | `0.0189`      | Any `Float64`     |
| `ai`            | Consumer specific scaling exponent for the attack rate     | `-0.491`      | Any `Float64`     |
| `aj`            | Resource specific scaling exponent for the attack rate     | `-0.465`      | Any `Float64`     |

Example:

```julia
# food web
A = [0 0 0 0 0; 0 1 0 0 0; 0 0 0 0 0; 0 1 1 0 0; 0 1 1 1 1]
# setting the model parameters for ADBM periodic rewiring using biomass to calculate resource densities
p = model_parameters(
                     A #food web
                     , Z = 10.0 #consumer/resource body mass scaling
                     , rewire_method = :ADBM #ADBM reiwring
                     , adbm_trigger = :interval #rewiring triggered periodically ...
                     , adbm_interval = 100 #... with Δt = 100
                     , Nmethod = :biomass #densities = biomass
                     )
# set initial biomass as to have immediate extinction of species 4
Bi = [1.0,1.0,1.0,0.0,1.0]
# perform the simulations
s = simulate(p, Bi)
# you can check the identity of the extinct species :
p[:extinctions]
# extinction times for each species:
p[:extinctionstime]
# and the temporary matrix (A is recorded just before each rewiring event)
p[:tmpA][1] # original matrix, just before extinction of species 4
p[:tmpA][2] # matrix after extinction of species 4, before extinction of species 2
# the new interaction matrix, after the last extinction:
p[:A]
```

### Gilljam's diet similarity model

| Name                | Meaning                                                                                      | Default value | Alternative value |
| ------------------- | -------------------------------------------------------------------------------------------- | ------------- | ----------------- |
| `cost`              | Rewiring cost (a consumer decrease in efficiency when exploiting novel resource)             | `0.0`         | --                |
| `specialistPrefMag` | Strength of the consumer preference for one prey species if `preferenceMethod = :specialist` | `0.9`         | --                |
| `preferenceMethod`  | Scenarios with respect to prey preferences of consumers                                      | `:generalist` | `:specialist`     |

### Staniczenko's diet overlap model

No extra parameters are needed for this rewiring method.

# References

- Gilljam, D., Curtsdotter, A., & Ebenman, B. (2015). Adaptive rewiring aggravates the effects of species loss in ecosystems. *Nature communications*, 6, 8412.

- Petchey, O. L., Beckerman, A. P., Riede, J. O., & Warren, P. H. (2008). Size, foraging, and food web structure. *Proceedings of the National Academy of Sciences*, 105(11), 4191-4196.

- Staniczenko, P., Lewis, O. T., Jones, N. S., & Reed‐Tsochas, F. (2010). Structural dynamics and robustness of food webs. *Ecology letters*, 13(7), 891-899.
