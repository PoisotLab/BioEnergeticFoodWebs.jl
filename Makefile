NAME=BioEnergeticFoodWebs
V=0.5
FOLD=~/.julia/v$(V)/$(NAME)
JEXEC=julia


.DEFAULT_GOAL := help

.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

wipe: ## Remove the package if installed
	- julia -e 'Pkg.rm("$(NAME)")'

.PHONY: clean
clean: ## Clean the test directory and remove test artifacts
	- rm src/*cov

.PHONY: install
install: src/*jl test/*jl ## Install the package in the specified julia version (removes before if already present)
	-julia -e 'Pkg.rm("$(NAME)")'
	-julia -e 'Pkg.clone(pwd())'

test: src/*jl test/*jl ## Run the tests
	$(JEXEC) -e 'include("src/BioEnergeticFoodWebs.jl"); include("test/runtests.jl")'

coverage: test ## Perform the code coverage analysis
	cd $(FOLD); julia -e 'Pkg.add("Coverage"); using Coverage; coverage = process_folder(); covered_lines, total_lines = get_summary(coverage); println(round(covered_lines/total_lines*100,2),"% covered")'
