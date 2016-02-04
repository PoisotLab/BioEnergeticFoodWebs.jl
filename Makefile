.PHONY: clean

clean:
	- rm src/*cov

test: src/*jl test/*jl
	julia --code-coverage test/runtests.jl

coverage: test
	julia -e 'Pkg.add("Coverage"); using Coverage; coverage = process_folder(); covered_lines, total_lines = get_summary(coverage); println(round(covered_lines/total_lines*100,2),"% covered")'

