# Generating random networks

Users can generate random networks. It is, of course, possible to supply your
own. The networks should be presented as matrices of 0 and 1. Internally,
`befwm` will check that there are as many rows as there are columns.

## Niche model

Following Williams & Martinez, we have implemented the *niche* model of
food webs. This model represents allometric relationships between preys and
predators well, and is therefore well suited to generate random networks.

Random niche model networks can be generated using `nichemodel`, which takes
two arguments: the number of species `S`, and the desired connectance `C`:

~~~@example
using BioEnergeticFoodWebs
nichemodel(10, 0.2)
~~~

Note that there are a number of keyword arguments (optional) that can be
supplied: `tolerance` will give the allowed deviation from the desired
connectance, and `toltype` will indicate whether the error is relative
or absolute.
