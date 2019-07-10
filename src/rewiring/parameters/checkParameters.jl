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
  elseif rewireMethod ∈ [:Gilljam, :DS]
    required_keys = [
    :rewire_method,
    :similarity,
    :specialistPrefMag,
    :extinctions,
    :preferenceMethod,
    :cost,
    :costMat,
    :specialistPref]
  elseif rewireMethod ∈ [:stan, :DO]
    required_keys = [
    :rewire_method,
    :extinctions]
  end

  if rewireMethod ∈ [:Gilljam, :ADBM, :stan, :DO, :DS]
    for k in required_keys
      @assert get(rewireP, k, nothing) != nothing
    end
  end

end
