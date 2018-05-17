using BioEnergeticFoodWebs
using Base.Test

anyerrors = false

test_files = [
    "trophic_rank.jl",
    "checks.jl",
    "make_parameters.jl",
    "simulate.jl",
    "random.jl",
    "measures.jl",
    "rewiring/ADBM.jl",
    "rewiring/GilljamRewire.jl",
    "rewiring/StaniczenkoRewire.jl"
]

for current_test in test_files
    try
        include(current_test)
        println("\033[1m\033[32mPASSED\033[0m\t$(current_test)")
    catch e
        anyerrors = true
        println("\033[1m\033[31mFAILED\033[0m\t$(current_test)")
        showerror(STDOUT, e, backtrace())
        println()
    end
end


if anyerrors
    throw("Test failed")
end
