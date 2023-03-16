function [glob] = calculateTransport(glob, iteration)

    topog = zeros(glob.ySize, glob.xSize);
    flowThick = 0;
    prodFacies = uint8(0);
    oneTransThickMap = num2cell(zeros(glob.ySize, glob.xSize)); % Map of thickness of deposited transported sediment for current iteration
    oneTransFaciesMap = num2cell(uint16(zeros(glob.ySize, glob.xSize))); % Map of facies deposited by transport for current iteration
    transFacies = uint16(0);
    flowCount = uint16(0);
    flowRoute = zeros(glob.ySize, glob.xSize);
    destCells = uint16(0);
    noRoute = uint16(0);
    foundDeeperCell = false;
    dummy1 = uint16(0);
    dummy2 = uint16(0);

    topog = glob.strata(:,:,iteration);

    % Calculate transport from each point on the grid
    yArray=1:glob.ySize;
    xArray=1:glob.xSize;
    yArrayRand = yArray(randperm(length(yArray)));
    xArrayRand = xArray(randperm(length(xArray)));
    for i=1:glob.ySize
        for j=1:glob.xSize

            y=yArrayRand(i);
            x=xArrayRand(j);

            flowThick = glob.initialTransportThickMap(y,x); % Trans thick map contains the transportable
            %thicknesses calculated in the production routines, derived from the glob.erosionPerc value
            prodFacies =  glob.facies{y,x,iteration}(1); % Get the in-situ produced facies for this cell

            % Check if there is a deeper cell adjacent to source cell before triggering a
            % flow. This is necessary because triggering a flow causes sediment to be
            % removed from the source cell - don't want this to happen if flow is not
            % going to happen
            [foundDeeperCell, deepestX, deepestY] = findDeepestNeighbourCell(glob,topog,x,y);
            flowGradient = topog(y,x) - topog(deepestY, deepestX);

            % Only call the flow calculator if...
            % pTransportOverride < glob.transportContinueProbability OR all the following are true:
            % Source cell contrains primary producer facies 1,2, or 3 that are below sea-level
            % There is a deeper adjacent cell
            % gradient to adjacent deeper cell and flow thickness both exceed set thresholds
            if      (foundDeeperCell == true ...
                    && prodFacies <= glob.maxProdFacies && prodFacies > 0 && glob.wd(y,x,iteration) >= 0 ...
                    && flowGradient > glob.transportGradient(prodFacies) && flowThick > 0.001)

                transFacies = glob.transportProductFacies(prodFacies); % Get the transport facies produced from the in-situ facies

                % Remove the transportable thickness from the relevant array records
                glob.strata(y,x,iteration) = glob.strata(y,x,iteration) - flowThick;
                glob.thickness{y,x,iteration}(1) = glob.thickness{y,x,iteration}(1) - flowThick;

                [topog, glob] = calcOneTransportEvent(glob, iteration, topog, y, x, flowThick, prodFacies, transFacies, noRoute);
                flowCount = flowCount + 1;
            end
        end
    end

    totalTransported = 0.0;

    for y=1:glob.ySize
        for x=1:glob.xSize

            checkProcess=strcmp(glob.siliciclasticsRoutine,'on');
            if checkProcess==1
                %calculate the amount of siliciclastic
                kl=find(glob.facies{y,x,iteration}(:)==8);
                if isempty(kl)
                    clast = 0;
                else
                    clast = sum(glob.thickness{y,x,iteration}(kl));
                end
            else
                clast =0;
            end
            % Increase deposited thickness by amount of deposition in all the transported facies at y,x
            % deposited thickness is the amount of deposited without the siliciclastic
            if glob.facies{y,x,iteration}(1) <= glob.maxProdFacies
                oneThickness=sum(glob.thickness{y,x,iteration}(:))-sum(glob.thickness{y,x,iteration}(1))-clast;
            else
                oneThickness=sum(glob.thickness{y,x,iteration}(:))-clast;
            end

            % Increase deposited thickness by amount of deposition in all the transported facies at y,x       
            glob.strata(y,x,iteration) = glob.strata(y,x,iteration) + oneThickness;
            totalTransported = totalTransported + oneThickness;

            % Decrease WD by amount of deposition
            glob.wd(y,x,iteration) = glob.wd(y,x,iteration) - oneThickness;

            if oneThickness>0; destCells=destCells+1; end
        end
    end

    % Record transported sediment as thickness in the strata array and as facies in the
    % faciesTrans array
    %glob.faciesTrans(:,:,iteration) = oneTransFaciesMap;
    %glob.faciesTransThick(:,:,iteration) = oneTransThickMap;

    fprintf('Trans %3.2f in %d flows to %d cells. Failed %d', totalTransported, flowCount, destCells, noRoute);
end

function [topog, glob] = calcOneTransportEvent(glob, iteration, topog, startY, startX, flowThick, prodFacies, transFacies, noRoute)
% Calculates the transport from cell startX startY and records the deposited thickness in oneTransThickMap

    % Initialize variables
    flowDone = false;
    flowRoute = zeros(glob.ySize, glob.xSize);
    flowLength = uint16(0); % length of flow in number of grid cells
    numFaciesInCell = uint8(0);
    flowRoute(startY, startX) = flowLength;
    flowGradient = 0;

    y = startY;
    x = startX;

    while flowDone == false

        [foundDeeperCell, deepestX, deepestY] = findDeepestNeighbourCell(glob,topog, x, y);
        flowGradient = (topog(y,x) - topog(deepestY, deepestX)) / glob.dx; % dx is in m too, so gradient is dimensionaless ratio
        
        % pTransportOverride is a random number which if less than glob.transportContinueProbability for each facies
        % forces transport to continue, even if there is no deeper neighbour cell
        pTransportOverride = rand(1);
        
        % Lower cells found adjacent to the current flow cell, and gradient > minimum threshold, so deposit and prepare to carry on flow

        % TRANSPORT to deeper cell and beyond, with possibility of some deposition also
        if foundDeeperCell == true || pTransportOverride < glob.transContinueProb(prodFacies)
            if flowGradient > glob.transportGradient(prodFacies) || pTransportOverride < glob.transContinueProb(prodFacies) % So still above deposition threshold
                flowLength = flowLength + 1;
                flowRoute(deepestY, deepestX) = flowLength;
                x = deepestX; % update flow coorindates to this adjacent deeper cell
                y = deepestY;
                flowDone = false; % Continue flow, because there may be yet deeper cells adjacent to this one...
            else
                % Calculate the thickness to deposit based on a proportional decay of
                % thickness and a minimum cutoff
                if flowThick < 0.01 % gradient too small and flow too thin
                    depositHere = flowThick;
                    flowThick = 0;
                    flowDone = true;
                else %gradient too small and thick flow
                    depositHere = flowThick * 0.5;
                    flowThick = flowThick - depositHere;
                end

                glob.numberOfLayers(y,x,iteration)=glob.numberOfLayers(y,x,iteration)+1;
                glob.facies{y, x,iteration}(glob.numberOfLayers(y,x,iteration)) = transFacies;
                glob.thickness{y, x,iteration}(glob.numberOfLayers(y,x,iteration)) = depositHere; % Nb this could lead to deposition to above sealevel
                topog(y, x) = topog(y, x) + depositHere;
            end

        % DEPOSIT
        % Else no lower cell found, so deposit all flow at the last deepest cell x y unless it is the start cell
        else if not(x == startX && y == startY)
                availableSpace = glob.SL(iteration)-topog(y,x);
                if flowThick <= availableSpace
                    glob.numberOfLayers(y,x,iteration)=glob.numberOfLayers(y,x,iteration)+1;
                    glob.facies{y, x,iteration}(glob.numberOfLayers(y,x,iteration)) = transFacies;
                    glob.thickness{y, x,iteration}(glob.numberOfLayers(y,x,iteration)) = flowThick;
                    topog(y, x) = topog(y, x) + flowThick; % NB this means flows will interact with deposits of previous flow

                    flowDone = true; % End the flow because no deeper cell found or below gradient threshold so deposit in this low
                else
                    %NB add this on 26/5 to avoid building over sea level - estani & george
                    depositHere = availableSpace;
                    flowThick = flowThick - depositHere;
                    glob.numberOfLayers(y,x,iteration)=glob.numberOfLayers(y,x,iteration)+1;
                    glob.facies{y, x,iteration}(glob.numberOfLayers(y,x,iteration)) = transFacies;
                    glob.thickness{y, x,iteration}(glob.numberOfLayers(y,x,iteration)) = depositHere;
                    topog(y, x) = topog(y, x) + depositHere;

                    xInc = [0 -1 1 -1 1 -1 1 0 ];
                    yInc = [-1 1 -1 -1 0 0 1 1 ];
                    a=1;
                    checkSurr=0;

                    while flowThick>0
                        ny=y+yInc(a)   ;
                        if ny<1 ; ny=1; end
                        if ny>glob.ySize; ny=glob.ySize; end
                        nx=x+xInc(a);
                        if nx<1 ; nx=1; end
                        if nx>glob.xSize; nx=glob.xSize; end
                        availableSpace=glob.SL(iteration)-topog(ny,nx);
                        if availableSpace>flowThick
                            depositHere=flowThick;
                        else
                            depositHere=availableSpace;
                        end
                        flowThick=flowThick-depositHere;

                        if depositHere > 0
                            glob.numberOfLayers(ny,nx,iteration)=glob.numberOfLayers(ny,nx,iteration)+1;
                            glob.facies{ny,nx,iteration}(glob.numberOfLayers(ny,nx,iteration)) = transFacies;
                            glob.thickness{ny,nx,iteration}(glob.numberOfLayers(ny,nx,iteration)) = depositHere;
                            topog(ny,nx) = topog(ny,nx) + depositHere;
                        end

                        if availableSpace<=0
                            checkSurr=1;
                        end

                        a=a+1;
                        if a>8
                            if checkSurr==1
                                flowThick = 0;
                            else
                                y=y+1;
                                a=1;
                                if y==glob.ySize
                                    flowThick=0;
                                end
                            end
                        end

                    end
                    flowDone=true;
                end
            else
                flowDone = true; % Should only happen if deepest cell is start cell 
                noRoute = noRoute + 1;
            end
        end
    end
end

function [foundDeeperCell, deepestX, deepestY] = findDeepestNeighbourCell(glob,topog,x,y)

    foundDeeperCell = false;
    deepestCellHeight = topog(y,x);
    deepestY = y; % These will be the returned values if no deeper cell is found. Important because used in gradient calc above
    deepestX = x;

    xInc = [0 0 1 -1 -1 1 -1  1 ];
    yInc = [-1 1 0 0 1 -1 -1  1 ];
    dummy = 0;% check if out of boundaries is the deepest cell

    for k = 1:8 % Loop through the adjacent cells

        % Calculate xco and yco from the value of x y modifed by the increments in
        % xInc and yInc. Should give a coord for each of the adjacent 8 cells
        xWrap = x + xInc(k);
        yWrap = y + yInc(k);

        if strcmp(glob.wrapRoutine,'unwrap') == 1
            % if on the grid edge, inplement closed boundary boundary
            if xWrap < 1; xWrap=1; end;
            if xWrap > glob.xSize; xWrap=glob.xSize; end;
            if yWrap < 1; yWrap = 1; end;
            if yWrap > glob.ySize; yWrap = glob.ySize; end;
        else
            % if on the grid edge, implement wrapping-mirrored-reflecting etc boundary
            if xWrap < 1; xWrap=glob.xSize; end;
            if xWrap > glob.xSize; xWrap=1; end;
            if yWrap < 1; yWrap = glob.ySize; end;
            if yWrap > glob.ySize; yWrap = 1; end;
        end

        % Check the current grid cell in the neighbour loop and see if it is the deepest found so far and not already visited
        % Cell is deeper
        if topog(yWrap, xWrap) < deepestCellHeight 
            foundDeeperCell = true;
            deepestCellHeight = topog(yWrap, xWrap); % added 5 Jan 2014 - elimnates depositional ridges bug on the slope
            deepestX = xWrap;
            deepestY = yWrap;
            
        % two (or more(adjacent) have the same depth. Move to the closest, accounting for diagonals          
        elseif topog(yWrap, xWrap) == deepestCellHeight
            foundDeeperCell = true;
            distDeep = sqrt(double((y-deepestY)^2 + (x-deepestX)^2));
            distNew = sqrt(double((y-yWrap)^2 + (x-xWrap)^2));
            if distNew <= distDeep
                deepestCellHeight = topog(yWrap, xWrap); % added 5 Jan 2014 - elimnates depositional ridges bug on the slope
                deepestX = xWrap;
                deepestY = yWrap;
            end
        end
    end
end
