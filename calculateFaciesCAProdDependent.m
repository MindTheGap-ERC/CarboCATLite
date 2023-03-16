function [glob] = calculateFaciesCAProdDependent(glob, iteration)
% Calculate the facies cellular automata according to neighbour rules in
% glob.CARules and modify production rate modifier for each cell according to number of neighbours.
% The order in which facies are checked depends on the production value at the depth of the cell

    j = iteration - 1;
    k = iteration;

    % Neighbours contains a count of neighbours for each facies at each grid point and is populated by the countAllNeighbours function
    neighbours = zeros(glob.ySize, glob.xSize, glob.maxProdFacies);

    [neighbours] = countAllNeighbours(glob, j, neighbours);
    glob.faciesProdAdjust = zeros(glob.ySize, glob.xSize);

    tempFaciesProd = zeros(glob.ySize, glob.xSize, glob.maxProdFacies); % need a CA array for each prod facies

    for y = 1 : glob.ySize
        for x= 1 : glob.xSize

            oneFacies = glob.facies{y,x,j}(1);

            % Only do anything here if the latest stratal surface is below sea-level, i.e.
            % water depth > 0.001 and if the concentration is enough to maintain production       
            if glob.wd(y,x,k) > 0.001

                % For a subaerial hiatus, now reflooded because from above wd > 0
                if oneFacies == 9 % 9 is the code for subaerial exposure
                    checkProcess=strcmp(glob.refloodingRoutine,'pre-exposed');
                    if checkProcess==1
                        % Get the facies from the pre-exposed
                        glob.facies{y,x,k}(1) = findPreHiatusFacies(glob, x,y,iteration); % reoccupy with facies from below hiatus
                        glob.numberOfLayers(y,x,k)=1;
                    else
                        % Set facies =0;
                        glob.facies{y,x,k}(1) = 0;
                        glob.numberOfLayers(y,x,k)=0;
                    end
                    if glob.facies{y,x,k}(1)> glob.maxProdFacies || glob.facies{y,x,k}(1)==0
                        glob.facies{y,x,k}(1) = 0;
                        glob.numberOfLayers(y,x,k)=0;
                    end
                    
                % For cells already containing producing facies
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
                end

                % Finally, calculate the production adjustment factor for the current facies distribution
                oneFacies = glob.facies{y,x,k}(1);
                glob.faciesProdAdjust(y,x)=calculateFaciesProductionAdjustementFactor(glob,y,x,oneFacies,neighbours);       
            else        
                glob.facies{y,x,k}(1) = 9; % Set to above sea-level facies because must be at or above sea-level
                glob.numberOfLayers(y,x,k)=1;

            end
        end
    end
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
