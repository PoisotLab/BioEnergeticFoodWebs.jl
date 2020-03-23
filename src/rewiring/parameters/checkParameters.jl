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
    :adbm_trigger,
    :costMat,
    :extinctions,
    :extinctionstime,
    :tmpA]
    if rewireP[:adbm_trigger] == :interval
      append!(required_keys, [:adbm_interval, :rewiretime])
    end
  elseif rewireMethod ∈ [:Gilljam, :DS]
    required_keys = [
    :rewire_method,
    :similarity,
    :specialistPrefMag,
    :extinctions,
    :extinctionstime,
    :tmpA,
    :preferenceMethod,
    :cost,
    :costMat,
    :specialistPref]
  elseif rewireMethod ∈ [:stan, :DO]
    required_keys = [
    :rewire_method,
    :extinctions,
    :extinctionstime,
    :tmpA]
  end

  if rewireMethod ∈ [:Gilljam, :ADBM, :stan, :DO, :DS]
    for k in required_keys
      @assert get(rewireP, k, nothing) != nothing
    end
  end

end
