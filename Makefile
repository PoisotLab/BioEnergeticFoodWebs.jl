NAME=befwm
V=0.4
FOLD=~/.julia/v$(V)/$(NAME)

.PHONY: clean

clean:
	- rm src/*cov

install: src/*jl test/*jl
	-julia -e 'Pkg.rm("$(NAME)")'
	-julia -e 'Pkg.clone(pwd())'


test: install
	julia --code-coverage test/runtests.jl

coverage: test
	cd $(FOLD); julia -e 'Pkg.add("Coverage"); using Coverage; coverage = process_folder(); covered_lines, total_lines = get_summary(coverage); println(round(covered_lines/total_lines*100,2),"% covered")'

doc:
	julia -e 'Pkg.add("Lexicon"); using Lexicon; using befwm; save("doc/api.md", befwm)'

