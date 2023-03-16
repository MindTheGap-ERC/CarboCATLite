function [glob] = calculateTransportCrossPlatform(glob, iteration)

topog = zeros(glob.ySize, glob.xSize);
flowThick = 0;
prodFacies = uint8(0);
oneTransThickMap = num2cell(zeros(glob.ySize, glob.xSize)); % Map of thickness of deposited transported sediment for current iteration
oneTransFaciesMap = num2cell(uint16(zeros(glob.ySize, glob.xSize))); % Map of facies deposited by transport for current iteration
transFacies = uint16(0);
flowCount = uint16(0);
flowRoute = zeros(glob.ySize, glob.xSize);
transLength = uint16(0);
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
        
        %Calculate the gradient in the specified direction
        [nextX, nextY,foundDeeperCell] = currentDirection(x, y, glob,topog);
        flowGradient = topog(y,x) - topog(nextY,nextX);
        
        % If...
        % source cell contains primary producer facies 1,2, or 3 and are below sea level
        % flow thickness exceeds set threshold
        % flow gradient is less than the threshold
        % Call the cross platform transportation
        
        if foundDeeperCell==true && ...
                prodFacies <= glob.maxProdFacies &&  prodFacies > 0 && glob.wd(y,x,iteration) >= 0 && flowThick > glob.faciesThicknessPlotCutoff &&...
                flowGradient <= glob.transportGradient(prodFacies)
            
            transFacies = glob.transportProductFacies(prodFacies); % Get the transport facies produced from the in-situ facies
            
            
            % Remove the transportable thickness from the relevant array records
            glob.strata(y,x,iteration) = glob.strata(y,x,iteration) - flowThick;
            glob.thickness{y,x,iteration}(1) = glob.thickness{y,x,iteration}(1) - flowThick;
            
            [topog, glob] = calcOneCrossPlat(glob, iteration, topog, y, x, flowThick, prodFacies, transFacies, noRoute);
            
            
            flowCount = flowCount + 1;
            
            
            % If...
            % source cell contains primary producer facies 1,2, or 3 and are below sea level
            % flow thickness exceeds set threshold
            % flow gradient is greater than the threshold
            % Call the steepest descent
        elseif foundDeeperCell==true && ...
                prodFacies <= glob.maxProdFacies &&  prodFacies > 0 && glob.wd(y,x,iteration) >= 0 && flowThick > glob.faciesThicknessPlotCutoff &&...
                flowGradient > glob.transportGradient(prodFacies)
            
            transFacies = glob.transportProductFacies(prodFacies); % Get the transport facies produced from the in-situ facies
            
            
            % Remove the transportable thickness from the relevant array records
            glob.strata(y,x,iteration) = glob.strata(y,x,iteration) - flowThick;
            glob.thickness{y,x,iteration}(1) = glob.thickness{y,x,iteration}(1) - flowThick;
            
            [topog,glob] = calcOneTransportEvent(glob, iteration, topog, y, x, flowThick, prodFacies, transFacies, noRoute);
            flowCount = flowCount + 1;
        end
    end
end


totalTransported = 0.0;


for y=1:glob.ySize
    for x=1:glob.xSize
        checkProcess=strcmp(glob.siliciclasticsRoutine,'on');
        if checkProcess==1;
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
        % Increase deposited thickness by amount of deposition in all the transported
        % facies at y,x
        %deposited thickness is the amount of deposited without the
        %siliciclastic
        if glob.facies{y,x,iteration}(1)<=glob.maxProdFacies
            oneThickness=sum(glob.thickness{y,x,iteration}(:))-sum(glob.thickness{y,x,iteration}(1))-clast;
        else
            oneThickness=sum(glob.thickness{y,x,iteration}(:))-clast;
        end
        
        %Update the strata array
        glob.strata(y,x,iteration) = glob.strata(y,x,iteration) + oneThickness;
        
        totalTransported = totalTransported + oneThickness;
        
        % Decrease WD by amount of deposition
        glob.wd(y,x,iteration) = glob.wd(y,x,iteration) - oneThickness;
        
        if oneThickness>0; destCells=destCells+1; end
    end
end

fprintf('Trans %3.2f in %d flows to %d cells. Failed %d.', totalTransported, flowCount, destCells, noRoute);

end


function [topog,glob] = calcOneCrossPlat(glob, iteration, topog, startY,startX,flowThick, prodFacies, transFacies, noRoute)
% calculates the transport from cell startX startY and records the deposited thickness. The cross platform moves material in areas with
% gradients less than the threshold. When the threshold is exceeded the cross platform terminates, the material is passed to steepeset descent
% and the cross platform cannot start again.

% Initialize variables
flowDone = false;
flowRoute = zeros(glob.ySize, glob.xSize);
flowLength = uint16(0); % length of flow in number of grid cells
numFaciesInCell = uint8(0);
flowRoute(startY, startX) = flowLength;
steepest=false; %if steepest=false the steepest descent has not called
df=0.5; %deposited fraction

y = startY;
x = startX;


%If the gradient is greater than the threshold, the steepest
%descent algorithm is called. When the steepest has been called, the
%cross platfrom algorithm cannot run again.

while flowDone == false
    
    if steepest == false
        
        %Define current direction
        %Check the next cell in the current direction and calculate the flowGradient.
        
        [nextX, nextY,foundDeeperCell] = currentDirection(x, y, glob,topog);
        
        
        flowLength = flowLength + 1;
        flowRoute(nextY, nextX) = flowLength;
        
        
        %Accumulation at the production cell might create a steep gradient.
        %Skip the current cell and check the gradient for the cells away from the production cell
        
        if y==startY && x==startX
            flowGradient = 0;
        else
            flowGradient = topog(y,x) - topog(nextY,nextX);
        end
        
        %If flow gradient 
        if flowGradient < glob.transportGradient(prodFacies)
            
            
            %there is a deeper cell (and it is below SL)
            availableSpace=glob.SL(iteration)-topog(nextY,nextX);
            if availableSpace>=0 %&& foundDeeperCell==true
                
                if foundDeeperCell==0
                    y=nextY+1;
                    x = nextX;
                else
                    x = nextX;
                    y = nextY;
                end
                
                if y==glob.ySize %The flow terminates when the edge of the platform has been reached.
                    flowDone = true;
                end
                
            else %if the next cell is above SL or the current cell is the deepest cell. Then
                %deposit everything at the previous cell, check for deposition above SL and exit.
                %starting with the current cell and all tha adjacent cells
                xInc = [0 1 -1 0 1 -1 0 -1 1];
                yInc = [0 0 0 -1 -1 -1 1 1 1] ;
                a=1;
                while flowThick > 0 %Conservation of mass. All available material must be distributed somewhere.
                    wrapx=x+xInc(a);
                    wrapy=y+yInc(a);
                    
                    %The flow terminates when the edge of the platform has benn reached at y direction.
                    if wrapy>glob.ySize;wrapy=glob.ySize;flowThick=0;end
                    if wrapy<1;wrapy=1;flowThick=0;end
                    
                    %Wrapping boundary at x direction
                    if wrapx>glob.xSize;wrapx=1;end
                    if wrapx<1;wrapx=glob.xSize;end
                    
                    %No deposition above SL
                    availableSpace=glob.SL(iteration)-topog(wrapy,wrapx);
                    if availableSpace>0
                        if flowThick > availableSpace
                            depositHere = availableSpace;
                        else
                            depositHere = flowThick;
                        end
                        
                        flowThick = flowThick - depositHere;
                        
                        glob.numberOfLayers(wrapy,wrapx,iteration)=glob.numberOfLayers(wrapy,wrapx,iteration)+1;
                        glob.facies{wrapy, wrapx,iteration}(glob.numberOfLayers(wrapy,wrapx,iteration)) = transFacies;
                        glob.thickness{wrapy, wrapx,iteration}(glob.numberOfLayers(wrapy,wrapx,iteration)) = depositHere;
                        topog(wrapy,wrapx) = topog(wrapy,wrapx) + depositHere; % NB this means flows will interact with deposits of previous flow
                        
                        a=a+1;
                        if a>9
                            y=y+1;
                            a=1;
                            if y>=glob.ySize
                                flowThick=0;
                            end
                        end
                    else
                        a=a+1;
                        if a>9
                            y=y+1;
                            a=1;
                            if y>=glob.ySize
                                flowThick=0;
                            end
                        end
                    end
                    %                                end
                    %                                end
                end
                flowDone=true;
            end
        else % a local gradient greater than the threshold has been found. Terminate cross platform and call steepest descent.
            steepest = true;
        end
        
    else % local Gradient greater than the threshold. Call steepest.
        
        [topog,glob] = calcOneTransportEvent(glob, iteration, topog, y, x, flowThick, prodFacies, transFacies, noRoute);
        flowDone = true;
        
    end
end
end

function [topog, glob] = calcOneTransportEvent(glob, iteration, topog, startY, startX, flowThick, prodFacies, transFacies, noRoute)
% calculates the transport from cell startX startY and records the deposited thickness in
% oneTransThickMap

% Initialize variables
flowDone = false;
flowRoute = zeros(glob.ySize, glob.xSize);
flowLength = uint16(0); % length of flow in number of grid cells
numFaciesInCell = uint8(0);
flowRoute(startY, startX) = flowLength;
flowGradient = 0;
distLimit=3;

y = startY;
x = startX;

while flowDone == false
    
    [foundDeeperCell, deepestX, deepestY] = findDeepestNeighbourCell(topog, x, y,glob);
    flowGradient = topog(y,x) - topog(deepestY, deepestX);
    
    % Lowers cells found adjacent to the current flow cell, and gradient > minimum threshold, so deposit and
    % prepare to carry on flow
    
    %TRANSPORT
    if foundDeeperCell == true
        if flowGradient > glob.transportGradient(prodFacies)
            flowLength = flowLength + 1;
            flowRoute(deepestY, deepestX) = flowLength;
            x = deepestX;
            y = deepestY;
            flowDone = false; % Because there may be yet deeper cells adjacent to this one...
        else
            % Calculate the thickness to deposit based on a proportional decay of
            % thickness and a minimum cutoff
            
            if flowThick < 0.01 % gradient too small and flow too thin
                depositHere = flowThick;
                flowThick = 0;
                flowDone = true;
                
            else %gradient too small and thick flow
                
                depositHere = flowThick * 0.5;
                %-------
                availableSpace=glob.SL(iteration)-topog(y,x);
                if availableSpace==0
                   x = deepestX;
                   y = deepestY;
                end
                if depositHere>availableSpace
                    depositHere=availableSpace;
                end
                %--------
                flowThick = flowThick - depositHere;
            end
            
            glob.numberOfLayers(y,x,iteration)=glob.numberOfLayers(y,x,iteration)+1;
            glob.facies{y, x,iteration}(glob.numberOfLayers(y,x,iteration)) = transFacies;
            glob.thickness{y, x,iteration}(glob.numberOfLayers(y,x,iteration)) = depositHere;
            topog(y, x) = topog(y, x) + depositHere;
            
        end
        
        % DEPOSIT
        % Else no lower cell found, so deposit all flow at the last deepest cell x y unless it is the start cell
    else if not(x == startX && y == startY)
            availableSpace=glob.SL(iteration)-topog(y,x);
            if flowThick<=availableSpace;
                glob.numberOfLayers(y,x,iteration)=glob.numberOfLayers(y,x,iteration)+1;
                glob.facies{y, x,iteration}(glob.numberOfLayers(y,x,iteration)) = transFacies;
                glob.thickness{y, x,iteration}(glob.numberOfLayers(y,x,iteration)) = flowThick;
                topog(y, x) = topog(y, x) + flowThick; % NB this means flows will interact with deposits of previous flow
                
                flowDone = true; % End the flow because no deeper cell found or below gradient threshold so deposit in this low
            else
                %NB add this on 26/5/2015 to avoid building over sea level - estani
                %& george
                depositHere=availableSpace;
                flowThick=flowThick-depositHere;
                glob.numberOfLayers(y,x,iteration)=glob.numberOfLayers(y,x,iteration)+1;
                glob.facies{y, x,iteration}(glob.numberOfLayers(y,x,iteration)) = transFacies;
                glob.thickness{y, x,iteration}(glob.numberOfLayers(y,x,iteration)) = depositHere;
                topog(y, x) = topog(y, x) + depositHere;
                
                
                xInc = [0 -1 1 -1 1 -1 1 0 ];
                yInc = [-1 1 -1 -1 0 0 1 1 ];
                a=1;
                checkSurr=0;
                
                while flowThick>0;
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
                    
                    
                    if depositHere>0;
                        glob.numberOfLayers(ny,nx,iteration)=glob.numberOfLayers(ny,nx,iteration)+1;
                        glob.facies{ny,nx,iteration}(glob.numberOfLayers(ny,nx,iteration)) = transFacies;
                        glob.thickness{ny,nx,iteration}(glob.numberOfLayers(ny,nx,iteration)) = depositHere;
                        topog(ny,nx) = topog(ny,nx) + depositHere;
                        
                    end
                    
                    if availableSpace<=0;
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
            flowDone = true; % Should only happen if deepest cell is start cell */
            noRoute = noRoute + 1;
        end
    end
end

%     fprintf('\n');
%     for k=1:glob.ySize
%        for m=1:glob.xSize
%         if flowRoute(k,m)>0 fprintf('(%d %d) %d %5.4f ',m,k,flowRoute(k,m), topog(k,m)); end
%        end
%     end
%     fprintf('\n');
end



function [nextX, nextY,foundDeeperCell] = currentDirection(x, y, glob,topog)
foundDeeperCell = false;
deepestCellHeight = topog(y,x);
nextY = y; % These will be the returned values if no deeper cell is found. Important because used in gradient calc above
nextX = x;
%     xInc = [0 -1 1 -1 1 -1 1 0 ];
%     yInc = [-1 1 -1 -1 0 0 1 1 ];
    xInc = [0 -1 1];
    yInc = [1 1 1 ];


%dummy=0;% check if out of boundaries is the deepest cell
for k = 1:3 % Loop through the adjacent cells
    
    % Calculate xco and yco from the value of x y modifed by the increments in
    % xInc and yInc. Should give a coord for each of the adjacent 8 cells
    xWrap = x + xInc(k);
    yWrap = y + yInc(k);
    
    checkProcess=strcmp(glob.wrapRoutine,'unwrap');
    if checkProcess==1;
        %if in the edge, close boundary
        if xWrap < 1; xWrap=1; end;
        if xWrap > glob.xSize; xWrap=glob.xSize; end;
        if yWrap < 1; yWrap = 1; end;
        if yWrap > glob.ySize; yWrap = glob.ySize; end;
    else
        %wrap
        if xWrap < 1; xWrap=glob.xSize; end;
        if xWrap > glob.xSize; xWrap=1; end;
        if yWrap < 1; yWrap = glob.ySize; end;
        if yWrap > glob.ySize; yWrap = 1; end;
    end
    
    % Check the current cell in the neighbour loop and see if it is the
    % deepest found so far and not already visited
    %Cell is deeper
    if topog(yWrap, xWrap) < deepestCellHeight %&& flowRoute(yWrap,xWrap) == 0
        foundDeeperCell = true;
        deepestCellHeight = topog(yWrap, xWrap); % added 5 Jan 2014 - elimnates depositional ridges bug on the slope
        nextX = xWrap;
        nextY = yWrap;
        %two (or more cells) have the same depth. Move to the closest
        %one
    elseif topog(yWrap, xWrap) == deepestCellHeight
        distDeep = sqrt(double((y-nextY)^2 + (x-nextX)^2));
        distNew = sqrt(double((y-yWrap)^2 + (x-xWrap)^2));
        if distNew <= distDeep
            foundDeeperCell = true;
            deepestCellHeight = topog(yWrap, xWrap); % added 5 Jan 2014 - elimnates depositional ridges bug on the slope
            nextX = xWrap;
            nextY = yWrap;
        end
    end
end
end

function [foundDeeperCell, deepestX, deepestY] = findDeepestNeighbourCell(topog,x,y,glob)
n=0;
foundDeeperCell = false;
deepestCellHeight = topog(y,x);
deepestY = y; % These will be the returned values if no deeper cell is found. Important because used in gradient calc above
deepestX = x;
    xInc = [0 -1 1 -1 1 -1 1 0 ];
    yInc = [-1 1 -1 -1 0 0 1 1 ];


%dummy=0;% check if out of boundaries is the deepest cell
for k = 1:8 % Loop through the adjacent cells
    
    % Calculate xco and yco from the value of x y modifed by the increments in
    % xInc and yInc. Should give a coord for each of the adjacent 8 cells
    xWrap = x + xInc(k);
    yWrap = y + yInc(k);
    
    checkProcess=strcmp(glob.wrapRoutine,'unwrap');
    if checkProcess==1;
        %if in the edge, close boundary
        if xWrap < 1; xWrap=1; end;
        if xWrap > glob.xSize; xWrap=glob.xSize; end;
        if yWrap < 1; yWrap = 1; end;
        if yWrap > glob.ySize; yWrap = glob.ySize; end;
    else
        %wrap
        if xWrap < 1; xWrap=glob.xSize; end;
        if xWrap > glob.xSize; xWrap=1; end;
        if yWrap < 1; yWrap = glob.ySize; end;
        if yWrap > glob.ySize; yWrap = 1; end;
    end

    % Check the current cell in the neighbour loop and see if it is the
    % deepest found so far and not already visited
    %Cell is deeper
    if topog(yWrap, xWrap) < deepestCellHeight %&& flowRoute(yWrap,xWrap) == 0
        foundDeeperCell = true;
        deepestCellHeight = topog(yWrap, xWrap); % added 5 Jan 2014 - elimnates depositional ridges bug on the slope
        deepestX = xWrap;
        deepestY = yWrap;
        %two (or more cells) have the same depth. Move to the closest
        %one
    elseif topog(yWrap, xWrap) == deepestCellHeight
        distDeep = sqrt(double((y-deepestY)^2 + (x-deepestX)^2));
        distNew = sqrt(double((y-yWrap)^2 + (x-xWrap)^2));
        if distNew <= distDeep
            foundDeeperCell = true;
            deepestCellHeight = topog(yWrap, xWrap); % added 5 Jan 2014 - elimnates depositional ridges bug on the slope
            deepestX = xWrap;
            deepestY = yWrap;
        end
    end
end
n=n+1;
end


