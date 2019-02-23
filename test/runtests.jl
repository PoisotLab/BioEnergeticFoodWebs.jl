using BioEnergeticFoodWebs
using Test

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
    "rewiring/StaniczenkoRewire.jl",
    "consumption.jl",
    "biological_rates.jl",
    "temperature_size.jl"
]

test_n = 1
anyerrors = false

for current_test in test_files
    try
        include(current_test)
        println("\033[1m\033[32mPASSED\033[0m\t$(current_test)")
    catch e
        global anyerrors = true
        println("\033[1m\033[31mFAILED\033[0m\t$(current_test)")
        showerror(stdout, e, backtrace())
        println()
        throw("TEST FAILED")
    end
    global test_n += 1
end


if anyerrors
    throw("Test failed")
end
