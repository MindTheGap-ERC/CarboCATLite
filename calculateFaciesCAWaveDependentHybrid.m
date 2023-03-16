function [glob] = calculateFaciesCAWaveDependentHybrid(glob, iteration)
% Calculate the facies cellular automata according to neighbour rules in
% glob.CARules and according to the wave energy preferences of each facies

    if strcmp(glob.waveRoutine,'on') == 1
        
        % Initialise arrays needed for this function
        neighbours = zeros(glob.ySize, glob.xSize, glob.maxProdFacies);
        glob.faciesProdAdjust = zeros(glob.ySize, glob.xSize);
        j = iteration - 1;
        k = iteration;
        
        glob.faciesProdAdjust = ones(glob.ySize, glob.xSize);
        
        % Neighbours contains a count of neighbours for each facies at each grid point and is populated by the countAllNeighbours function
        [neighbours] = countAllNeighbours(glob, j, neighbours);
        
        for y = 1 : glob.ySize
            for x= 1 : glob.xSize
 
                % Only do anything here if the latest stratal surface is below sea-level, i.e.
                % water depth > 0.001 and if the concentration is enough to maintain production       
                if glob.wd(y,x,k) > 0.001
    
                    [glob, newFacies] = coloniseOrContinueWaveDependentFacies(glob, x, y, k);
                    
                    if newFacies == 0 
                        glob = calcWaveInsensitiveCA(glob, x, y, j, k, neighbours);
                    end
                else
                    glob.facies{y,x,k}(1) = 9; % Set to above sea-level facies because must be at or above sea-level
                    glob.numberOfLayers(y,x,k)=1;
                end               
            end
        end 
    else
        fprintf('Need wave energy process selected in process options to use wave energy sensitive CA\n');
        fprintf('WARNING - no CA calculated\n');
    end
    
%     finalFaciesMap = cell2mat(glob.facies(:,:,k));
%     f = 1:9;
%     faciesTotals(f) = sum(finalFaciesMap(:) == f);
%     fprintf('CA 1:%d 2:%d 3:%d ', faciesTotals(1), faciesTotals(2), faciesTotals(3));
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
                    % now count the neighbours using the x-y indices

                    % Don't include cell that has over a certain wd
                    % difference, and penalise the CA with a factor
                    wdDiff = abs(glob.wd(yco,xco,j)-glob.wd(y,x,j));

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

    j = iteration - 1;

    while j > 0 && glob.facies{y,x,j}(1) == 9
        j = j - 1;
    end

    preHiatusFacies = glob.facies{y,x,j}(1);
end

function glob = calcWaveInsensitiveCA(glob, x, y, j, k, neighbours)

    oneFacies = glob.facies{y,x,j}(1); % Get the previously deposited facies at x,y

    % For a subaerial hiatus, now reflooded because from above wd > 0
    if oneFacies == 9 % 9 is the code for subaerial exposure
        checkProcess = strcmp(glob.refloodingRoutine,'pre-exposed');
        if checkProcess==1
            %get the facies from the pre-exposed
            glob.facies{y,x,k}(1) = findPreHiatusFacies(glob, x,y,k); % reoccupy with facies from below hiatus
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
    elseif (oneFacies <= glob.maxProdFacies && oneFacies > 0) && ...
            glob.prodWaveThresholdHigh(oneFacies) - glob.prodWaveThresholdLow(oneFacies) == 1.0 && ...
            glob.numberOfLayers(y,x,j)==1

        % Check if neighbours is less than min for survival CARules(i,2) or greater than max for survival CARules(i,3),
        % or if water depth is greater than production cutoff, and if so kill that facies 
        if (neighbours(y,x,oneFacies) < glob.CARules(oneFacies,2)) ||...
                (neighbours(y,x,oneFacies) > glob.CARules(oneFacies,3)) ||...
                (glob.wd(y,x,k) >= glob.prodRateWDCutOff(oneFacies))
            glob.facies{y,x,k}(1) = 0; % kill the facies because wrong neighbour count or too deep

        else % The right number of neighbours exists so facies persists
         
            glob.facies{y,x,k}(1) = oneFacies;
            glob.numberOfLayers(y,x,k) = 1;    
        end
    else % Otherwise cell must be empty or contain transported product, so see if it can be colonised with a producing facies
        newFaciesProd = zeros(1,glob.maxProdFacies);                    
        for f = 1:glob.maxProdFacies
            % Check if number of neighbours is within range to trigger new
            % facies cell, and only allow potential new faices to colonise the cell if the water depth is less the production cut off depth
            if (neighbours(y,x,f) >= glob.CARules(f,4)) && ...
                    (neighbours(y,x,f) <= glob.CARules(f,5)) && ...
                    (glob.wd(y,x,k) < glob.prodRateWDCutOff(f)) && ...
                    glob.waveEnergy(y,x) >= glob.prodWaveThresholdLow(f) && ...
                    glob.waveEnergy(y,x) <= glob.prodWaveThresholdHigh(f)

                newFaciesProd(f) = f; % new facies cell triggered at y,x
            end
        end

        % calculate the water-depth adjusted production rate for each facies and store in prodRate vector
        prodRate = zeros(1,glob.maxProdFacies);
        for f = 1:glob.maxProdFacies
            if newFaciesProd(f) > 0
                prodRate(f) = glob.prodRate(f) * calculateProductionWDAdjustment(glob, x,y, f, k);
            end
        end
        
        maxProd = max(prodRate); % get the maximum prod rate and it's index, the latter being the max prod facies code

        if maxProd == 0 % No facies producing at this x,y water depth so cell is empty
            glob.facies{y,x,k}(1) = 0;
        else
            maxProdFacies = find(prodRate == maxProd);
            
            if length(maxProdFacies) == 1 % only one facies at the maximum prod rate, so assign this facies to cell x,y
                 glob.facies{y,x,k}(1) = max(prodRate);
            else
                maxProdFacies = find(prodRate == maxProd);
                chooseFacies = randi(length(maxProdFacies),1);
                glob.facies{y,x,k}(1) = maxProdFacies(chooseFacies);
%                 fprintf('\n%d %d new facies %d\n', x,y, maxProdFacies(chooseFacies));
            end
        end
%         % Find the highest production rate and assign a fraction of 1 at the correct position in the glob.fraction array
%         [sortedProdArray,index] = sort(prodRate);
%         if sum(sortedProdArray(:)) == 0
%             glob.facies{y,x,k}(1) = 0;
%         else
%             glob.facies{y,x,k}(1) = index(glob.maxProdFacies); % the last element in the array has the largest production
%             glob.numberOfLayers(y,x,k)=1;
%         end
    end
end

function [glob, newFacies] = coloniseOrContinueWaveDependentFacies(glob, x, y, k)

    possNewFacies = zeros(glob.maxProdFacies, 1);
    possNewFaciesCount = 0;
    for f = 1:glob.maxProdFacies % loop through all the producing facies that could be wave-energy dependent
        
        % First check if facies f is wave-energy sensitive
        if glob.prodWaveThresholdHigh(f)- glob.prodWaveThresholdLow(f) < 0.9999 % 0.9999 to allow for rounding error
            
            % it is wave sensitive, so check that this xy position is
            % within the required wave energy and water depth ranges
            if glob.waveEnergy(y,x) >= glob.prodWaveThresholdLow(f) && ... % So check if xy pos meets it's WD and wave energy criteria
                glob.waveEnergy(y,x) <= glob.prodWaveThresholdHigh(f) && ...
                glob.wd(y,x,k) <= glob.prodRateWDCutOff(f)
            
                possNewFacies(f) = f; % reset from zero for a facies that meets neighbour and water depth rules
                possNewFaciesCount = possNewFaciesCount + 1;
            end
        end
    end

    % More than one candidate facies, so calculate which is optimum for the wave energy at this x,y
    if possNewFaciesCount > 0 
        
        % More than one wave sensitive facies could go in this xy cell, so
        % select which based on which has an optimum (middle of the range)
        % wave energy sensitivity closest to the wave energy at xy
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
        
        newFacies = waveOptimumFacies;
        glob.facies{y,x,k}(1) = waveOptimumFacies;
        glob.numberOfLayers(y,x,k) = 1; % non zero-facies code here means one layer has been produced at y,x,k
    else
        newFacies = 0;
    end
end