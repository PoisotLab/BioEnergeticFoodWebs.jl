using Documenter
push!(LOAD_PATH, "../src/")
using BioEnergeticFoodWebs

makedocs(
         modules = [BioEnergeticFoodWebs]
        )

deploydocs(
           deps   = Deps.pip("pygments", "mkdocs", "mkdocs-material", "python-markdown-math"),
           julia = "0.5", 
           repo = "github.com/PoisotLab/BioEnergeticFoodWebs.jl.git"
          )
