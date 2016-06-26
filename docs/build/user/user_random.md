
<a id='Generating-random-networks-1'></a>

## Generating random networks


The `befwm` allows the generation of random networks. It is, of course, possible to supply your own. The networks should be presented as matrices of 0 and 1. Internally, `befwm` will check that there are as many rows as there are columns.


<a id='Niche-model-1'></a>

### Niche model


Following Williams & Martinez {{ "williams-martinez" | cite }}, we have implemented the *niche* model of food webs. This model represents allometric relationships between preys and predators well {{ "gravel" | cite }}, and is therefore well suited to generate random networks for `befwm`.


Random niche model networks can be generated using `nichemodel`, which takes two arguments: the number of species `S`, and the number of interactions `L`:


```julia
nichemodel(10, 12)
nichemodel(10, 15)
nichemodel(10, 50)
```

