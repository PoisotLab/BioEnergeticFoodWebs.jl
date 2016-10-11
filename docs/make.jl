using Documenter, BioEnergeticFoodWebs

makedocs(
         modules = [BioEnergeticFoodWebs]
        )

deploydocs(
           deps   = Deps.pip("pygments", "mkdocs", "mkdocs-material", "python-markdown-math"),
           repo = "github.com/PoisotLab/BioEnergeticFoodWebs.jl.git"
          )
