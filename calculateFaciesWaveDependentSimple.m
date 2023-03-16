function [glob] = calculateFaciesWaveDependentSimple(glob, iteration)
% Calculate the facies cellular automata according to neighbour rules in
% glob.CARules and according to the wave energy preferences of each facies

    if strcmp(glob.waveRoutine,'on') == 1
        
        glob.faciesProdAdjust = ones(glob.ySize, glob.xSize);
        
        for y = 1 : glob.ySize - 1 % Because of y+1 in glob.waveEnergy reference below
             for x= 1 : glob.xSize
                
                if glob.wd(y,x,iteration) > 0.001
                    f = 1:glob.maxProdFacies;
                    waveEnergyImbalance = abs(glob.prodWaveOptimum(f) - glob.waveEnergy(y+1,x)); % y+1 because waves from cell y+1 break in cell y
                    [~, newFacies] = min(waveEnergyImbalance);

                    if (glob.wd(y,x,iteration) < glob.prodRateWDCutOff(newFacies))
                        glob.facies{y,x,iteration}(1) = newFacies;
                        glob.numberOfLayers(y,x,iteration)=1;
                    else
                        glob.facies{y,x,iteration}(1) = 0;
                    end
                else
                    glob.facies{y,x,iteration}(1) = 0;
                end
             end
        end
    end
end
