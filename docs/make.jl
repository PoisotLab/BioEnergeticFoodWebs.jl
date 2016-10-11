using Documenter, BioEnergeticFoodWebs

makedocs(
         modules = [BioEnergeticFoodWebs]
        )

deploydocs(
           repo = "github.com/PoisotLab/BioEnergeticFoodWebs.jl.git"
          )
