using Sundials
#=using DataFrames=#
#=using Gadfly=#

include("utils.jl")
include("ode.jl")

A = omnivory


# Done!

biomass = rand(S)
derivative = zeros(Float64, S)
start = 0
stop = 200
steps = 100
t = collect(linspace(start, stop, stop * steps))
f(t, y, ydot) = dBdt(t, y, ydot, p)
data = Sundials.cvode(f, biomass, t)

using Gadfly
p1 = plot(x=t, y=data[:,1], Geom.line)
p2 = plot(x=t, y=data[:,2], Geom.line)
p3 = plot(x=t, y=data[:,3], Geom.line)
p4 = plot(x=t, y=data[:,1]+data[:,2]+data[:,3], Geom.line)

draw(PNG("a.png", 30cm, 20cm), vstack(hstack(p1, p2), hstack(p3, p4)))
