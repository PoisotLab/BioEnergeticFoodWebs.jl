# Extinctions

Simulations can be run with rewiring by using the `rewiring_method`
keyword in `model_parameters`.
This allows species to form new links following extinctions according to some
set of rules.
There are four options for the `rewiring_method` argument:
* `:none` - Default setting with no rewiring
* `:ADBM` - The allometric diet breadth model (ADBM) as described in Petchey
et al. (2008). Based on optimal foraging theory.
* `:Gilljam` - The rewiring mechanism used by Gilljam et al.(2015) based on diet
similarity.
* `:stan` - The rewiring mechanism used by Staniczenko et al.(2010) based
on diet overlap.

The `simulate` function will automatically perform the rewiring depending on
which option is chosen. Further parameters can also be supplied to
`model_parameters`.

Simulations with rewiring are run in the same way as those without, for example
using ADBM rewiring:

```julia
A = nichemodel(10, 0.3);
p = model_parameters(A,rewire_method = :ADBM);
b = rand(size(A, 1));

s = simulate(p, b, start=0, stop=50, steps=1000)
```

## Rewiring parameters

As for all other parameters, rewiring parameters can be passed to `model_parameters`. The parameters' default values follow the litterature (see references above). When no alternative value is provided, any value can be passed, as long as it is of the same type as the default value.

For more details on the parameters meaning and value, see the references

### Petchey's ADBM model

|Name|Meaning|Default value|Alternative value|
|---|---|---|---|
|`Nmethod`|Method used to calculate the resource density|`:original`|`:biomass`|
|`Hmethod`|Method used to calculate the handling time|`:ratio`|`:power`|
|`n`|Scaling constant for the resource density|`1.0`|--|
|`ni`|Species-specific scaling exponent for the resource density|`0.75`|--|
|`b`|Scaling constant for handling time|`0.401`|--|
|`h_adbm`|Scaling constant for handling time|`1.0`|--|
|`hi`|Consumer specific scaling exponent for handling time|`1.0`|--|
|`hj`|Resource specific scaling constant for handling time|`1.0`|--|
|`e`|Scaling constant for the net energy gain|`1.0`|--|
|`a_adbm`|Scaling constant for the attack rate|`0.0189`|--|
|`ai`|Consumer specific scaling exponent for the attack rate|`-0.491`|--|
|`aj`|Resource specific scaling exponent for the attack rate|`-0.465`|--|

### Gilljam's diet similarity model

|Name|Meaning|Default value|Alternative value|
|---|---|---|---|
|`cost`|Rewiring cost (a consumer decrease in efficiency when exploiting novel resource)|`0.0`|--|
|`specialistPrefMag`|Strength of the consumer preference for one prey species if `preferenceMethod = :specialist` |`0.9`|--|
|`preferenceMethod`|Scenarios with respect to prey preferences of consumers|`:generalist`|`:specialist`|

### Staniczenko's diet overlap model

No extra parameters are needed for this rewiring method.

# References

- Gilljam, D., Curtsdotter, A., & Ebenman, B. (2015). Adaptive rewiring aggravates the effects of species loss in ecosystems. *Nature communications*, 6, 8412.

- Petchey, O. L., Beckerman, A. P., Riede, J. O., & Warren, P. H. (2008). Size, foraging, and food web structure. *Proceedings of the National Academy of Sciences*, 105(11), 4191-4196.

- Staniczenko, P., Lewis, O. T., Jones, N. S., & Reed‐Tsochas, F. (2010). Structural dynamics and robustness of food webs. *Ecology letters*, 13(7), 891-899.
