using befwm

A = [0 1 1 0; 0 0 0 1; 0 0 0 1; 0 0 0 0]
p = make_initial_parameters(A)
p = make_parameters(p)

println(simulate(p, rand(4)))
