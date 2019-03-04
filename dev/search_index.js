var documenterSearchIndex = {"docs": [

{
    "location": "#",
    "page": "-",
    "title": "-",
    "category": "page",
    "text": ""
},

{
    "location": "#Outline-1",
    "page": "-",
    "title": "Outline",
    "category": "section",
    "text": "Pages = [\n  \"man/installation.md\",\n  \"man/random.md\",\n  \"man/first_simulation.md\",\n  \"man/contributing.md\",\n  \"man/extinctions.md\",\n  \"man/temperature.md\"\n]\nDepth = 2"
},

{
    "location": "#Library-Outline-1",
    "page": "-",
    "title": "Library Outline",
    "category": "section",
    "text": "Pages = [\"lib/public.md\", \"lib/internals.md\"]\nDepth = 2"
},

{
    "location": "#main-index-1",
    "page": "-",
    "title": "Index",
    "category": "section",
    "text": ""
},

{
    "location": "#Functions-1",
    "page": "-",
    "title": "Functions",
    "category": "section",
    "text": "Pages = [\"lib/public.md\", \"lib/internals.md\"]\nOrder = [:function]"
},

{
    "location": "lib/internals/#",
    "page": "Internal Documentation",
    "title": "Internal Documentation",
    "category": "page",
    "text": "CurrentModule = BioEnergeticFoodWebs"
},

{
    "location": "lib/internals/#Internal-Documentation-1",
    "page": "Internal Documentation",
    "title": "Internal Documentation",
    "category": "section",
    "text": ""
},

{
    "location": "lib/internals/#Contents-1",
    "page": "Internal Documentation",
    "title": "Contents",
    "category": "section",
    "text": "Pages = [\"internals.md\"]"
},

{
    "location": "lib/internals/#Index-1",
    "page": "Internal Documentation",
    "title": "Index",
    "category": "section",
    "text": "Pages = [\"internals.md\"]"
},

{
    "location": "lib/internals/#BioEnergeticFoodWebs.connectance",
    "page": "Internal Documentation",
    "title": "BioEnergeticFoodWebs.connectance",
    "category": "function",
    "text": "** Connectance of a network**\n\nReturns the connectance of a square matrix, defined as SL^2.\n\n\n\n\n\n"
},

{
    "location": "lib/internals/#BioEnergeticFoodWebs.distance_to_producer",
    "page": "Internal Documentation",
    "title": "BioEnergeticFoodWebs.distance_to_producer",
    "category": "function",
    "text": "Distance to a primary producer\n\nThis function measures, for every species, its shortest path to a primary producer using matrix exponentiation. A primary producer has a value of 1, a primary consumer a value of 2, and so forth.\n\n\n\n\n\n"
},

{
    "location": "lib/internals/#BioEnergeticFoodWebs.trophic_rank",
    "page": "Internal Documentation",
    "title": "BioEnergeticFoodWebs.trophic_rank",
    "category": "function",
    "text": "Trophic rank\n\nBased on the average distance of preys to primary producers. Specifically, the rank is defined as the average of the distance of preys to primary producers (recursively). Primary producers always have a trophic rank of 1.\n\n\n\n\n\n"
},

{
    "location": "lib/internals/#BioEnergeticFoodWebs.check_food_web",
    "page": "Internal Documentation",
    "title": "BioEnergeticFoodWebs.check_food_web",
    "category": "function",
    "text": "Is the matrix correctly formatted?\n\nA correct matrix has only 0 and 1, two dimensions, and is square.\n\nThis function returns nothing, but raises an AssertionError if one of the conditions is not met.\n\n\n\n\n\n"
},

{
    "location": "lib/internals/#Functions-and-methods-for-networks-1",
    "page": "Internal Documentation",
    "title": "Functions and methods for networks",
    "category": "section",
    "text": "connectance\ndistance_to_producer\ntrophic_rank\ncheck_food_web"
},

{
    "location": "lib/internals/#BioEnergeticFoodWebs.dBdt",
    "page": "Internal Documentation",
    "title": "BioEnergeticFoodWebs.dBdt",
    "category": "function",
    "text": "Derivatives\n\nThis function is the one wrapped by the various integration routines. Based on a timepoint t, an array of biomasses biomass, and a series of simulation parameters p, it will return dB/dt for every species.\n\n\n\n\n\n"
},

{
    "location": "lib/internals/#BioEnergeticFoodWebs.growthrate",
    "page": "Internal Documentation",
    "title": "BioEnergeticFoodWebs.growthrate",
    "category": "function",
    "text": "Growth rate\n\nTODO\n\n\n\n\n\n"
},

{
    "location": "lib/internals/#ODE-wrappers-and-functions-for-integration-1",
    "page": "Internal Documentation",
    "title": "ODE wrappers and functions for integration",
    "category": "section",
    "text": "dBdt\ngrowthrate"
},

{
    "location": "lib/internals/#BioEnergeticFoodWebs.coefficient_of_variation",
    "page": "Internal Documentation",
    "title": "BioEnergeticFoodWebs.coefficient_of_variation",
    "category": "function",
    "text": "Coefficient of variation\n\nCorrected for the sample size.\n\n\n\n\n\n"
},

{
    "location": "lib/internals/#BioEnergeticFoodWebs.shannon",
    "page": "Internal Documentation",
    "title": "BioEnergeticFoodWebs.shannon",
    "category": "function",
    "text": "Shannon\'s entropy\n\nCorrected for the number of species, removes negative and null values, return NaN in case of problem.\n\n\n\n\n\n"
},

{
    "location": "lib/internals/#Functions-to-work-on-output-1",
    "page": "Internal Documentation",
    "title": "Functions to work on output",
    "category": "section",
    "text": "coefficient_of_variation\nshannon"
},

{
    "location": "lib/internals/#BioEnergeticFoodWebs.model_parameters",
    "page": "Internal Documentation",
    "title": "BioEnergeticFoodWebs.model_parameters",
    "category": "function",
    "text": "Create default parameters\n\nThis function creates model parameters, based on a food web matrix A. Specifically, the default values of the keyword parameters are:\n\nParameter Default Value Meaning\nK 1.0 carrying capacity of producers\nZ 1.0 consumer-resource body mass ratio\nr 1.0 growth rate of producers\nc 0 quantifies the predator interference\nh 1 Hill coefficient\ne_carnivore 0.85 assimilation efficiency of carnivores\ne_herbivore 0.45 assimilation efficiency of herbivores\ny_invertebrate 8 maximum consumption rate of invertebrate predators relative to their metabolic rate\ny_vertebrate 4 maximum consumption rate of vertebrate predators relative to their metabolic rate\nΓ 0.5 half-saturation density\nα 1.0 interspecific competition relatively to intraspecific competition\nproductivity :species type of productivity regulation\nrewire_method :none method for rewiring the foodweb following extinction events\ne 1 (ADBM) Scaling constant for the net energy gain\na_adbm 0.0189 (ADBM) Scaling constant for the attack rate\nai -0.491 (ADBM) Consumer specific scaling exponent for the attack rate\naj -0.465 (ADBM) Resource specific scaling exponent for the attack rate\nb 0.401 (ADBM) Scaling constant for handling time\nh_adbm 1.0 (ADBM) Scaling constant for handling time\nhi 1.0 (ADBM) Consumer specific scaling exponent for handling time\nhj 1.0 (ADBM) Resource specific scaling constant for handling time\nn 1.0 (ADBM) Scaling constant for the resource density\nni 0.75 (ADBM) Species-specific scaling exponent for the resource density\nHmethod :ratio (ADBM) Method used to calculate the handling time\nNmethod :original (ADBM) Method used to calculate the resource density\ncost 0.0 (Gilljam) Rewiring cost (a consumer decrease in efficiency when exploiting novel resource)\nspecialistPrefMag 0.9 (Gilljam) Strength of the consumer preference for 1 prey if preferenceMethod = :specialist\npreferenceMethod :generalist (Gilljam) Scenarios with respect to prey preferences of consumers\nD 0.25 global turnover rate\n\nAll of these values are passed as optional keyword arguments to the function.\n\nA = [0 1 1; 0 0 0; 0 0 0]\np = model_parameters(A, Z=100.0, productivity=:system)\n\nThe productivity keyword can be either :species (each species has an independant carrying capacity equal to K), :system (the carrying capacity is K divided by the number of primary producers), or :competitive (the species compete with themselves at rate 1.0, and with one another at rate α).\n\nIt is possible for the user to specify a vector of species body-mass, called bodymass – please do pay attention to the fact that the model assumes that primary producers have a bodymass equal to unity, since all biological rates are expressed relatively. We do not perform any check on whether or not the user-supplied body-mass vector is correct (mostly because there is no way of defining correctness for vectors where body-mass of producers are not equal to unity).\n\nThe keyword vertebrates is an array of true or false for every species in the matrix. By default, all species are invertebrates.\n\nA rewiring method can pe passed to specified if the foodweb should be rewired following extinctions events, and the method that should be used to perform the rewiring. This rewire_method keyword can be eighter :none (no rewiring), :ADBM (allometric diet breadth model as described in Petchey et al., 2008), :Gilljam (rewiring mechanism used by Gilljam et al., 2015, based on diet similarity) or :stan (rewiring mechanism used by Staniczenko et al, 2010, based on diet overlap).\n\nIf rewire_methodis :ADBM or :Gilljam, additional keywords can be passed. See the online documentation and the original references for more details.\n\n\n\n\n\n"
},

{
    "location": "lib/internals/#BioEnergeticFoodWebs.check_initial_parameters",
    "page": "Internal Documentation",
    "title": "BioEnergeticFoodWebs.check_initial_parameters",
    "category": "function",
    "text": "Check initial parameters\n\n\n\n\n\n"
},

{
    "location": "lib/internals/#BioEnergeticFoodWebs.check_parameters",
    "page": "Internal Documentation",
    "title": "BioEnergeticFoodWebs.check_parameters",
    "category": "function",
    "text": "Are the simulation parameters present?\n\nThis function will make sure that all the required parameters are here, and that the arrays and matrices have matching dimensions.\n\n\n\n\n\n"
},

{
    "location": "lib/internals/#Functions-to-prepare-and-check-parameters-1",
    "page": "Internal Documentation",
    "title": "Functions to prepare and check parameters",
    "category": "section",
    "text": "model_parameters\ncheck_initial_parameters\ncheck_parameters"
},

{
    "location": "lib/public/#",
    "page": "Public Documentation",
    "title": "Public Documentation",
    "category": "page",
    "text": ""
},

{
    "location": "lib/public/#Public-Documentation-1",
    "page": "Public Documentation",
    "title": "Public Documentation",
    "category": "section",
    "text": "Documentation for BioEnergeticFoodWebs\'s public (exported) interface.See Internal Documentation for documentation on internal functions."
},

{
    "location": "lib/public/#Contents-1",
    "page": "Public Documentation",
    "title": "Contents",
    "category": "section",
    "text": "Pages = [\"public.md\"]"
},

{
    "location": "lib/public/#Index-1",
    "page": "Public Documentation",
    "title": "Index",
    "category": "section",
    "text": "Pages = [\"public.md\"]"
},

{
    "location": "lib/public/#Setting-up-simulations-1",
    "page": "Public Documentation",
    "title": "Setting up simulations",
    "category": "section",
    "text": "model_parameters"
},

{
    "location": "lib/public/#BioEnergeticFoodWebs.nichemodel",
    "page": "Public Documentation",
    "title": "BioEnergeticFoodWebs.nichemodel",
    "category": "function",
    "text": "Niche model of food webs\n\nTakes a number of species S and a number of interactions L, and returns a food web with predators in rows, and preys in columns. This function is used internally by nichemodel called with a connectance.\n\n\n\n\n\nNiche model of food webs\n\nTakes a number of species S and a connectance C, and returns a food web with predators in rows, and preys in columns. Note that the connectance is first transformed into an integer number of interactions.\n\nThis function has two keyword arguments:\n\ntolerance is the allowed error on tolerance (see below)\ntoltype is the type or error, and can be :abs (absolute) and :rel\n\n(relative). Relative tolerance is the amount of error allowed, relative to the desired connectance value. If the simulated network has a tolerance x, the target connectance is c, then the relative error is |1-x/c|.\n\n\n\n\n\n"
},

{
    "location": "lib/public/#Generating-networks-1",
    "page": "Public Documentation",
    "title": "Generating networks",
    "category": "section",
    "text": "nichemodel"
},

{
    "location": "lib/public/#Simulating-and-saving-the-output-1",
    "page": "Public Documentation",
    "title": "Simulating and saving the output",
    "category": "section",
    "text": "simulate\nBioEnergeticFoodWebs.save"
},

{
    "location": "lib/public/#BioEnergeticFoodWebs.population_stability",
    "page": "Public Documentation",
    "title": "BioEnergeticFoodWebs.population_stability",
    "category": "function",
    "text": "Population stability\n\nPopulation stability is measured as the mean of the negative coefficient of variations of all species with an abundance higher than threshold. By default, the stability is measured over the last last=1000 timesteps.\n\n\n\n\n\n"
},

{
    "location": "lib/public/#BioEnergeticFoodWebs.total_biomass",
    "page": "Public Documentation",
    "title": "BioEnergeticFoodWebs.total_biomass",
    "category": "function",
    "text": "Total biomass\n\nReturns the sum of biomass, averaged over the last last timesteps.\n\n\n\n\n\n"
},

{
    "location": "lib/public/#BioEnergeticFoodWebs.population_biomass",
    "page": "Public Documentation",
    "title": "BioEnergeticFoodWebs.population_biomass",
    "category": "function",
    "text": "Per species biomass\n\nReturns the average biomass of all species, over the last last timesteps.\n\n\n\n\n\n"
},

{
    "location": "lib/public/#BioEnergeticFoodWebs.foodweb_evenness",
    "page": "Public Documentation",
    "title": "BioEnergeticFoodWebs.foodweb_evenness",
    "category": "function",
    "text": "Food web diversity\n\nBased on the average of Shannon\'s entropy (corrected for the number of species) over the last last timesteps. Values close to 1 indicate that all populations have equal biomasses.\n\n\n\n\n\n"
},

{
    "location": "lib/public/#BioEnergeticFoodWebs.species_richness",
    "page": "Public Documentation",
    "title": "BioEnergeticFoodWebs.species_richness",
    "category": "function",
    "text": "Number of surviving species\n\nNumber of species with a biomass larger than the threshold. The threshold is by default set at eps(), which should be close to 10^-16.\n\n\n\n\n\n"
},

{
    "location": "lib/public/#BioEnergeticFoodWebs.species_persistence",
    "page": "Public Documentation",
    "title": "BioEnergeticFoodWebs.species_persistence",
    "category": "function",
    "text": "Proportion of surviving species\n\nProportion of species with a biomass larger than the threshold. The threshold is by default set at eps(), which should be close to 10^-16.\n\n\n\n\n\n"
},

{
    "location": "lib/public/#Analysis-of-output-1",
    "page": "Public Documentation",
    "title": "Analysis of output",
    "category": "section",
    "text": "population_stability\ntotal_biomass\npopulation_biomass\nfoodweb_evenness\nspecies_richness\nspecies_persistence"
},

{
    "location": "man/contributing/#",
    "page": "Contributing to the package",
    "title": "Contributing to the package",
    "category": "page",
    "text": ""
},

{
    "location": "man/contributing/#Contributing-to-the-package-1",
    "page": "Contributing to the package",
    "title": "Contributing to the package",
    "category": "section",
    "text": ""
},

{
    "location": "man/contributing/#Reporting-issues-1",
    "page": "Contributing to the package",
    "title": "Reporting issues",
    "category": "section",
    "text": "A simple yet very useful way to contribute to BioEnergeticFoodWebs is to report issues on [GitHub][issues].[issues]: https://github.com/PoisotLab/BioEnergeticFoodWebs.jl/issues \"Open an issue\"Issues can be either reports of bugs, or suggestions of things to improve in the package."
},

{
    "location": "man/contributing/#Adding-code-and-features-1",
    "page": "Contributing to the package",
    "title": "Adding code and features",
    "category": "section",
    "text": "Please start by submitting an issue explaining what you would like to add. When we merge your changes into a new release, we will give you authorship on the DOI provided by [Zenodo][zenodo].[zenodo]: https://zenodo.org/record/160189#.V_1sLnVhlhEtip: Tip\nWhen you contribute, please fork the next branch, and not the master one. In order to make sure that the master branch is always functional, we do not commit directly to it."
},

{
    "location": "man/extinctions/#",
    "page": "Extinctions",
    "title": "Extinctions",
    "category": "page",
    "text": ""
},

{
    "location": "man/extinctions/#Extinctions-1",
    "page": "Extinctions",
    "title": "Extinctions",
    "category": "section",
    "text": "Simulations can be run with rewiring by using the rewiring_method keyword in model_parameters. This allows species to form new links following extinctions according to some set of rules. There are four options for the rewiring_method argument::none - Default setting with no rewiring\n:ADBM - The allometric diet breadth model (ADBM) as described in Petcheyet al. (2008). Based on optimal foraging theory.:Gilljam - The rewiring mechanism used by Gilljam et al.(2015) based on dietsimilarity.:stan - The rewiring mechanism used by Staniczenko et al.(2010) basedon diet overlap.The simulate function will automatically perform the rewiring depending on which option is chosen. Further parameters can also be supplied to model_parameters.Simulations with rewiring are run in the same way as those without, for example using ADBM rewiring:A = nichemodel(10, 0.3);\np = model_parameters(A,rewire_method = :ADBM);\nb = rand(size(A, 1));\n\ns = simulate(p, b, start=0, stop=50, steps=1000)"
},

{
    "location": "man/extinctions/#Rewiring-parameters-1",
    "page": "Extinctions",
    "title": "Rewiring parameters",
    "category": "section",
    "text": "As for all other parameters, rewiring parameters can be passed to model_parameters. The parameters\' default values follow the litterature (see references above). When no alternative value is provided, any value can be passed, as long as it is of the same type as the default value.For more details on the parameters meaning and value, see the references"
},

{
    "location": "man/extinctions/#Petchey\'s-ADBM-model-1",
    "page": "Extinctions",
    "title": "Petchey\'s ADBM model",
    "category": "section",
    "text": "Name Meaning Default value Alternative value\nNmethod Method used to calculate the resource density :original :biomass\nHmethod Method used to calculate the handling time :ratio :power\nn Scaling constant for the resource density 1.0 –\nni Species-specific scaling exponent for the resource density 0.75 –\nb Scaling constant for handling time 0.401 –\nh_adbm Scaling constant for handling time 1.0 –\nhi Consumer specific scaling exponent for handling time 1.0 –\nhj Resource specific scaling constant for handling time 1.0 –\ne Scaling constant for the net energy gain 1.0 –\na_adbm Scaling constant for the attack rate 0.0189 –\nai Consumer specific scaling exponent for the attack rate -0.491 –\naj Resource specific scaling exponent for the attack rate -0.465 –"
},

{
    "location": "man/extinctions/#Gilljam\'s-diet-similarity-model-1",
    "page": "Extinctions",
    "title": "Gilljam\'s diet similarity model",
    "category": "section",
    "text": "Name Meaning Default value Alternative value\ncost Rewiring cost (a consumer decrease in efficiency when exploiting novel resource) 0.0 –\nspecialistPrefMag Strength of the consumer preference for one prey species if preferenceMethod = :specialist 0.9 –\npreferenceMethod Scenarios with respect to prey preferences of consumers :generalist :specialist"
},

{
    "location": "man/extinctions/#Staniczenko\'s-diet-overlap-model-1",
    "page": "Extinctions",
    "title": "Staniczenko\'s diet overlap model",
    "category": "section",
    "text": "No extra parameters are needed for this rewiring method."
},

{
    "location": "man/extinctions/#References-1",
    "page": "Extinctions",
    "title": "References",
    "category": "section",
    "text": "Gilljam, D., Curtsdotter, A., & Ebenman, B. (2015). Adaptive rewiring aggravates the effects of species loss in ecosystems. Nature communications, 6, 8412.\nPetchey, O. L., Beckerman, A. P., Riede, J. O., & Warren, P. H. (2008). Size, foraging, and food web structure. Proceedings of the National Academy of Sciences, 105(11), 4191-4196.\nStaniczenko, P., Lewis, O. T., Jones, N. S., & Reed‐Tsochas, F. (2010). Structural dynamics and robustness of food webs. Ecology letters, 13(7), 891-899."
},

{
    "location": "man/first_simulation/#",
    "page": "First simulation",
    "title": "First simulation",
    "category": "page",
    "text": ""
},

{
    "location": "man/first_simulation/#First-simulation-1",
    "page": "First simulation",
    "title": "First simulation",
    "category": "section",
    "text": "Starting a simulation has three steps: getting the network, deciding on the parameters, and then starting the simulation itself.In this example, we will start with a simple generation of the null model, then generate the default set of parameters (see ?model_parameters), and start a short simulation.Do keep in mind that all functions are documented, so you can type in ?function_name from within Julia, and get access to the documentation.A = nichemodel(10, 0.3);\np = model_parameters(A);\nb = rand(size(A, 1));\n\ns = simulate(p, b, start=0, stop=50, steps=1000)The A matrix, which is used by subsequent functions, has predators in rows, and preys in columns. It can only have 0 and 1."
},

{
    "location": "man/installation/#",
    "page": "Getting started with BioEnergeticFoodWebs",
    "title": "Getting started with BioEnergeticFoodWebs",
    "category": "page",
    "text": ""
},

{
    "location": "man/installation/#Getting-started-with-BioEnergeticFoodWebs-1",
    "page": "Getting started with BioEnergeticFoodWebs",
    "title": "Getting started with BioEnergeticFoodWebs",
    "category": "section",
    "text": ""
},

{
    "location": "man/installation/#Installing-julia-1",
    "page": "Getting started with BioEnergeticFoodWebs",
    "title": "Installing julia",
    "category": "section",
    "text": "The recommended way to install Julia is from the [JuliaLang][jll] website. Most GNU/Linux distributions have a package named julia, and there are [platform-specific][pfsi] instructions if needs be.[jll]: http://julialang.org/downloads/ \"JuliaLang download page\" [pfsi]: http://julialang.org/downloads/platform.html \"Platform-specific installation instructions\"There are further specific instructions to install a Julia kernel in Jupyter on the IJulia page."
},

{
    "location": "man/installation/#Installing-BioEnergeticFoodWebs-1",
    "page": "Getting started with BioEnergeticFoodWebs",
    "title": "Installing BioEnergeticFoodWebs",
    "category": "section",
    "text": "The current version can be installed by typing the following line into Julia (which is usually started from the command line):Pkg.add(\"BioEnergeticFoodWebs\")warning: Warning\nThe version of BioEnergeticFoodWebs that will be installed depends on your version of julia. By default, the current version always works on the current released version of julia; but we make no guarantee that it will work on the previous version, or the one currently in development.The package can be loaded withusing BioEnergeticFoodWebs"
},

{
    "location": "man/installation/#Keeping-up-to-date-1",
    "page": "Getting started with BioEnergeticFoodWebs",
    "title": "Keeping up to date",
    "category": "section",
    "text": "If you have already installed the package, you can check for updates withPkg.update()"
},

{
    "location": "man/installation/#Citing-the-package-1",
    "page": "Getting started with BioEnergeticFoodWebs",
    "title": "Citing the package",
    "category": "section",
    "text": "The package itself can be cited assummary: Summary\nTimothée Poisot, Eva Delmas, Viral B. Shah, Tony Kelman, & Tom clegg. (2017). PoisotLab/BioEnergeticFoodWebs.jl: v0.3.1 [Data set]. Zenodo. http://doi.org/10.5281/zenodo.401053If you want to also cite the software note describing the relase of v0.2.0, you can citesummary: Summary\nEva Delmas, Ulrich Brose, Dominique Gravel, Daniel Stouffer, Timothée Poisot. (2016). Simulations of biomass dynamics in community food webs. Methods col Evol. http://doi.org/10.1111/2041-210X.12713"
},

{
    "location": "man/random/#",
    "page": "Generating random networks",
    "title": "Generating random networks",
    "category": "page",
    "text": ""
},

{
    "location": "man/random/#Generating-random-networks-1",
    "page": "Generating random networks",
    "title": "Generating random networks",
    "category": "section",
    "text": "Users can generate random networks. It is, of course, possible to supply your own. The networks should be presented as matrices of 0 and 1. Internally, befwm will check that there are as many rows as there are columns."
},

{
    "location": "man/random/#Niche-model-1",
    "page": "Generating random networks",
    "title": "Niche model",
    "category": "section",
    "text": "Following Williams & Martinez, we have implemented the niche model of food webs. This model represents allometric relationships between preys and predators well, and is therefore well suited to generate random networks.Random niche model networks can be generated using nichemodel, which takes two arguments: the number of species S, and the desired connectance C:using BioEnergeticFoodWebs\nnichemodel(10, 0.2)Note that there are a number of keyword arguments (optional) that can be supplied: tolerance will give the allowed deviation from the desired connectance, and toltype will indicate whether the error is relative or absolute."
},

{
    "location": "man/temperature/#",
    "page": "Temperature dependence",
    "title": "Temperature dependence",
    "category": "page",
    "text": ""
},

{
    "location": "man/temperature/#Temperature-dependence-1",
    "page": "Temperature dependence",
    "title": "Temperature dependence",
    "category": "section",
    "text": "Both organisms biological rates and body sizes can be set to be temperature dependent, using respectively different temperature dependence functions for biological rates and different temperature size rules for body sizes. This effect of temperature can be integrated in the bioenergetic model using one of the functions described below. However, note that these functions should only be used when the user has a good understanding of the system modelled as some functions, under certain conditions, can lead to an erratic behavior of the bioenergetic model (instability, negative rates, etc.)."
},

{
    "location": "man/temperature/#Temperature-dependence-for-biological-rates-1",
    "page": "Temperature dependence",
    "title": "Temperature dependence for biological rates",
    "category": "section",
    "text": "The default behavior of the model will always be to assume that none of the biological rates are affected by temperature. If you wish to implement temperature dependence however, you can use one of the following functions:extended Eppley function (Bernhardt et al., 2018)\nexponential Boltzmann Arrhenius function\nextended Boltzmann Arrhenius function\nGaussian functionThese functions determine the shape of the thermal curves used to scale the biological rates with temperature.Nota The exponential Boltzmann Arrhenius function is the most documented in the litterature, hence parameters have been measured for the different biological rates (conversely to other functions that are less used, or more specific to a type of organism). We thus encourage to choose the Boltzmann Arrhenius function when using the default parameters provided in the package, as parameters are better supported in the litterature."
},

{
    "location": "man/temperature/#General-example-1",
    "page": "Temperature dependence",
    "title": "General example",
    "category": "section",
    "text": "Each of the biological rates (growth, metabolism, attack rate and handling time) is defined as a keyword in model_parameters. Simply specify the function you want to use as the corresponding value (and the temperature of the system in degrees Kelvin):A = [0 1 0 ; 0 0 1 ; 0 0 0]\np = model_parameters(A, T = 290.0,\n                     growthrate = ExtendedEppley(:growth),\n                     metabolicrate = Gaussian(:metabolism),\n                     handlingtime = ExponentialBA(:handlingtime),\n                     attackrate = ExtendedBA(:attackrate))"
},

{
    "location": "man/temperature/#Extended-Eppley-1",
    "page": "Temperature dependence",
    "title": "Extended Eppley",
    "category": "section",
    "text": "Note that rates can be negative (outside of the thermal range) when using the extended Eppley function.Bernhardt et al. (2018) proposed an extension of the original model of Eppley (1972). Following this extension the thermal performance curve of rate q_i of species i is defined by the equation:q_i(T) = M_i^beta * m0 * exp(b * T) * (1 - (fracT - T_textopttextrange2)^2)Where M_i is the body mass of species i and T is the temperature in degrees Kelvin. The default parameters values are described for each rate below.Note that this function has originially been documented for phytoplankton growth rate in Eppley 1972. Although its shape is general and may be used for other organisms, parameters should be changed accordingly."
},

{
    "location": "man/temperature/#Growth-rate-1",
    "page": "Temperature dependence",
    "title": "Growth rate",
    "category": "section",
    "text": "For the growth rate, the parameters values are set to:Parameter Keyword Meaning Default values References\nβ β allometric exponent -0.25 Gillooly et al. 2002\nm0 maxrate_0 maximum growth rate observed at 273.15 K 0.81 Eppley 1972\nb eppley_exponent exponential rate of increase 0.0631 Eppley 1972\nz z location of the inflexion point of the function 298.15 NA\ntextrange range thermal breadth (range within which the rate is positive) 35 NATo use this function, initialize model_parameters() with ExtendedEppley(:growthrate) for the keyword growthrate:A = [0 1 0 ; 0 0 1 ; 0 0 0] #linear food chain\np = model_parameters(A, growthrate = ExtendedEppley(:growthrate), T = 290.0) #default parameters values\n# change the parameters values for the allometric exponent using a named tuple\np_newvalues = model_parameters(A, growthrate = ExtendedEppley(:growthrate, parameters_tuple = (β = -0.21,)), T = 290.0)"
},

{
    "location": "man/temperature/#Metabolic-rate-1",
    "page": "Temperature dependence",
    "title": "Metabolic rate",
    "category": "section",
    "text": "We use the same function as above for the metabolic rate, with the added possibility to have different parameters values for producers, vertebrates and invertebrates. The defaults are initially set to the same values for all metabolic types (see table above), but can be changed independently (see example below).A = [0 1 0 ; 0 0 1 ; 0 0 0] #linear food chain\np = model_parameters(A, metabolicrate = ExtendedEppley(:metabolicrate), T = 290.0) #default parameters values\n# change the parameters values for the allometric exponent using a named tuple\np_newvalues = model_parameters(A, metabolicrate = ExtendedEppley(:metabolicrate, parameters_tuple = (range_producer = 30, range_invertebrate = 40, range_vertebrate = 25)), T = 290.0)"
},

{
    "location": "man/temperature/#Exponential-Boltzmann-Arrhenius-1",
    "page": "Temperature dependence",
    "title": "Exponential Boltzmann Arrhenius",
    "category": "section",
    "text": "The Boltzmann Arrhenius model, following the Metabolic Theory in Ecology, describes the scaling of a biological rate (q) with temperature by:q_i(T) = q_0 * M^beta_i * exp(E-fracT_0 - TkT_0T)Where q_0 is the organisms state-dependent scaling coefficient, calculated for 1g at 20 degrees Celsius (273.15 degrees Kelvin), β is the rate specific allometric scaling exponent, E is the activation energy in eV (electronvolts) of the response, T_0 is the normalization temperature and k is the Boltzmann constant (8617 10^-5 eVK^-1). As for all other equations, T is the temperature and M_i is the typical adult body mass of species i.Nota In many papers, the logarithm of the scaling constant q_0 is provided. When using those parameters, you should then give the exponential of q_0 (exp(q_0)) in the parameters."
},

{
    "location": "man/temperature/#Growth-rate-2",
    "page": "Temperature dependence",
    "title": "Growth rate",
    "category": "section",
    "text": "For the growth rate, the parameters values are set to:Parameter Keyword Meaning Default values References\nr_0 norm_constant growth dependent scaling coefficient -exp(15.68) Savage et al. 2004, Binzer et al. 2012\nbeta_i β allometric exponent -0.25 Savage et al. 2004, Binzer et al. 2012\nE activation_energy activation energy -0.84 Savage et al. 2004, Binzer et al. 2012\nT_0 T0 normalization temperature (Kelvins) 293.15 Binzer et al. 2012To use this function, initialize model_parameters() with ExponentialBA(:growthrate) for the keyword growthrate:A = [0 1 0 ; 0 0 1 ; 0 0 0] #linear food chain\np = model_parameters(A, growthrate = ExponentialBA(:growthrate), T = 290.0) #default parameters values\n# change the parameters values for the allometric exponent using a named tuple\np_newvalues = model_parameters(A, growthrate = ExponentialBA(:growthrate, parameters_tuple = (β = -0.21,)), T = 290.0)"
},

{
    "location": "man/temperature/#Metabolic-rate-2",
    "page": "Temperature dependence",
    "title": "Metabolic rate",
    "category": "section",
    "text": "For the metabolic rate, the parameters values can be different for each metabolic types (producers, invertebrates and vertebrates). The defaults are initially set to the same value for all metabolic types (see table below), but can be changed independently (see example below).For the metabolic rate, the parameters values are set to:Parameter Keyword Meaning Default values References\nr_0 norm_constant_invertebrate growth dependent scaling coefficient -exp(16.54) Ehnes et al. 2011, Binzer et al. 2012\nr_0 norm_constant_vertebrate growth dependent scaling coefficient -exp(16.54) Ehnes et al. 2011, Binzer et al. 2012\nbeta_i β_invertebrate allometric exponent -0.31 Ehnes et al. 2011\nbeta_i β_vertebrate allometric exponent -0.31 Ehnes et al. 2011\nE activation_energy_invertebrate activation energy -0.69 Ehnes et al. 2011, Binzer et al. 2012\nE activation_energy_vertebrate activation energy -0.69 Ehnes et al. 2011, Binzer et al. 2012\nT_0 T0_invertebrate normalization temperature (Kelvins) 293.15 Binzer et al. 2012\nT_0 T0_vertebrate normalization temperature (Kelvins) 293.15 Binzer et al. 2012A = [0 1 0 ; 0 0 1 ; 0 0 0] #linear food chain\np = model_parameters(A, metabolicrate = ExponentialBA(:metabolicrate), T = 290.0) #default parameters values\n# change the parameters values for the allometric exponent using a named tuple\np_newvalues = model_parameters(A, metabolicrate = ExponentialBA(:metabolicrate, parameters_tuple = (T0_producer = 293.15, T0_invertebrate = 300.15, T0_vertebrate = 300.15)), T = 290.0)"
},

{
    "location": "man/temperature/#Attack-rate-1",
    "page": "Temperature dependence",
    "title": "Attack rate",
    "category": "section",
    "text": "The attack rate is defined not for each species but for each interacting pair. As such, the body-mass scaling depends on the masses of both the consumer and its resource and the allometric exponent can be different for producers, vertebrates and invertebrates. However, the temperature scaling affects only the consumers, thus, the parameters involved can be defined differently only for vertebrates and invertebrates. For more details, see the table below.Note: The body-mass allometric scaling (originally defined as M_i^beta) becomes M_j^beta_j * M_k^beta_k where j is the consumer and k its resource.Parameter Keyword Meaning Default values References\nr_0 norm_constant_invertebrate growth dependent scaling coefficient -exp(13.1) Rall et al. 2012, Binzer et al. 2016\nr_0 norm_constant_vertebrate growth dependent scaling coefficient -exp(13.1) Rall et al. 2012, Binzer et al. 2016\nbeta_i β_producer allometric exponent 0.25 Rall et al. 2012, Binzer et al. 2016\nbeta_i β_invertebrate allometric exponent -0.8 Rall et al. 2012, Binzer et al. 2016\nbeta_i β_vertebrate allometric exponent -0.8 Rall et al. 2012, Binzer et al. 2016\nE activation_energy_invertebrate activation energy -0.38 Rall et al. 2012, Binzer et al. 2016\nE activation_energy_vertebrate activation energy -0.38 Rall et al. 2012, Binzer et al. 2016\nT_0 T0_invertebrate normalization temperature (Kelvins) 293.15 Rall et al. 2012, Binzer et al. 2016\nT_0 T0_vertebrate normalization temperature (Kelvins) 293.15 Rall et al. 2012, Binzer et al. 2016To use this function, initialize model_parameters() with ExponentialBA(:attackrate) for the keyword attackrate:A = [0 1 0 ; 0 0 1 ; 0 0 0] #linear food chain\np = model_parameters(A, attackrate = ExponentialBA(:attackrate), T = 290.0) #default parameters values\n# change the parameters values for the allometric exponent using a named tuple\np_newvalues = model_parameters(A, attackrate = ExponentialBA(:attackrate, parameters_tuple = (T0_invertebrate = 300.15, T0_vertebrate = 300.15)), T = 290.0)"
},

{
    "location": "man/temperature/#Handling-time-1",
    "page": "Temperature dependence",
    "title": "Handling time",
    "category": "section",
    "text": "The handling time is defined not for each species but for each interacting pair. As such, the body-mass scaling depends on the masses of both the consumer and its resource and the allometric exponent can be different for producers, vertebrates and invertebrates. However, the temperature scaling affects only the consumers, thus, the parameters involved can be defined differently only for vertebrates and invertebrates. For more details, see the table below.Note: The body-mass allometric scaling (originally defined as M_i^beta) becomes M_j^beta_j * M_k^beta_k where j is the consumer and k its resource.Parameter Keyword Meaning Default values References\nr_0 norm_constant_invertebrate growth dependent scaling coefficient exp(9.66) Rall et al. 2012, Binzer et al. 2016\nr_0 norm_constant_vertebrate growth dependent scaling coefficient exp(9.66) Rall et al. 2012, Binzer et al. 2016\nbeta_i β_producer allometric exponent -0.45 Rall et al. 2012, Binzer et al. 2016\nbeta_i β_invertebrate allometric exponent 0.47 Rall et al. 2012, Binzer et al. 2016\nbeta_i β_vertebrate allometric exponent 0.47 Rall et al. 2012, Binzer et al. 2016\nE activation_energy_invertebrate activation energy 0.26 Rall et al. 2012, Binzer et al. 2016\nE activation_energy_vertebrate activation energy 0.26 Rall et al. 2012, Binzer et al. 2016\nT_0 T0_invertebrate normalization temperature (Kelvins) 293.15 Rall et al. 2012, Binzer et al. 2016\nT_0 T0_vertebrate normalization temperature (Kelvins) 293.15 Rall et al. 2012, Binzer et al. 2016To use this function, initialize model_parameters() with ExponentialBA(:handlingtime) for the keyword handlingtime:A = [0 1 0 ; 0 0 1 ; 0 0 0] #linear food chain\np = model_parameters(A, handlingtime = ExponentialBA(:handlingtime), T = 290.0) #default parameters values\n# change the parameters values for the allometric exponent using a named tuple\np_newvalues = model_parameters(A, handlingtime = ExponentialBA(:handlingtime, parameters_tuple = (T0_vertebrate = 300.15, β_producer = -0.25)), T = 290.0)"
},

{
    "location": "man/temperature/#Extended-Boltzmann-Arrhenius-1",
    "page": "Temperature dependence",
    "title": "Extended Boltzmann Arrhenius",
    "category": "section",
    "text": "To describe a more classical unimodal relationship of biological rates with temperature, one can also use the extended Boltzmann Arrhenius function. This is an extension based on the Johnson and Lewin model to describe the decrease in biological rates at higher temperatures (and is still based on chemical reaction kinetics).q_i(T) = exp(q_0) * M^beta_i * exp(fracEkT * l(T))Where l(T) is :l(T) = frac11 + expfrac-1kT + (fracE_DT_opt + k * ln(fracEE_D - E))"
},

{
    "location": "man/temperature/#Growth-rate-3",
    "page": "Temperature dependence",
    "title": "Growth rate",
    "category": "section",
    "text": "For the growth rate, the parameters values are set to:Parameter Keyword Meaning Default values References\nr_0 norm_constant growth dependent scaling coefficient 18*10^9 NA\nbeta_i β allometric exponent -0.25 Gillooly et al. 2002\nE activation_energy activation energy 0.53 Dell et al 2011\nT_opt T_opt temperature at which trait value is maximal (Kelvins) 298.15 NA\nE_D deactivation_energy deactivation energy 1.15 Dell et al 2011To use this function, initialize model_parameters() with ExtendedBA(:growthrate) for the keyword growthrate:A = [0 1 0 ; 0 0 1 ; 0 0 0] #linear food chain\np = model_parameters(A, growthrate = ExtendedBA(:growthrate), T = 290.0) #default parameters values\n# change the parameters values for the allometric exponent using a named tuple\np_newvalues = model_parameters(A, growthrate = ExtendedBA(:growthrate, parameters_tuple = (T_opt = 300.15, )), T = 290.0)"
},

{
    "location": "man/temperature/#Metabolic-rate-3",
    "page": "Temperature dependence",
    "title": "Metabolic rate",
    "category": "section",
    "text": "For the metabolic rate, the parameters values can be different for each metabolic types (producers, invertebrates and vertebrates). The defaults are initially set to the same value for all metabolic types, but can be changed independently (see example below).For the metabolic rate, the parameters values are set to:Parameter Keyword Meaning Default values References\nr_0 norm_constant_producer growth dependent scaling coefficient for producers 15*10^9 NA\nr_0 norm_constant_invertebrate growth dependent scaling coefficient for invertebrates 15*10^9 NA\nr_0 norm_constant_vertebrate growth dependent scaling coefficient for vertebrates 15*10^9 NA\nbeta_i β_producer allometric exponent for producers -0.25 Gillooly et al. 2002\nbeta_i β_invertebrate allometric exponent for invertebrates -0.25 Gillooly et al. 2002\nbeta_i β_vertebrate allometric exponent for vertebrates -0.25 Gillooly et al. 2002\nE activation_energy_producer activation energy for producers 0.53 Dell et al 2011\nE activation_energy_invertebrate activation energy for invertebrates 0.53 Dell et al 2011\nE activation_energy_vertebrates activation energy for vertebrates 0.53 Dell et al 2011\nT_opt T_opt_producer temperature at which trait value is maximal (K) for producers 298.15 NA\nT_opt T_opt_invertebrate temperature at which trait value is maximal (K) for invertebrates 298.15 NA\nT_opt T_opt_vertebrate temperature at which trait value is maximal (K) for vertebrates 298.15 NA\nE_D deactivation_energy_producer deactivation energy for producers 1.15 Dell et al 2011\nE_D deactivation_energy_invertebrate deactivation energy for invertebrates 1.15 Dell et al 2011\nE_D deactivation_energy_vertebrate deactivation energy for invertebrates 1.15 Dell et al 2011A = [0 1 0 ; 0 0 1 ; 0 0 0] #linear food chain\np = model_parameters(A, metabolicrate = ExtendedBA(:metabolicrate), T = 290.0) #default parameters values\n# change the parameters values for the allometric exponent using a named tuple\np_newvalues = model_parameters(A, metabolicrate = ExtendedBA(:metabolicrate, parameters_tuple = (deactivation_energy_vertebrate = 1.02, T_opt_invertebrate = 293.15)), T = 290.0)"
},

{
    "location": "man/temperature/#Attack-rate-2",
    "page": "Temperature dependence",
    "title": "Attack rate",
    "category": "section",
    "text": "The attack rate is defined not for each species but for each interacting pair. As such, the body-mass scaling depends on the masses of both the consumer and its resource and the allometric exponent can be different for producers, vertebrates and invertebrates. However, the temperature scaling affects only the consumers, thus, the parameters involved can be defined differently only for vertebrates and invertebrates. For more details, see the table below.Note: The body-mass allometric scaling (originally defined as M_i^beta) becomes M_j^beta_j * M_k^beta_k where j is the consumer and k its resource.Parameter Keyword Meaning Default values References\nr_0 norm_constant_invertebrate growth dependent scaling coefficient 510^13 Bideault et al 2019\nr_0 norm_constant_vertebrate growth dependent scaling coefficient 510^13 Bideault et al 2019\nbeta_i β_producer allometric exponent 0.25 Gillooly et al., 2002\nbeta_i β_invertebrate allometric exponent 0.25 Gillooly et al., 2002\nbeta_i β_vertebrate allometric exponent 0.25 Gillooly et al., 2002\nE activation_energy_invertebrate activation energy 0.8 Dell et al 2011\nE activation_energy_vertebrate activation energy 0.8 Dell et al 2011\nE_D deactivation_energy_invertebrate deactivation energy 1.15 Dell et al 2011\nE_D deactivation_energy_vertebrate deactivation energy 1.15 Dell et al 2011\nT_opt T_opt_invertebrate normalization temperature (Kelvins) 298.15 NA\nT_opt T_opt_vertebrate normalization temperature (Kelvins) 298.15 NATo use this function, initialize model_parameters() with ExtendedBA(:attackrate) for the keyword attackrate:A = [0 1 0 ; 0 0 1 ; 0 0 0] #linear food chain\np = model_parameters(A, attackrate = ExtendedBA(:attackrate), T = 290.0) #default parameters values\n# change the parameters values for the allometric exponent using a named tuple\np_newvalues = model_parameters(A, attackrate = ExtendedBA(:attackrate, parameters_tuple = (deactivation_energy_vertebrate = 1.02, T_opt_invertebrate = 293.15))), T = 290.0)"
},

{
    "location": "man/temperature/#Gaussian-1",
    "page": "Temperature dependence",
    "title": "Gaussian",
    "category": "section",
    "text": "A simple gaussian function (or inverted gaussian function depending on the rate) has also been used in studies to model the scaling of biological rates with temperature. This can be formalized by the following equation:q_i(T) = M_i^beta * q_opt * exppm (frac(T - T_opt)^22s_q^2)"
},

{
    "location": "man/temperature/#Growth-rate-4",
    "page": "Temperature dependence",
    "title": "Growth rate",
    "category": "section",
    "text": "For the organisms growth, the default parameters values are:Parameter Keyword Meaning Default values References\nq_opt \'norm_constant\' maximal trait value (at T_opt) 1.0 NA\nT_opt \'T_opt\' temperature at which trait value is maximal 298.15 Amarasekare 2015\ns_q \'range\' performance breath (width of function) 20 Amarasekare 2015\nbeta \'β\' allometric exponent -0.25 Gillooly et al 2002To use this function initialize model_parameters() with Gaussian(:growthrate) for the keyword growthrate:A = [0 1 0 ; 0 0 1 ; 0 0 0] #linear food chain\np = model_parameters(A, growthrate = Gaussian(:growthrate), T = 290.0) #default parameters values\n# change the parameters values for the allometric exponent using a named tuple\np_newvalues = model_parameters(A, growthrate = Gaussian(:growthrate, parameters_tuple = (T_opt = 300.15, )), T = 290.0)"
},

{
    "location": "man/temperature/#Metabolic-rate-4",
    "page": "Temperature dependence",
    "title": "Metabolic rate",
    "category": "section",
    "text": "For the metabolic rate, the parameters values can be different for each metabolic types (producers, invertebrates and vertebrates). The defaults are initially set to the same value for all metabolic types, but can be changed independently (see example below).For the metabolic rate, the default parameters values are:Parameter Keyword Meaning Default values References\nq_opt \'normconstantproducer\' maximal trait value (at T_opt) for producers 0.2 NA\nq_opt \'normconstantinvertebrate\' maximal trait value (at T_opt) for invertebrates 0.35 NA\nq_opt \'normconstantvertebrate\' maximal trait value (at T_opt) for vertebrates 0.9 NA\nT_opt \'Toptproducer\' temperature at which trait value is maximal for producers 298.15 Amarasekare 2015\nT_opt \'Toptinvertebrate\' temperature at which trait value is maximal for invertebrates 298.15 Amarasekare 2015\nT_opt \'Toptvertebrate\' temperature at which trait value is maximal for vertebrates 298.15 Amarasekare 2015\ns_q \'range_producer\' performance breath (width of function) for producers 20 Amarasekare 2015\ns_q \'range_invertebrate\' performance breath (width of function) for invertebrates 20 Amarasekare 2015\ns_q \'range_vertebrate\' performance breath (width of function) for vertebrates 20 Amarasekare 2015\nbeta \'β_producer\' allometric exponent for producers -0.25 Gillooly et al 2002\nbeta \'β_invertebrate\' allometric exponent for vertebrates -0.25 Gillooly et al 2002\nbeta \'β_vertebrate\' allometric exponent for vertebrates -0.25 Gillooly et al 2002To use this function initialize model_parameters() with Gaussian(:metabolicrate) for the keyword metabolicrate:A = [0 1 0 ; 0 0 1 ; 0 0 0] #linear food chain\np = model_parameters(A, metabolicrate = Gaussian(:metabolicrate), T = 290.0) #default parameters values\n# change the parameters values for the allometric exponent using a named tuple\np_newvalues = model_parameters(A, metabolicrate = Gaussian(:metabolicrate, parameters_tuple = (T_opt_producer = 293.15, β_invertebrate = -0.3)), T = 290.0)"
},

{
    "location": "man/temperature/#Attack-rate-3",
    "page": "Temperature dependence",
    "title": "Attack rate",
    "category": "section",
    "text": "The attack rate is defined not for each species but for each interacting pair. As such, the body-mass scaling depends on the masses of both the consumer and its resource and the allometric exponent can be different for producers, vertebrates and invertebrates. However, the temperature scaling affects only the consumers, thus, the parameters involved can be defined differently only for vertebrates and invertebrates.Note: The body-mass allometric scaling (originally defined as M_i^beta) becomes M_j^beta_j * M_k^beta_k where j is the consumer and k its resource.For the attack rate, the default parameters values are:Parameter Keyword Meaning Default values References\nq_opt \'normconstantinvertebrate\' maximal trait value (at T_opt) for invertebrates 16 NA\nq_opt \'normconstantvertebrate\' maximal trait value (at T_opt) for vertebrates 16 NA\nT_opt \'Toptinvertebrate\' temperature at which trait value is maximal for invertebrates 298.15 Amarasekare 2015\nT_opt \'Toptvertebrate\' temperature at which trait value is maximal for vertebrates 298.15 Amarasekare 2015\ns_q \'range_invertebrate\' performance breath (width of function) for invertebrates 20 Amarasekare 2015\ns_q \'range_vertebrate\' performance breath (width of function) for vertebrates 20 Amarasekare 2015\nbeta \'β_producer\' allometric exponent for producers -0.25 Gillooly et al 2002\nbeta \'β_invertebrate\' allometric exponent for vertebrates -0.25 Gillooly et al 2002\nbeta \'β_vertebrate\' allometric exponent for vertebrates -0.25 Gillooly et al 2002To use this function initialize model_parameters() with Gaussian(:attackrate) for the keyword attackrate:A = [0 1 0 ; 0 0 1 ; 0 0 0] #linear food chain\np = model_parameters(A, attackrate = Gaussian(:attackrate), T = 290.0) #default parameters values\n# change the parameters values for the allometric exponent using a named tuple\np_newvalues = model_parameters(A, attackrate = Gaussian(:attackrate, parameters_tuple = (range_vertebrate = 25, range_invertebrate = 30)), T = 290.0)"
},

{
    "location": "man/temperature/#Handling-time-2",
    "page": "Temperature dependence",
    "title": "Handling time",
    "category": "section",
    "text": "The handling time is defined not for each species but for each interacting pair. As such, the body-mass scaling depends on the masses of both the consumer and its resource and the allometric exponent can be different for producers, vertebrates and invertebrates. However, the temperature scaling affects only the consumers, thus, the parameters involved can be defined differently only for vertebrates and invertebrates. For more details, see the table below.Nota 1: The body-mass allometric scaling (originally defined as M_i^beta) becomes M_j^beta_j * M_k^beta_k where j is the consumer and k its resource.Nota 2: The handling time is the only rate for which an inverted gaussian is used (the handling time becomes more optimal by decreasing).For the handing time, the default parameters values are:Parameter Keyword Meaning Default values References\nq_opt \'normconstantinvertebrate\' maximal trait value (at T_opt) for invertebrates 0.125 NA\nq_opt \'normconstantvertebrate\' maximal trait value (at T_opt) for vertebrates 0.125 NA\nT_opt \'Toptinvertebrate\' temperature at which trait value is maximal for invertebrates 298.15 Amarasekare 2015\nT_opt \'Toptvertebrate\' temperature at which trait value is maximal for vertebrates 298.15 Amarasekare 2015\ns_q \'range_invertebrate\' performance breath (width of function) for invertebrates 20 Amarasekare 2015\ns_q \'range_vertebrate\' performance breath (width of function) for vertebrates 20 Amarasekare 2015\nbeta \'β_producer\' allometric exponent for producers -0.25 Gillooly et al 2002\nbeta \'β_invertebrate\' allometric exponent for vertebrates -0.25 Gillooly et al 2002\nbeta \'β_vertebrate\' allometric exponent for vertebrates -0.25 Gillooly et al 2002To use this function initialize model_parameters() with ExponentialBA(:handlingtime) for the keyword handlingtime:A = [0 1 0 ; 0 0 1 ; 0 0 0] #linear food chain\np = model_parameters(A, handlingtime = Gaussian(:handlingtime), T = 290.0) #default parameters values\n# change the parameters values for the allometric exponent using a named tuple\np_newvalues = model_parameters(A, handlingtime = Gaussian(:handlingtime, parameters_tuple = (T0_vertebrate = 300.15, β_producer = -0.25)), T = 290.0)"
},

{
    "location": "man/temperature/#Temperature-dependence-for-body-sizes-1",
    "page": "Temperature dependence",
    "title": "Temperature dependence for body sizes",
    "category": "section",
    "text": "The default behavior of the model is to assume, as it does for biological rates, that typical adults body sizes are not affected by temperature. In this case, the bodymass vector can either:be provided to model_parameters through the keyword bodymass: model_parameters(A, bodymass = [...])\nbe calculated by model_parameters as Mi= Z^(TR_i-1) where TR_i is the trophic level of species i and Z is the typical consumer-resource body mass ratio in the system. Z can be passed to model_parameters by using the Z keyword: model_parameters(A, Z = 10.0)\nbe a vector of dry masses (at 293.15 Kelvins) provided by the user: model_parameters(A, dry_mass_293 = [...])If multiple keywords are provided, the model will use this order of priority: body masses, dry masses, Z.To simulate the effect of temperature on body masses, the model uses the following general formula, following Forster and Hirst 2012:M_i(T) = m_i * exp(log_10(PCM  100 + 1) * T - 29315)Where M_i is the body mass of species i, T is the temperature (in Kelvins), m_i is the body mass when there is no effect of temperature (provided by the user through Z, bodymass or dry_mass_293) and PCM is the Percentage change in body-mass per degree Celsius. This percentage is calculated differently depending on the type of system or the type of response wanted (Forster and Hirst 2012, Sentis et al 2017):Mean Aquatic Response: PCM = -390 - 053 * log_10(dm) where dm is the dry mass (calculated in the model from Z or wet mass if not provided). Body size decreases with temperature.\nMean Terrestrial Response: PCM = -172 + 054 * log_10(dm) where dm is the dry mass (calculated in the model from Z or wet mass if not provided). Body size decreases with temperature.\nMaximum Response: PCM = -8. Body size decreases with temperature.\nReverse Response: PCM = 4. Body size increases with temperature.To set the temperature size rule, use the TSR keyword in model_parameters:A = [0 1 1 ; 0 0 1 ; 0 0 0] #omnivory motif\np_aqua = model_parameters(A, T = 290.0, TSR = :mean_aquatic) #mean aquatic, wet and dry masses calculated from Z and trophic levels (Z default value is 1.0)\np_terr = model_parameters(A, T = 290.0, TSR = :mean_terrestrial, bodymass = [26.3, 15.2, 4.3]) #mean terrestrial, typical wet masses (at 20 degrees C) are provided and will we used to estimate dry masses and wet masses at T degrees K.\np_max = model_parameters(A, T = 290.0, TSR = :maximum, dry_mass_293 = [1.8, 0.7, 0.2]) #maximum, dry masses are provided and will be used by the temperature size rule to calculate wet masses at T degrees K.\np_rev =  model_parameters(A, T = 290.0, TSR = :maximum, Z = 10.0) #reverse - masses increase with T, wet and dry masses calculated from Z and trophic levels."
},

{
    "location": "man/temperature/#References-1",
    "page": "Temperature dependence",
    "title": "References",
    "category": "section",
    "text": "Amarasekare, P. (2015). Effects of temperature on consumer–resource interactions. Journal of Animal Ecology, 84(3), 665-679.Bideault, A., Loreau, M., & Gravel, D. (2019). Temperature modifies consumer-resource interaction strength through its effects on biological rates and body mass. Frontiers in Ecology and Evolution, 7, 45.Bernhardt, J. R., Sunday, J. M., Thompson, P. L., & O\'Connor, M. I. (2018). Nonlinear averaging of thermal experience predicts population growth rates in a thermally variable environment. Proceedings of the Royal Society B: Biological Sciences, 285(1886), 20181076.Binzer, A., Guill, C., Brose, U., & Rall, B. C. (2012). The dynamics of food chains under climate change and nutrient enrichment. Philosophical Transactions of the Royal Society B: Biological Sciences, 367(1605), 2935-2944.Binzer, A., Guill, C., Rall, B. C., & Brose, U. (2016). Interactive effects of warming, eutrophication and size structure: impacts on biodiversity and food‐web structure. Global change biology, 22(1), 220-227.Brose, U., Williams, R. J., & Martinez, N. D. (2006). Allometric scaling enhances stability in complex food webs. Ecology letters, 9(11), 1228-1236.Englund, G., Öhlund, G., Hein, C. L., & Diehl, S. (2011). Temperature dependence of the functional response. Ecology letters, 14(9), 914-921.Eppley, R. W. (1972). Temperature and phytoplankton growth in the sea. Fish. bull, 70(4), 1063-1085.Forster, J., & Hirst, A. G. (2012). The temperature‐size rule emerges from ontogenetic differences between growth and development rates. Functional Ecology, 26(2), 483-492.Kremer, C. T., Thomas, M. K., & Litchman, E. (2017). Temperature‐and size‐scaling of phytoplankton population growth rates: Reconciling the Eppley curve and the metabolic theory of ecology. Limnology and Oceanography, 62(4), 1658-1670.Rall, B. C., Brose, U., Hartvig, M., Kalinkat, G., Schwarzmüller, F., Vucic-Pestic, O., & Petchey, O. L. (2012). Universal temperature and body-mass scaling of feeding rates. Philosophical Transactions of the Royal Society B: Biological Sciences, 367(1605), 2923-2934.Sentis, A., Binzer, A., & Boukal, D. S. (2017). Temperature‐size responses alter food chain persistence across environmental gradients. Ecology letters, 20(7), 852-862."
},

]}
