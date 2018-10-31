### Temperature Size Rule, following Forster et al 2012 ###

## Mean aquatic response : average TS response for aquatic Metazoa

# Args: temperature in Celsius degrees, DM20 dry mass at 20 degrees

function TSR_aqua(temp,DM20)
    # tempCel=temp-273.15
    c=6.5
    PCM=-3.90-0.53*log10(DM20)     # Percentage change in body-mass per degrés C
    S=log(PCM/100+1)               # Sign and magnitude of TS response
    M=c*DM20.*exp.(S.*(temp-20))./1000 # dry mass converted to fresh mass in g
    return(M)
end

temp=linspace(5,35,50)
DMtsr=0.2

bmTSR_aqua=TSR_aqua(temp,DMtsr)

using Plots
plotlyjs()

plot(temp,bmTSR_aqua)

## Mean terrestrial response : average TS response for terrestrial Metazoa

function TSR_terrestrial(temp,DM20)
    c=6.5
    PCM=-1.72+0.54*log10(DM20)
    S=log(PCM/100+1)
    M=c*DM20*exp(S*(temp-20))/1000
    return(M)
end

temp=linspace(5,35,50)
DMtsr=0.2

bmTSR_terrestrial=TSR_terrestrial(temp,DMtsr)

using Plots
plotlyjs()

plot(temp,bmTSR_terrestrial)

## Max TS response : strongest negative response

function TSR_max(temp,DM20)
    c=6.5
    PCM=-8
    S=log(PCM/100+1)
    M=c*DM20*exp(S*(temp-20))/1000
    return(M)
end

temp=linspace(5,35,50)
DMtsr=0.2

bmTSR_max=TSR_max(temp,DMtsr)

using Plots
plotlyjs()

plot(temp,bmTSR_max)

## Reverse TS response : strongest positive TS response

function TSR_reverse(temp,DM20)
    c=6.5
    PCM=4
    S=log(PCM/100+1)
    M=c*DM20*exp(S*(temp-20))/1000
    return(M)
end

temp=linspace(5,35,50)
DMtsr=0.2

bmTSR_reverse=TSR_reverse(temp,DMtsr)

lines(temp,bmTSR_reverse)
