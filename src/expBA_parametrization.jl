
function exponentialBA(T_param)
    k=8.617e-5
    return (bodymass, T) -> T_param.norm_constant.*((bodymass.^T_param.β).*exp.(-T_param.activation_energy./(k*T)))
end

T_param_expba = @NT(norm_constant = 0.2e11, activation_energy = 0.65, β = -0.25)


handling(tempfunc::Function, par) = tempfunc(par)

handling(exponentialBA, T_param_expba)(1,295)


T_param_expba = @NT(norm_constant = 0.2e11, activation_energy = 0.65, β = -0.25)
T_param_extba = @NT(norm_constant = 0.2e11, activation_energy = 0.65, β = -0.25, deactivation_energy = 1.15, T_opt = 293)
T_param_gauss = @NT(norm_constant = 0.5, range = 20, β = -0.25, T_opt = 293)
T_param_eppley = @NT(maxrate_0 = 0.81, eppley_exponent = 0.0631, T_opt = 291.15, range = 35, β = -0.25)

## Exponential BA 2

function exponentialBA2(T_param)
    k=8.617e-5
    return (bodymass, T) -> T_param.norm_constant*(bodymass.^T_param.β)*exp(T_param.activation_energy*(T_param.T0-(T+T_param.T0K))/(k*(T+T_param.T0K)*T_param.T0))
end


T_param_expba_r = @NT(norm_constant = exp(-15.68), activation_energy = -0.84, β = -0.25, T0=293.15, T0K=273.15)

T_param_expba_x = @NT(norm_constant = exp(-16.54), activation_energy = -0.69, β = -0.31, T0=293.15, T0K=273.15)

T_param_expba_a = @NT(norm_constant = exp(-13.1), activation_energy = -0.38, β = 0.25, T0=293.15, T0K=273.15)

T_param_expba_h = @NT(norm_constant = exp(9.66), activation_energy = 0.26, β = -0.45, T0=293.15, T0K=273.15)

growthR(tempfunc::Function, par) = tempfunc(par)
metabolicR(tempfunc::Function, par) = tempfunc(par)
attackR(tempfunc::Function, par) = tempfunc(par)
handlingT(tempfunc::Function, par) = tempfunc(par)

temp=295

mprey=0.01
mpred=10*mprey
βpred_a=-0.8
βpred_h=0.47

## Handling time additional body mass dependency

norm_constant_h_massdep=1.92
β1_h_massdep=-0.48
β2_h_massdep=0.0256

h_massdep = exp(norm_constant_h_massdep + β1_h_massdep * log(mpred/mprey) + β2_h_massdep * (log(mpred/mprey))^2)

## Handling time additional temperature dependency: quadratic relationship
norm_constant_h_Tquad = 0.5;            # intercept
β1_h_Tquad = -0.055;                    # linear slope term 1
β2_h_Tquad = 0.0013;                    # quadratic slope term 2

h_Tquad = exp(norm_constant_h_Tquad + β1_h_Tquad * (temp) +  β2_h_Tquad * (temp)^2)

h1=handlingT(exponentialBA2, T_param_expba_h)(mprey,temp)
handlingTime=h1*mpred^βpred_h*h_massdep*h_Tquad


## Attack rate additional dependencies
norm_constant_a_massdep    = -1.81;         # intercept
β1_a_massdep  = 0.39;          # linear slope term 1
β2_a_massdep  = -0.017;        # quadratic slope term 2


a_massdep=exp(norm_constant_a_massdep + β1_a_massdep * log(mpred/mprey) + β2_a_massdep * (log(mpred/mprey))^2)

a1=attackR(exponentialBA2, T_param_expba_a)(mprey,temp)
attackRate=a1*mpred^βpred_a*a_massdep

growthRate=growthR(exponentialBA2, T_param_expba_r)(mprey,temp)
metabolicRate=metabolicR(exponentialBA2, T_param_expba_x)(mprey,temp)
