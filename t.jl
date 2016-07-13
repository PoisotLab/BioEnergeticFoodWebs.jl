using befwm

A = nichemodel(10, 0.3)
p = model_parameters(A)
b = rand(10)

s = simulate(p, b)
