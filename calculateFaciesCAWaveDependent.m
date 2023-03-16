function [glob] = calculateFaciesCAWaveDependent(glob, iteration)
% Calculate the facies cellular automata according to neighbour rules in
% glob.CARules and according to the wave energy preferences of each facies

    if strcmp(glob.waveRoutine,'on') == 1
        
        % Initialise arrays needed for this function
        neighbours = zeros(glob.ySize, glob.xSize, glob.maxProdFacies);
        glob.faciesProdAdjust = zeros(glob.ySize, glob.xSize);
        possNewFacies = zeros(glob.maxProdFacies, 1); % vector of facies that could colonise an empty cell - see below

        j = iteration - 1;
        k = iteration;
        
        % Neighbours contains a count of neighbours for each facies at each grid point and is populated by the countAllNeighbours function
        [neighbours] = countAllNeighbours(glob, j, neighbours);
        
        for y = 1 : glob.ySize
            for x= 1 : glob.xSize

                oneFacies = glob.facies{y,x,j}(1);

                % Only do anything here if the latest stratal surface is below sea-level, i.e.
                % water depth > 0.001 and if the concentration is enough to maintain production       
                if glob.wd(y,x,k) > 0.001

                    % For a subaerial hiatus, now reflooded because from above wd > 0
                    if oneFacies == 9 % 9 is the code for subaerial exposure
                        checkProcess = strcmp(glob.refloodingRoutine,'pre-exposed');
                        if checkProcess==1
                            %get the facies from the pre-exposed
                            glob.facies{y,x,k}(1) = findPreHiatusFacies(glob, x,y,iteration); % reoccupy with facies from below hiatus
                            glob.numberOfLayers(y,x,k)=1;
                        else
                            % set facies =0;
                            glob.facies{y,x,k}(1) = 0;
                            glob.numberOfLayers(y,x,k)=0;
                        end
                        
                        if glob.facies{y,x,k}(1)> glob.maxProdFacies || glob.facies{y,x,k}(1) == 0
                            glob.facies{y,x,k}(1) = 0;
                            glob.numberOfLayers(y,x,k)=0;
                        end

                    % For cells already containing producing facies
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
                else        
                    glob.facies{y,x,k}(1) = 9; % Set to above sea-level facies because must be at or above sea-level
                    glob.numberOfLayers(y,x,k)=1;
                end
                
                % Finally, calculate the production adjustment factor for the current facies distribution
                oneFacies = glob.facies{y,x,k}(1);
                glob.faciesProdAdjust(y,x)=calculateFaciesProductionAdjustementFactor(glob,y,x,oneFacies,neighbours); 
            end
        end
    else
        fprintf('Need wave energy process selected in process options to use wave energy sensitive CA\n');
        fprintf('WARNING - no CA calculated\n');
    end
    
    finalFaciesMap = cell2mat(glob.facies(:,:,k));
    f = 1:9;
    faciesTotals(f) = sum(finalFaciesMap(:) == f);
    fprintf('CA 1:%d 2:%d 3:%d', faciesTotals(1), faciesTotals(2), faciesTotals(3));
end

function [neighbours] = countAllNeighbours(glob, j, neighbours)
% Function to count the number of cells within radius containing facies 1
% to maxFacies across the whole grid and store results in neihgbours matrix

    ySize=int16(glob.ySize);
    xSize=int16(glob.xSize);
    for yco = 1 : ySize
        for xco = 1 : xSize
            oneFacies = glob.facies{yco,xco,j}(1);
            if oneFacies>0 && oneFacies<=glob.maxProdFacies
                radius = glob.CARules(oneFacies,1);
            else
                radius = glob.CARules(1,1);
            end
            for l = -radius : radius
                for m = -radius : radius

                    y = yco + l;
                    x = xco + m;

                    checkProcess=strcmp(glob.wrapRoutine,'unwrap');
                    if checkProcess==1
                        %if near the edge, complete in a mirror-like image the
                        %neighbours array
                        if y<1;  y=1+(1-y); end
                        if x<1;  x=1+(1-x); end
                        if y>ySize; y=ySize+(ySize-y); end
                        if x>xSize; x=xSize+(xSize-x); end
                    else
                        %or wrap around the corners
                        if y<1;  y=ySize+1+l; end
                        if x<1;  x=xSize+1+m; end
                        if y>ySize; y=l; end
                        if x>xSize; x=m; end
                    end
                    %now count the neighbours using the x-y indeces

                    %Don't include cell that has over a certain wd
                    %difference, and penalise the CA with a factor
                    wdDiff=abs(glob.wd(yco,xco,j)-glob.wd(y,x,j));

                    if wdDiff>glob.BathiLimit
                        wdDiffFactor=0;
                    else
                        wdDiffFactor=(-1/glob.BathiLimit)*wdDiff+1;
                    end
                    if wdDiffFactor>0.9; wdDiffFactor=1; end
                    faciesType=glob.facies{y,x,j}(1);
                    % Count producing facies as neighbours but do not include the center cell -
                    % neighbours count should not include itself
                    if faciesType > 0 && faciesType <= glob.maxProdFacies && not (l == 0 && m == 0)
                        neighbours(yco,xco,faciesType) = neighbours(yco,xco,faciesType) + (1*wdDiffFactor);
                    end

                end
            end
        end
    end
end

function [preHiatusFacies] = findPreHiatusFacies(glob, x,y,iteration)

    k = iteration - 1;

    while k > 0 && glob.facies{y,x,k}(1) == 9
        k = k - 1;
    end

    preHiatusFacies = glob.facies{y,x,k}(1);
end
