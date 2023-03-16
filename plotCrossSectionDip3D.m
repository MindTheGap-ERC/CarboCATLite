function plotCrossSectionDip3D(x, glob, iteration)

    thicknessPerY=sum(glob.numberOfLayers(:,x,2:end),3);
    long = find(thicknessPerY>0, 1, 'last' );
    if isempty(long)
        long=glob.ySize;
    end
     
    % First find the plot limits for the z-axis
    minDepth = max(max(glob.strata(:,:,iteration))); % Find the highest (so shallowest) values in the strata array
    minDepth = minDepth * 1.1; % Add 10% to the minimum depth
    maxDepth = min(min(glob.strata(:,:,1))); % Find the lowest (ie deepest) values in strata array
    maxDepth = maxDepth * 1.1; % Add 10% to the maximum depth
   
%     % Use maxdepth to draw a light-grey solid colour basement along the x-axis bottom of the section
%     % Use j as the loop counter, because x is used as the line of section x-coord
%     yco = [double(glob.ySize)*glob.dx, double(glob.ySize)*glob.dx, double(glob.ySize)*glob.dx, double(glob.ySize)*glob.dx]; 
%     for j = 1:glob.xSize
%         xco = [double(j-0.5)*glob.dx, double(j-0.5)*glob.dx, double(j+0.5)*glob.dx, double(j+0.5)*glob.dx]; 
%         zco = [maxDepth, glob.strata(glob.ySize,j,1), glob.strata(glob.ySize,j,1), maxDepth];
%         patch(xco, yco, zco, [0.7 0.7 0.7],'EdgeColor','none');
%     end
    
    % Because everything else will plot along the cross-section line at x, set xco here for use below
    xco = [x*glob.dx,x*glob.dx,x*glob.dx,x*glob.dx]; % Everything will plot along cross-section line x=1
    
    % Now use maxdepth to draw a light grey solid colour basement along the y-axis bottom of the section
    for y = 1:long%glob.ySize-1
        yco = [double(y-0.5)*glob.dx, double(y-0.5)*glob.dx, double(y+0.5)*glob.dx, double(y+0.5)*glob.dx]; 
        zco = [maxDepth, glob.strata(y,x,1), glob.strata(y,x,1), maxDepth];
        patch(xco, yco, zco, [0.7 0.7 0.7],'EdgeColor','none');
    end
    
    % Loop along the section and through timelines to draw the cross section
    for y = 1:long
       for k=2:iteration
            
            cell = glob.numberOfLayers(y,x,k);
            while cell > 0

               yco = [double(y-0.5)*glob.dx, double(y-0.5)*glob.dx, double(y+0.5)*glob.dx, double(y+0.5)*glob.dx];

               allThick = sum(glob.thickness{y,x,k}(1:cell));
                oneThick = sum(glob.thickness{y,x,k}(1:cell-1));
                top = glob.strata(y,x,k-1)+allThick;
                bottom = glob.strata(y,x,k-1)+oneThick;
                fCode = glob.facies{y,x,k}(cell); % Note this is zero for no depositon, 9 for subaerial hiatus

                % Draw the in-situ production facies first
                if fCode > 0
                    zco = [bottom, top, top, bottom];
                    faciesCol = [glob.faciesColours(fCode,1) glob.faciesColours(fCode,2) glob.faciesColours(fCode,3)];
                    patch(xco, yco, zco, faciesCol,'EdgeColor','none');
                end
                
                cell = cell - 1;
            end
        end
    end

    % Loop through iterations and draw timelines
    for i=1:glob.timeLineCount

        k = glob.timeLineAge(i);

        if k <= iteration
            for y = 1:long-1%glob.ySize-1
                % Draw a marker line across the top and down/up the side of a particular grid cell
                yco = [y*glob.dx, (y+1)*glob.dx, (y+1)*glob.dx];
                zco = [glob.strata(y,x,k), glob.strata(y,x,k), glob.strata(y+1,x,k)];
                line([x*glob.dx,x*glob.dx,x*glob.dx], yco, zco, 'LineWidth',2, 'color', 'black');
            end
            line([x*glob.dx,x*glob.dx], [(y+1)*glob.dx,(y+2)*glob.dx], [glob.strata(y+1,x,k), glob.strata(y+1,x,k)],'LineWidth',2, 'color', 'black');
        end
    end
end