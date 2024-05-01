# Sensaitivity test of changing different CA 
**bold text**

We also tested how changing the celullar stomata (CA) rules would influence the output. See more background about what is CA, please refer to 'sensitivity test of CA rules'.

## 1: wavesimple 
This scenario is the default setting. In this scenario, the CA process has been changed to 'simple wave' process.

The code of the scenario is:
```
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
```

This code calculates the 'waveEnergyImbalance' between the species and calculated wave energy (depends on water depth). The code allows the smallest discrepancies between the wave energy niche of the species and the calculated wave energy.

The results could be found in the following figure: the growth of the carbonate platform can keep up with the sealevel change.
![] (https://osf.io/axzj3)
<figurecaption> Simplewave results.

## 2: ProductionCA

This scenario considers CA but do not involve the waveenergy selection process.

The code is (only the main part):
```
              elseif (oneFacies <= glob.maxProdFacies && oneFacies>0) && glob.numberOfLayers(y,x,j)==1

                    % Check if neighbours is less than min for survival CARules(i,2) or
                    % greater than max for survival CARules(i,3), or if water depth is greater than production cutoff and if so kill
                    % that facies
                    thick = glob.carbonateVolMap(y,x) / (glob.ySize*glob.xSize);
                    checkProcess=strcmp(glob.concentrationRoutine,'on');

                    if (neighbours(y,x,oneFacies) < glob.CARules(oneFacies,2)) ||...
                            (neighbours(y,x,oneFacies) > glob.CARules(oneFacies,3)) ||...
                            (glob.wd(y,x,iteration) >= glob.prodRateWDCutOff(oneFacies)) ||...
                            ( checkProcess == 1 && thick < 0.01)
                        glob.facies{y,x,k}(1) = 0;
                    else % The right number of neighbours exists
                        glob.facies{y,x,k}(1) = oneFacies;
                        glob.numberOfLayers(y,x,k)=1;  
                    end

                else % Otherwise cell must be empty or contain transported product so see if it can be colonised with a producing facies
                    % Check again the carbonate concentration
                    thick = glob.carbonateVolMap(y,x) / (glob.ySize*glob.xSize);
                    checkProcess=strcmp(glob.concentrationRoutine,'on');
                    if checkProcess == 0 || thick > 0.01
                        for f = 1:glob.maxProdFacies
                            % Check if number of neighbours is within range to trigger new
                            % facies cell, and only allow new cell if the water depth is less the production cut off depth
                            if (neighbours(y,x,f) >= glob.CARules(f,4)) && (neighbours(y,x,f) <= glob.CARules(f,5)) && (glob.wd(y,x,iteration) < glob.prodRateWDCutOff(f))
                                tempFaciesProd(y,x,f) = f; % new facies cell triggered at y,x
                            end
                        end

                        prodRate = zeros(1,glob.maxProdFacies);
                        for f = 1:glob.maxProdFacies
                            if tempFaciesProd(y,x,f) > 0
                                prodRate(f) = glob.prodRate(f) * calculateProductionWDAdjustment(glob, x,y, f, iteration);
                            end
                        end

                        % Find the highest production rate and assign a fraction of 1 at the correct position in the glob.fraction array
                        [sortedArray,index]=sort(prodRate);
                        if sum(sortedArray(:))==0
                            glob.facies{y,x,k}(1)=0;
                        else
                            glob.facies{y,x,k}(1)=index(glob.maxProdFacies); % the last element in the array has the largest production
                            glob.numberOfLayers(y,x,k)=1;
                        end
                    end
```

This code first determine what the facies of the last iteration. It then checks its neighborhood: if the number of neighborhood meets the requirements of the facies. We take facies 1 as an example: if it has 7 neighbors with facies 1, it will survive and occupy this cell, because the CA rules suggests that it will survive between 4 and 10. If not meet, it will return 0 (empty cell).

The results could be found in the following figure: the growth of the carbonate platform can keep up with the sealevel change.
![] (https://osf.io/mzjec)
<figurecaption> ProductionCA results.

## 3: Wave Hybrid

This scenario considers both wave energy selection and CA.

The code as follows (main part):

```
                   elseif (oneFacies <= glob.maxProdFacies && oneFacies>0) && glob.numberOfLayers(y,x,j)==1

                        % Check if neighbours is less than min for survival CARules(i,2) or greater than max for survival CARules(i,3),
                        % or if water depth is greater than production cutoff, and if so kill that facies 
                        if (neighbours(y,x,oneFacies) < glob.CARules(oneFacies,2)) ||...
                                (neighbours(y,x,oneFacies) > glob.CARules(oneFacies,3)) ||...
                                (glob.wd(y,x,iteration) >= glob.prodRateWDCutOff(oneFacies))
                            glob.facies{y,x,k}(1) = 0; % kill the facies because wrong neighbour count or too deep
                            
                        else % The right number of neighbours exists

                            % Facies persists if wave energy is appropriate                  
                            if glob.waveEnergy(y,x) >= glob.prodWaveThresholdLow(oneFacies) && ...
                                    glob.waveEnergy(y,x) <= glob.prodWaveThresholdHigh(oneFacies)
                                glob.facies{y,x,k}(1) = oneFacies;
                                glob.numberOfLayers(y,x,k) = 1;
                            else
                                glob.facies{y,x,k}(1) = 0;
                            end    
                        end

                    else % Otherwise cell must be empty or contain transported product, so see if it can be colonised with a producing facies
                        possNewFacies = zeros(glob.maxProdFacies, 1);
                        possNewFaciesCount = 0;
                        for f = 1:glob.maxProdFacies % loop to create candidate facies cells in the empty grid cell
                            % Check if number of neighbours is within range to trigger new facies cell,
                            % and only allow new cell if the water depth is less the production cut off depth
                            if (neighbours(y,x,f) >= glob.CARules(f,4)) && ...
                                    (neighbours(y,x,f) <= glob.CARules(f,5)) && ...
                                    (glob.wd(y,x,iteration) < glob.prodRateWDCutOff(f))
                                possNewFacies(f) = f; % reset from zero for a facies that meets neighbour and water depth rules
                                possNewFaciesCount = possNewFaciesCount + 1;
                            end
                        end

                        % More than one candidate facies so calculate which is optimum for wave energy at this x,y
                        if possNewFaciesCount > 1 
                            waveOptimumFacies = 0; % default value to set if no optimum wave energy facies found
                            minDivergence = 100; % higher than maximum possible, since 0<=wave energy<=1
                            for f = 1:glob.maxProdFacies
                                if possNewFacies(f) > 0

                                    divergence = abs(glob.prodWaveOptimum(f) - glob.waveEnergy(y,x));
                                    if divergence < minDivergence
                                        minDivergence = divergence;
                                        waveOptimumFacies = f;
                                    end
                                end
                            end

%                             if glob.wd(y,x,k) <= glob.prodRateWDCutOff(waveOptimumFacies) % Finally, check the selected facies is good in this water depth
                                glob.facies{y,x,k}(1) = waveOptimumFacies;
                                if waveOptimumFacies > 0
                                    glob.numberOfLayers(y,x,k)=1; % non zero-facies code here means one layer has been produced at y,x,k
                                end
%                             end
                        elseif possNewFaciesCount == 1
                            
                            singlePossNewFacies = max(possNewFacies(:));
                            
%                             if  glob.wd(y,x,k) <= glob.prodRateWDCutOff(singlePossNewFacies) && ...
                            if glob.waveEnergy(y,x) >= glob.prodWaveThresholdLow(singlePossNewFacies) && ...
                                    glob.waveEnergy(y,x) <= glob.prodWaveThresholdHigh(singlePossNewFacies)
                                
                                glob.facies{y,x,k}(1) = singlePossNewFacies;
                                glob.numberOfLayers(y,x,k)=1;
                            end
                        end
                    end
```

This code first calculate productionCA. If the cell is assigned with facies 0 (empty cell), it would carry out simplewave.

The result is here:
![](https://osf.io/ptmwv)
<figurecaption> WaveCA result

## 4: Wavehybrid CA

This scenario also considers both wave energy selection and CA.

The code as follows (main part):

```
                if glob.wd(y,x,k) > 0.001
    
                    [glob, newFacies] = coloniseOrContinueWaveDependentFacies(glob, x, y, k);
                    
                    if newFacies == 0 
                        glob = calcWaveInsensitiveCA(glob, x, y, j, k, neighbours);
                    end
                else
                    glob.facies{y,x,k}(1) = 9; % Set to above sea-level facies because must be at or above sea-level
                    glob.numberOfLayers(y,x,k)=1;
```

This code first calculates the wavenergy selection (Simplewave). If the cell is assigned with empty cell, it begins to carry out productionCA.

The result is here:
![](hhttps://osf.io/qdwxu)
<figurecaption> WavehybridCA result

# Summary
We compared how the choice of CA controls the carbonate platform evolution. In a nutshell, the scenario 2 and 3 drowns, and 1 and 4 keeps up with sealevel. This is because 1 and 4 depends mainly on wave energy imbalance (i.e., the fit between the calculated wave energy and the comfortable range of the species) and thehe bilogical competetion is minor. 2 and 3 drowns because of the strong biological competition.
