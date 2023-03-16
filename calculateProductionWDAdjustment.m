function [prodAdjust] = calculateProductionWDAdjustment(glob, x,y, oneFacies, iteration)

    if glob.surfaceLight(oneFacies)>500
        prodAdjust = tanh((glob.surfaceLight(oneFacies) * exp(-glob.extinctionCoeff(oneFacies) * glob.wd(y,x,iteration)))/ glob.saturatingLight(oneFacies));
    else
        prodAdjust = (1./ (1+((glob.wd(y,x,iteration)-glob.profCentre(oneFacies))./glob.profWidth(oneFacies)).^(2.*glob.profSlope(oneFacies))) );   
    end
end