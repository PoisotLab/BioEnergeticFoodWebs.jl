# Measures on output

These functions let you work with the output of the simulations (*i.e.*
the object returned by `simulate`).

## Population variability

In the original paper {{ "brose" | cite }}, population variability is defined
as the average of the negative coefficients of variations of biomasses of
persisting species. This can be measured using the `population_stability`
function. There are two arguments you can act on: `last` (the number of
timesteps before the end on which the stability should be measured), and
`threshold` (the biomass under which populations are considered extinct for
the purpose of this measure).

This measure is *extremely* sensitive to both of these parameters, especially
when the system does not reach a stable equilibrium. We found that a
way to give much more stable results is to consider *all* species, even
those with very small biomasses. This can be done by setting a *negative*
threshold. Usually, at least 1000 timesteps are required to get a stable
estimate of stability.

## Population biomass

The `population_biomass` function returns the average biomass over `last`
timesteps for *every* population in the network.

## Total biomass

The `total_biomass` function returns the total biomass over `last`
timesteps for the entire network.
