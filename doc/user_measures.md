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

Note that in the original paper, what is presented is actually this measure,
multiplied by 100, which is the *relative standard error*, and not the
coefficient of variation. Note also that, so as to correct for the fact
that the number of timesteps varies, we use the corrected estimator of the
coefficient of variation.

## Population biomass

The `population_biomass` function returns the average biomass over `last`
timesteps for *every* population in the network.

## Total biomass

The `total_biomass` function returns the total biomass over `last`
timesteps for the entire network.

## Food web diversity

The `foodweb_diversity` is the Shannon entropy measure, corrected for the
number of population (*i.e.*, divided by the natural log of the number of
populations). Values of 1 indicate high evenness, and values close to 0
indicate extreme un-evenness. In the original paper, diversity is measured
as the number of species with a biomass above a given threshold. Given that
this threshold has to be set in an arbitrary way, and does not account for
the fact that changing several parameters also changes the distribution of
biomasses, we have not retained this measurement of diversity.

## Saving the simulations

The object returned by `simulate` can be saved using the `befwm.save`
function. This function is *not* exported, so it must be called with the
`befwm.` prefix. By default, this function will generate a unique identifier
for every simulation.
