function modificationFactor = calculateProductionWaveEnergyAdjustment(glob, x,y, faciesCode)

    modificationFactor = 0;
    if faciesCode > 0 && faciesCode <= glob.maxProdFacies
        if glob.wave(y,x) >= glob.prodWaveThresholdLow(faciesCode) && glob.wave(y,x) <= glob.prodWaveThresholdHigh(faciesCode)
            modificationFactor = 1;
        end
    end
end