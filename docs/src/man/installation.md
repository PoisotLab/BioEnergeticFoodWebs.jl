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

