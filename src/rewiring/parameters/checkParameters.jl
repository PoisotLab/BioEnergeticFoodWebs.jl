"""
**Check Rewiring parameters**

This function will check that all the required rewiring parameters are present
"""

function check_rewiring_parameters(rewireP,rewireMethod)
  if rewireMethod == :ADBM
    required_keys = [
    :e,
    :a,
    :ai,
    :aj,
    :b,
    :h,
    :hi,
    :hj,
    :n,
    :ni,
    :Nmethod,
    :Hmethod,
    :rewireMethod,
    :costMat]
  elseif rewireMethod == :Gilljam
    required_keys = [
    :rewireMethod,
    :similarity,
    :specialistPrefMag,
    :extinctions,
    :preferenceMethod,
    :cost,
    :costMat,
    :specialistPref]
  end

  for k in required_keys
    @assert get(rewireP, k, nothing) != nothing
  end

end
