"""
**Check Rewiring parameters**

This function will check that all the required rewiring parameters are present
"""

function check_rewiring_parameters(rewireP,rewireMethod)
  if rewireMethod == :ADBM
    required_keys = [
    :e,
    :a_adbm,
    :ai,
    :aj,
    :b,
    :h_adbm,
    :hi,
    :hj,
    :n,
    :ni,
    :Nmethod,
    :Hmethod,
    :rewire_method,
    :costMat]
  elseif rewireMethod == :Gilljam
    required_keys = [
    :rewire_method,
    :similarity,
    :specialistPrefMag,
    :extinctions,
    :preferenceMethod,
    :cost,
    :costMat,
    :specialistPref]
  elseif rewireMethod == :stan
    required_keys = [
    :rewire_method,
    :extinctions]
  end

  if rewireMethod ∈ [:Gilljam, :ADBM, :stan]
    for k in required_keys
      @assert get(rewireP, k, nothing) != nothing
    end
  end

end
