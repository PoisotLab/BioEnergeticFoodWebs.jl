# Getting started with `BioEnergeticFoodWebs`

## Installing `julia`

The recommended way to install Julia is from the [JuliaLang][jll] website. Most
GNU/Linux distributions have a package named `julia`, and there are
[platform-specific][pfsi] instructions if needs be.

[jll]: http://julialang.org/downloads/ "JuliaLang download page"
[pfsi]: http://julialang.org/downloads/platform.html "Platform-specific installation instructions"

There are further specific instructions to install a Julia kernel in Jupyter
on the [IJulia](https://github.com/JuliaLang/IJulia.jl) page.

## Installing `BioEnergeticFoodWebs`

The current version can be installed by typing the following line into Julia
(which is usually started from the command line):

``` julia
Pkg.add("BioEnergeticFoodWebs")
```

!!! warning
    The version of `BioEnergeticFoodWebs` that will be installed depends on your version of `julia`. By default, the current version *always* works on the current released version of `julia`; but we make no guarantee that it will work on the previous version, or the one currently in development.

The package can be loaded with

``` julia
using BioEnergeticFoodWebs
```

## Keeping up to date

If you have already installed the package, you can check for updates with

``` julia
Pkg.update()
```

## Citing the package

The package itself can be cited as

!!! summary
    Timothée Poisot, Eva Delmas, Viral B. Shah, Tony Kelman, & Tom clegg. (2017). PoisotLab/BioEnergeticFoodWebs.jl: v0.3.1 [Data set]. Zenodo. http://doi.org/10.5281/zenodo.401053

If you want to also cite the software note describing the relase of `v0.2.0`,
you can cite

!!! summary
    Eva Delmas, Ulrich Brose, Dominique Gravel, Daniel Stouffer, Timothée Poisot. (2016). Simulations of biomass dynamics in community food webs. Methods col Evol. http://doi.org/10.1111/2041-210X.12713
