using Pkg
using Documenter

push!(LOAD_PATH, "../src/")

Pkg.activate(".")
using BioEnergeticFoodWebs

makedocs(
         modules = [BioEnergeticFoodWebs],
         sitename = "BioEnergeticFoodWebs.jl",
         pages = [
                "Index" => "index.md",
                "Installation" => "man/installation.md",
                "Generating random networks" => "man/random.md",
                "First simulation" => "man/first_simulation.md",
                "Extinctions" => "man/extinctions.md",
                "Temperature dependence" => "man/temperature.md",
                "Contributing" => "man/contributing.md"
         ]
        )

deploydocs(
           deps = Deps.pip("pygments", "mkdocs==0.17.5", "mkdocs-material==2.9.4", "python-markdown-math"),
           repo = "github.com/PoisotLab/BioEnergeticFoodWebs.jl.git"
          )
