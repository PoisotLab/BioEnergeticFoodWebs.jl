"""
**Is the matrix correctly formatted?**

A *correct* matrix has only 0 and 1, two dimensions, and is square.

This function returns nothing, but raises an `AssertionError` if one of the
conditions is not met.
"""
function check_food_web(A)
  @assert size(A)[1] == size(A)[2]
  @assert length(size(A)) == 2
  @assert sum(map(x -> x ∉ [0 1], A)) == 0
end

"""
**Check initial parameters**
"""
function check_initial_parameters(parameters)
  required_keys = [
    :Z,
    :vertebrates,
    #:a_vertebrate,
    #:a_invertebrate,
    #:a_producer,
    #:m_producer,
    #:y_vertebrate,
    #:y_invertebrate,
    :e_herbivore,
    :e_carnivore,
    :h,
    #:Γ,
    :c,
    #:r,
    :K
  ]
  for k in required_keys
    @assert get(parameters, k, nothing) != nothing
  end
end

"""
**Are the simulation parameters present?**

This function will make sure that all the required parameters are here,
and that the arrays and matrices have matching dimensions.
"""
function check_parameters(parameters)
  check_initial_parameters(parameters)

  required_keys = [
    :w,
    :efficiency,
    :y,
    :x,
    #:a,
    :is_herbivore,
    :is_producer
  ]
  for k in required_keys
    @assert get(parameters, k, nothing) != nothing
  end
  @assert length(parameters[:is_producer]) == length(parameters[:is_herbivore])
  @assert size(parameters[:A]) == size(parameters[:efficiency])
  @assert length(parameters[:is_producer]) == size(parameters[:A], 1)
end

"""
TODO
"""
function check_temperature_parameters(rate::Symbol, tp::NamedTuple)
    #list the parameters required for each biological rate and for each temperature effect function
    #GROWTH
    growth_noeffect = [tp.r]
    growth_eppley = [tp.maxrate_0, tp.eppley_exponent, tp.T_opt, tp.range, tp.β]
    growth_expBA = [tp.norm_constant, tp.activation_energy, tp.T0, tp.β, tp.k, tp.T0K]
    growth_extBA = [tp.norm_constant, tp.activation_energy, tp.T0, tp.β, tp.deactivation_energy]
    growth_gauss = [tp.shape, tp.norm_constant, tp.range, tp.T_opt, tp.β]
    #METABOLISM
    metab_noeffect = [tp.a_vertebrate, tp.a_invertebrate, tp.a_producer]
    metab_eppley = [tp.maxrate_0_producer, tp.maxrate_0_invertebrate, tp.maxrate_0_vertebrate,
                    tp.eppley_exponent_producer, tp.eppley_exponent_invertebrate, eppley_exponent_vertebrate,
                    tp.T_opt_producer, tp.T_opt_invertebrate, tp.T_opt_vertebrate,
                    tp.range_producer, tp.range_invertebrate, tp.range_vertebrate,
                    tp.β_producer, tp.β_invertebrate, β_vertebrate]
    metab_expBA = [tp.norm_constant_producer, tp.norm_constant_invertebrate, tp.norm_constant_vertebrate,
                   tp.activation_energy_producer, tp.activation_energy_invertebrate, tp.activation_energy_vertebrate,
                   tp.T0_producer, tp.T0_invertebrate, tp.T0_vertebrate,
                   tp.β_producer, tp.β_invertebrate, tp.β_vertebrate]
    metab_extBA = [tp.norm_constant_producer, tp.norm_constant_invertebrate, tp.norm_constant_vertebrate,
                   tp.activation_energy_producer, tp.activation_energy_invertebrate, tp.activation_energy_vertebrate,
                   tp.deactivation_energy_producer, tp.deactivation_energy_invertebrate, tp.deactivation_energy_vertebrate,
                   tp.T_opt_producer, tp.T_opt_invertebrate, tp.T_opt_vertebrate,
                   tp.β_producer, tp.β_invertebrate, tp.β_vertebrate]
    metab_gauss = [tp.norm_constant_producer, tp.norm_constant_invertebrate, tp.norm_constant_vertebrate,
                   tp.T_opt_producer, tp.T_opt_invertebrate, tp.T_opt_vertebrate,
                   tp.β_producer, tp.β_invertebrate, tp.β_vertebrate,
                   tp.range_producer tp.range_invertebrate tp.range_vertebrate]
    #ATTACK
    attack_noeffect = [tp.Γ]
    attack_extBA = [tp.norm_constant_invertebrate, tp.norm_constant_vertebrate,
                   tp.activation_energy_invertebrate, tp.activation_energy_vertebrate,
                   tp.deactivation_energy_invertebrate, tp.deactivation_energy_vertebrate,
                   tp.T_opt_invertebrate, tp.T_opt_vertebrate,
                   tp.β_producer, tp.β_invertebrate, tp.β_vertebrate]
    #HANDLING TIME
    handling_noeffect = [tp.y_vertebrate, tp.y_invertebrate]
    #FUNCTIONAL RESPONSE
    fr_expBA = [tp.norm_constant_invertebrate, tp.norm_constant_vertebrate,
                tp.activation_energy_invertebrate, tp.activation_energy_vertebrate,
                tp.T0_invertebrate, tp.T0_vertebrate,
                tp.β_producer, tp.β_invertebrate, tp.β_vertebrate]
    fr_gauss = [tp.shape,
                tp.norm_constant_invertebrate, tp.norm_constant_vertebrate,
                tp.T_opt_invertebrate, tp.T_opt_vertebrate,
                tp.β_producer, tp.β_invertebrate, tp.β_vertebrate]
end
