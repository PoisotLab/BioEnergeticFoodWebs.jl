using Pkg
using Documenter

push!(LOAD_PATH, "../src/")

Pkg.activate(".")
using BioEnergeticFoodWebs

makedocs(
         modules = [BioEnergeticFoodWebs],
         sitename = "BioEnergeticFoodWebs.jl"
        )

deploydocs(
           deps = Deps.pip("pygments", "mkdocs", "mkdocs-material", "python-markdown-math"),
           julia = "1.0",
           repo = "github.com/PoisotLab/BioEnergeticFoodWebs.jl.git"
          )
