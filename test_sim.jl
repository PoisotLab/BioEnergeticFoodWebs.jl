using befwm

A = [0 1 1 0; 0 0 0 1; 0 0 0 1; 0 0 0 0]
p = A |> make_initial_parameters |> make_parameters

simulate(p, rand(4))
