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
function check_temperature_parameters(fname::String, passed_temp_parameters::NamedTuple)
    #list the parameters required for each biological rate and for each temperature effect function
    if fname == "no_effect_x"
      required_parameters = [:a_vertebrate, :a_invertebrate, :a_producer]
    elseif fname == "no_effect_r"
      required_parameters = [:r]
    elseif fname == "no_effect_handlingt"
      required_parameters = [:y_vertebrate, :y_invertebrate]
    elseif fname == "no_effect_attackr"
      required_parameters = [:Γ]
    elseif fname == "extended_eppley_r"
      required_parameters = [:maxrate_0, :eppley_exponent, :T_opt, :range, :β]
    elseif fname == "extended_eppley_x"
      required_parameters = [:maxrate_0_producer, :maxrate_0_invertebrate, :maxrate_0_vertebrate,
                      :eppley_exponent_producer, :eppley_exponent_invertebrate, :eppley_exponent_vertebrate,
                      :T_opt_producer, :T_opt_invertebrate, :T_opt_vertebrate,
                      :range_producer, :range_invertebrate, :range_vertebrate,
                      :β_producer, :β_invertebrate, :β_vertebrate]
    elseif fname == "exponential_BA_r"
      required_parameters = [:norm_constant, :activation_energy, :T0, :β, :k, :T0K]
    elseif fname == "exponential_BA_x"
      required_parameters = [:norm_constant_producer, :norm_constant_invertebrate, :norm_constant_vertebrate,
                     :activation_energy_producer, :activation_energy_invertebrate, :activation_energy_vertebrate,
                     :T0_producer, :T0_invertebrate, :T0_vertebrate,
                     :β_producer, :β_invertebrate, :β_vertebrate]
    elseif fname == "exponential_BA_functionalr"
      required_parameters = [:norm_constant_invertebrate, :norm_constant_vertebrate,
                  :activation_energy_invertebrate, :activation_energy_vertebrate,
                  :T0_invertebrate, :T0_vertebrate,
                  :β_producer, :β_invertebrate, :β_vertebrate]
    elseif fname == "extended_BA_r"
      required_parameters = [:norm_constant, :activation_energy, :T0, :β, :deactivation_energy]
    elseif fname == "extended_BA_x"
      required_parameters = [:norm_constant_producer, :norm_constant_invertebrate, :norm_constant_vertebrate,
                     :activation_energy_producer, :activation_energy_invertebrate, :activation_energy_vertebrate,
                     :deactivation_energy_producer, :deactivation_energy_invertebrate, :deactivation_energy_vertebrate,
                     :T_opt_producer, :T_opt_invertebrate, :T_opt_vertebrate,
                     :β_producer, :β_invertebrate, :β_vertebrate]
    elseif fname == "extended_BA_attackr"
      required_parameters = [:norm_constant_invertebrate, :norm_constant_vertebrate,
                     :activation_energy_invertebrate, :activation_energy_vertebrate,
                     :deactivation_energy_invertebrate, :deactivation_energy_vertebrate,
                     :T_opt_invertebrate, :T_opt_vertebrate,
                     :β_producer, :β_invertebrate, :β_vertebrate]
    elseif fname == "gaussian_r"
      required_parameters = [:shape, :norm_constant, :range, :T_opt, :β]
    elseif fname == "gaussian_x"
      required_parameters = [:norm_constant_producer, :norm_constant_invertebrate, :norm_constant_vertebrate,
                     :T_opt_producer, :T_opt_invertebrate, :T_opt_vertebrate,
                     :β_producer, :β_invertebrate, :β_vertebrate,
                     :range_producer, :range_invertebrate, :range_vertebrate]
    elseif fname == "gaussian_functionalr"
      required_parameters = [:shape,
                  :norm_constant_invertebrate, :norm_constant_vertebrate,
                  :T_opt_invertebrate, :T_opt_vertebrate,
                  :β_producer, :β_invertebrate, :β_vertebrate]
    end
    # assert that there are no additional parameter
    for temperature_parameter in collect(keys(passed_temp_parameters)) ; @assert temperature_parameter ∈ required_parameters ; end
    # assert that each parameter has a value
    for required_temp_parameters in required_parameters ; @assert get(passed_temp_parameters, required_temp_parameters, nothing) != nothing ; end
end
