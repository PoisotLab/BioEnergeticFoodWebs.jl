# Productivity 

The term used to calculate basal species productivity is: 

$$
r_i * G_i * B_i
$$

- $r_i$ is species $i$ intrinsic growth rate 
- $B-i$ is species $i$ biomass

The term $G_i$ however can take different form depending on the mechanism you
are interested in including in your model. There are three possible
alternatives: 

- basic logistic growth (with either a system-wide or a species-specific carrying capacity)
- logistic growth with explicit relative competition 
- nutrient intake.

## Logistic growth

The general formula for $G_i$ is: 

$$
G_i = 1 - \frac {\sum_c B_c} {effK}
$$

- $effK$ is the effective carrying capacity 
- $c$ is any species $i$ compete ith (including potentially itself)

### System-wide carrying capacity 

- $i$ compete only with itself $\sum_c B_c = B_i$
- $effK = K/nP$ where nP is the number of producer (basal species)

```julia 
A = nichemodel(10, 0.2)
p = model_parameters(A, productivity = :system, K = 20)
``` 

### Species-specific carrying capacity 

- $i$ compete only with itself $\sum_c B_c = B_i$
- $effK = K_i$ note that you can pass a vector of species-specific carrying capacity if you are using this alternative

```julia 
A = nichemodel(10, 0.2)
#temperature effect on carrying capacity
function carrying(m, k0, T)
    #m = body mass ; k0 = intercept for Baltzman function, T = temperature (Kelvins)
    βk = 0.28
    Ek = 0.71
    return exp(k0) .* (m .^ βk) .* exp.(Ek .* (293.15 .- T ) ./ (8.617e-5 .* T .* 293.15))
end
M = 10 .^ trophic_rank(A)
carryingcap = carrying(M, 10, 30+273.15) #T = 30C
p = model_parameters(A, productivity = :species, K = carryingcap)
``` 

### Competition 

- $\sum_c B_c = \sum_c \alpha * B_c$ where $\alpha$ represent the strength of inter-specific competition relatively to intra-specific competition
- $effK = K_i$

If $\alpha = 1.0$ then this alternative is equivalent to the species-specific alternative. 

```julia 
A = nichemodel(10, 0.2)
p = model_parameters(A, productivity = :competitive, K = 20, α = 1.2)
``` 

## Nutrient intake 

Following [Brose, Berlow and Martinez 2005][https://books.google.ca/books?hl=en&lr=&id=NHFBDX9-7L0C&oi=fnd&pg=PP1&ots=SHS7qYzWGY&sig=2sRhzLl4pbgi01g4PdaJy59ABHE&redir_esc=y#v=onepage&q&f=false] we implemented a nutrient intake model: 

$G_i(N) = MIN(\frac {N_1} {K_{1i} + N_1} , \frac {N_2} {K_{2i} + N_2})$

Where the concentrations of the two nutrients $N_1$ and $N_2$ are given by: 

$dN_l/dt = D(S_l - N_l) - \sum_{i = 1}^n (ν_l r_i G(N) B_i)$

- $ν_{li}$ is the content of nutrient $l$ in the biomass of species $i$, it's controlled by the argument `ν` (default = `[1.0, 0.5]`)
- $D$ is the turnover rate (expressed relative to the time scale of the growth rate of the basal species), it's controlled by the argument `D` (default = `0.25`)
- $S_l$ is the supply concentration, controlled by the argument of the simulate function, (default = )
- $K_{li}$ is the species and nutrient specific half-saturation density. If  all the producer species have similar $r_i$ and $x_i$ the half-saturation densities for the nutrient with the highest $ν_{l}$ define the competitive hierarchy among the producers. It's controlled by the arguments `K1` and `K2` (default = `[0.15]`). If only one value is passed for each, all species have the same half-saturation densities for K1 and K2, it is also possible to pass a vector of size S (where S is the number of species) for species-specific K1 and K2. 

```julia
A = [0 1 0 0 ; 0 0 1 1 ; 0 0 0 0 ; 0 0 0 0]
p = model_parameters(A, productivity = :nutrients, D = 0.25, ν = [1.0, 0.7], K1 = [0.2], K2 = [0.15])
```