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
           deps = Deps.pip("pygments", "mkdocs==0.17.5", "mkdocs-material==2.9.4", "python-markdown-math"),
           repo = "github.com/PoisotLab/BioEnergeticFoodWebs.jl.git",
           devbranch = "next"
          )
