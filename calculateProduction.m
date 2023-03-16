function glob = calculateProduction(glob, iteration)

    onefacies = uint8(0);
    prod = 0.0;
    glob.initialTransportThickMap = zeros(glob.ySize, glob.xSize);
    availableForTransport = 0.0;
    totalProd=0.0;
    faciesCellCount = zeros(1,glob.maxProdFacies);
    
    % Calculate carbonate production for each point on the grid.
    % NB could be optimized of prod was put into an xy map then used outside the loop to update all these other xy maps
    for y=1:glob.ySize
        for x=1:glob.xSize

            oneFacies =  glob.facies{y,x,iteration}(1);
            
            
            % Only need to calculate production for occupied cells i.e. 0 < facies < 9 (9 is subaerial exposure)
            if oneFacies > 0 && oneFacies <= glob.maxProdFacies && glob.wd(y,x,iteration) > 0

                faciesCellCount(oneFacies) = faciesCellCount(oneFacies) + 1; % Add the facies cell to the sum count for that facies
                
                % Bosscher and Schlager production variation with water depth
                if (glob.wd(y,x,iteration) > 0.0)

                    if glob.surfaceLight(oneFacies) > 500
                        % use this if you want to use Schlager's production profile
                        glob.prodDepthAdjust(y,x) =  tanh((glob.surfaceLight(oneFacies) * exp(-glob.extinctionCoeff(oneFacies) * glob.wd(y,x,iteration)))/ glob.saturatingLight(oneFacies));
                    else
                        % use this if you want to use new production profile
                        glob.prodDepthAdjust(y,x) = (1./ (1+((glob.wd(y,x,iteration)-glob.profCentre(oneFacies))./glob.profWidth(oneFacies)).^(2.*glob.profSlope(oneFacies))) );
                    end
                else
                    glob.prodDepthAdjust(y,x) = 0;
                end

                % Set production thickness to depth and neighbour-adjusted
                % thickness for this facies, taking into account the
                % varoius factors that control production
                % Note that faciesProdAdjust is calculated in calculateFaciesCA
                prod = glob.prodRate(oneFacies) * glob.prodDepthAdjust(y,x) * glob.faciesProdAdjust(y,x) * glob.carbProdCurve(iteration);
                prod = prod * glob.productionBySiliciclasticMap(y,x,oneFacies);

                if prod > glob.wd(y,x,iteration) % if production > accommodation set prod=accommodation to avoid build above SL
                    prod = glob.wd(y,x,iteration);
                end

                %check against the dissolved carbonate volume
                checkProcess=strcmp(glob.concentrationRoutine,'on');
                if checkProcess==1
                    volp=prod*(glob.dx^2); %in metres
                    if volp>glob.carbonateVolMap(y,x)
                        volp = glob.carbonateVolMap(y,x);
                        glob.carbonateVolMap(y,x) = 0;
                    else
                        glob.carbonateVolMap(y,x) = glob.carbonateVolMap(y,x)-volp;
                    end
                    prod = volp/(glob.dx^2);
                end

                % Decrease WD by amount of production
                glob.wd(y,x,iteration) = glob.wd(y,x,iteration) - prod;

                % Calculate the transportable thickness at this point as a proportion of production.
                checkProcess=strcmp(glob.waveRoutine,'on');
                if checkProcess ==0
                    availableForTransport = prod * glob.transportFraction(oneFacies);
                else
                    availableForTransport = prod * calculateTransportFraction(y,x,oneFacies,glob,iteration);
                end
                glob.initialTransportThickMap(y,x) = availableForTransport;

                % Record the production as thickness in the strata array
                glob.strata(y,x,iteration) = glob.strata(y,x,iteration-1) + prod;
                glob.thickness{y,x,iteration}(1) = prod;
                

            else % No deposition so record zero thickness
                if glob.facies{y,x,iteration}(1)~=8
                glob.prodDepthAdjust(y,x) = 0;
                prod = 0;
                glob.strata(y,x,iteration) = glob.strata(y,x,iteration-1);
                glob.thickness{y,x,iteration}(1) = 0.0;
                end
            end

%             if x==round(glob.xSize / 2) && y == round(glob.ySize / 2)
%                 fprintf('SL %3.2f WD:%3.2f @%d,%d Facies %d Prod %3.2f ', glob.SL(iteration), glob.wd(y,x,iteration), x,y, oneFacies, prod);
%             end

            totalProd = prod + totalProd;
        end
    end
    
    fprintf('SL %3.2f WD:%3.2f ', glob.SL(iteration), glob.wd(y,x,iteration));
    for f = 1:glob.maxProdFacies
        fprintf('%d:%d ', f, faciesCellCount(f));
    end
    fprintf('Tot accum. %3.2f ', totalProd);
end




