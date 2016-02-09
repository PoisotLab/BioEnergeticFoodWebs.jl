# befwm

## Exported

---

<a id="method__check_food_web.1" class="lexicon_definition"></a>
#### check_food_web(A) [¶](#method__check_food_web.1)
**Is the matrix correctly formatted?**

A *correct* matrix has only 0 and 1, two dimensions, and is square.

This function returns nothing, but raises an `AssertionError` if one of the
conditions is not met.


*source:*
[befwm/src/checks.jl:9](file:///home/tpoisot/.julia/v0.4/befwm/src/checks.jl)

---

<a id="method__check_parameters.1" class="lexicon_definition"></a>
#### check_parameters(p) [¶](#method__check_parameters.1)
**Are the simulation parameters present?**

This function will make sure that all the required parameters are here,
and that the arrays and matrices have matching dimensions.


*source:*
[befwm/src/checks.jl:44](file:///home/tpoisot/.julia/v0.4/befwm/src/checks.jl)

---

<a id="method__dbdt.1" class="lexicon_definition"></a>
#### dBdt(t,  biomass,  derivative,  p::Dict{Symbol, Any}) [¶](#method__dbdt.1)
**Derivatives**

This function is the one wrapped by `Sundials`. Based on a timepoint `t`,
an array of biomasses `biomass`, an equally sized array of derivatives
`derivative`, and a series of simulation parameters `p`, it will return
`dB/dt` for every species.


*source:*
[befwm/src/dBdt.jl:65](file:///home/tpoisot/.julia/v0.4/befwm/src/dBdt.jl)

---

<a id="method__make_initial_parameters.1" class="lexicon_definition"></a>
#### make_initial_parameters(A) [¶](#method__make_initial_parameters.1)
**Create default parameters**

This function creates initial parameters, based on a food web
matrix. Specifically, the default values are:


| Parameter | Value |
| ----      | ----- |
| K         | 1.0   |

There are two ways to modify the default values. First, by calling the
function and changing its output. For example

    A = [0 1 1; 0 0 0; 0 0 0]
    p = make_initial_parameters(A)
    p[:Z] = 100.0

Alternatively, every parameter can be used as a *keyword* argument when calling the function. For example

    A = [0 1 1; 0 0 0; 0 0 0]
    p = make_initial_parameters(A, Z=100.0)

The only exception is `vertebrates`, which has to be modified after this
function is called. By default, all of the species will be invertebrates.



*source:*
[befwm/src/make_parameters.jl:28](file:///home/tpoisot/.julia/v0.4/befwm/src/make_parameters.jl)

---

<a id="method__make_parameters.1" class="lexicon_definition"></a>
#### make_parameters(p::Dict{Symbol, Any}) [¶](#method__make_parameters.1)
**Make the complete set of parameters**

This function will add simulation parameters, based on the output of
`make_initial_parameters`.



*source:*
[befwm/src/make_parameters.jl:67](file:///home/tpoisot/.julia/v0.4/befwm/src/make_parameters.jl)

## Internal

---

<a id="method__consumption_rates.1" class="lexicon_definition"></a>
#### consumption_rates!(C,  biomass,  p,  F) [¶](#method__consumption_rates.1)
**Consumption**


*source:*
[befwm/src/dBdt.jl:46](file:///home/tpoisot/.julia/v0.4/befwm/src/dBdt.jl)

---

<a id="method__functional_response.1" class="lexicon_definition"></a>
#### functional_response!(F,  biomass,  p,  total_biomass_available) [¶](#method__functional_response.1)
**Functional response**

General function for the functional response matrix. Modifies `F` in place. 

Not to be called by the user.


*source:*
[befwm/src/dBdt.jl:30](file:///home/tpoisot/.julia/v0.4/befwm/src/dBdt.jl)

---

<a id="method__sum_biomasses.1" class="lexicon_definition"></a>
#### sum_biomasses!(total,  biomass,  p) [¶](#method__sum_biomasses.1)
**Total biomass available for each species**

Accounting for the allometric scaling and the number of resources.


This function should not be called by the user. Based on a vector of biomasses
(`biomass`) and a list of parameters (`p`), this function will update the
array `total` with the total biomass available to all species. `total[i]`
will give the biomass available to species `i`.


*source:*
[befwm/src/dBdt.jl:12](file:///home/tpoisot/.julia/v0.4/befwm/src/dBdt.jl)

