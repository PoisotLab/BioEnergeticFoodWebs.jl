module TestTrophicRank
    using Test
    using BioEnergeticFoodWebs

    food_chain = [0 0 0;0 0 1; 1 0 0]
    @assert trophic_rank(food_chain) == vec([1.0 3.0 2.0])

    food_chain = [0 1 0; 0 0 1; 0 0 0]
    @assert trophic_rank(food_chain) == vec([3.0 2.0 1.0])

    omnivory = [0 1 1; 0 0 1; 0 0 0]
    @assert trophic_rank(omnivory) == vec([2.5 2.0 1.0])

    diamond = [0 1 1 0; 0 0 0 1; 0 0 0 1; 0 0 0 0]
    @assert trophic_rank(diamond) == vec([3.0 2.0 2.0 1.0])

    chain_four = [0 1 0 0; 0 0 1 0; 0 0 0 1; 0 0 0 0]
    @assert trophic_rank(chain_four) == vec([4.0 3.0 2.0 1.0])

    @assert trophic_rank(zeros(Int64, (3, 3))) == ones(3)

end
