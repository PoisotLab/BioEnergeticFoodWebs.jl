push!(LOAD_PATH, "../src/")

using Documenter
using BioEnergeticFoodWebs

makedocs(
         modules = [BioEnergeticFoodWebs],
         sitename = "BioEnergeticFoodWebs.jl"
         )

deploydocs(
        deps   = Deps.pip("pygments", "python-markdown-math"),
        repo   = "github.com/PoisotLab/BioEnergeticFoodWebs.jl.git",
        devbranch = "next",
        push_preview = true
        )