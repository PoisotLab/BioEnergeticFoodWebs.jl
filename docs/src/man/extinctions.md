# Extinctions

Simulations can be run with rewiring by using the `rewiring_method`
keyword in `make_parameters`.
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

The `simulate` function will automatically preform the rewiring depending on
which option is chosen. Further parameters can also be supplied to
`rewire_method` (NEED TO ADD A PARAMETERS SECTION).

Simulations with rewiring are run in the same way as those without, for example
using ADBM rewiring:
```julia
A = nichemodel(10, 0.3);
p = model_parameters(A,rewire_method = :ADBM);
b = rand(size(A, 1));

s = simulate(p, b, start=0, stop=50, steps=1000)
```
