# Getting started with `BioEnergeticFoodWebs`

## Installing `julia`

Julia can be installed from the [JuliaLang][jll] website. Most GNU/Linux
distributions have a package named `julia`, and there are [platform-specific
instructions][pfsi] if needs be.

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

~~~ julia
using befwm
~~~
        
# User manual

1. [General informations](general-informations)
1. [Measures on output](measures)
2. [Generating random networks](random-networks)
3. [Functions reference](api)


