# Random networks

The `befwm` allows the generation of random networks.

## Niche model

Following Williams & Martinez {{ "williams-martinez" | cite }}, we have
implemented the *niche* model of food webs. This model represents allometric
relationships between preys and predators well {{ "gravel" | cite }}, and
is therefore well suited to generate random networks for `befwm`.

Random niche model networks can be generated using `nichemodel`, which takes
two arguments: the number of species `S`, and the connectance `C`:

~~~ julia
nichemodel(10, 0.3)
nichemodel(10, 0.4)
nichemodel(10, 0.5)
~~~

