# Getting started with `BioEnergeticFoodWebs`

## Installing `julia`

Julia can be installed from the [JuliaLang][jll] website. Most
GNU/Linux distributions have a package named `julia`, and there are
[platform-specific][pfsi] instructions if needs be.

[jll]: http://julialang.org/downloads/ "JuliaLang download page"
[pfsi]: http://julialang.org/downloads/platform.html "Platform-specific installation instructions"

There are further specific instructions to install a Julia kernel in Jupyter
on the [IJulia](https://github.com/JuliaLang/IJulia.jl) page.

## Installing `BioEnergeticFoodWebs`

The current version can be installed by typing the following line into Julia
(which is usually started from the command line

``` julia
Pkg.add("BioEnergeticFoodWebs")
```

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

1. Timothée Poisot, & Eva Delmas. (2016). PoisotLab/BioEnergeticFoodWebs.jl: v0.1.0 [Data set]. Zenodo. http://doi.org/10.5281/zenodo.160189
2. Eva Delmas, Ulrich Brose, Dominique Gravel, Daniel Stouffer, Timothée Poisot
bioRxiv 070946; doi: http://dx.doi.org/10.1101/070946
