function plotCrossSectionDip2D(x, crossSectionPlot, glob, iteration)

    subplot(crossSectionPlot);
    thicknessPerY=sum(glob.numberOfLayers(:,x,2:end),3);
    long = find(thicknessPerY>0, 1, 'last' );
    if isempty(long)
        long=glob.ySize;
    end
      
    % First delete the previous plot with a single large white patch
    minDepth = max(max(glob.strata(:,:,iteration))); % Find the highest (so shallowest) values in the strata array
    minDepth = minDepth * 1.1; % Add 10% to the minimum depth
    maxDepth = min(min(glob.strata(:,:,1))); % Find the lowest (ie deepest) values in strata array
    maxDepth = maxDepth * 1.1; % Add 10% to the maximum depth

    patch([0 long*glob.dx long*glob.dx 0], [minDepth minDepth maxDepth maxDepth], [1 1 1], 'EdgeColor','none');
   
    % Now reuse maxdepth to draw a light grey solid colour basement at the bottom of the section
    for y = 1:long%glob.ySize-1
        xco = [y*glob.dx, y*glob.dx, (y+1)*glob.dx, (y+1)*glob.dx]; 
        zco = [maxDepth, glob.strata(y,x,1), glob.strata(y,x,1), maxDepth];
        patch(xco, zco, [0.7 0.7 0.7],'EdgeColor','none');
    end

    % Loop along the section and through timelines to draw the cross section
    for y = 1:long
       for k=2:iteration
            
            cell = glob.numberOfLayers(y,x,k);
            while cell > 0

               xco = [y*glob.dx, y*glob.dx, (y+1)*glob.dx, (y+1)*glob.dx];

               allThick = sum(glob.thickness{y,x,k}(1:cell));
                oneThick = sum(glob.thickness{y,x,k}(1:cell-1));
                top=glob.strata(y,x,k-1)+allThick;
                bottom=glob.strata(y,x,k-1)+oneThick;
                fCode = glob.facies{y,x,k}(cell); % Note this is zero for no depositon, 9 for subaerial hiatus

                % Draw the insitu production facies first
                if fCode > 0
                    zco = [bottom, top,top, bottom];
                    faciesCol=[glob.faciesColours(fCode,1) glob.faciesColours(fCode,2) glob.faciesColours(fCode,3)]    ;
                    patch(xco, zco, faciesCol,'EdgeColor','none');
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
                % draw a marker line across the top and down/up the side of a particular grid cell
                xco = [y*glob.dx, (y+1)*glob.dx, (y+1)*glob.dx];
                yco = [glob.strata(y,x,k), glob.strata(y,x,k), glob.strata(y+1,x,k)];
                line(xco, yco, 'LineWidth',2, 'color', 'black');
            end
            line([(y+1)*glob.dx,(y+2)*glob.dx],[glob.strata(y+1,x,k), glob.strata(y+1,x,k)],'LineWidth',2, 'color', 'black');
        end
    end

    % Draw the final sea-level
    xco = [1*glob.dx, (long+1)*glob.dx];
    yco = [glob.SL(iteration) glob.SL(iteration)];
    line(xco,yco, 'LineWidth',2, 'color', 'blue');
    
    if minDepth>glob.SL(iteration); mm=minDepth; else mm=glob.SL(iteration); end
    axis([1 (long+1)*glob.dx maxDepth mm]);
    l=numel(num2str(round(maxDepth)))-1;
    maxD=(10^(l-1))*(ceil(maxDepth/(10^(l-1))));
    
    ylabel('Elevation (m)','FontSize',11);
    set(gca,'FontSize',11)
    set(crossSectionPlot,'XTickLabel',[]);
    grid on;
end