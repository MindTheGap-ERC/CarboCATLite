function plotChronostratSectionDip( xPos,chronoPlot, glob, iteration)
 
    subplot(chronoPlot);
    thicknessPerY=sum(glob.numberOfLayers(:,xPos,2:end),3);
    longA=find(thicknessPerY>0, 1, 'last' );  
    
    for i=0:10
        patch(0,0,i); % use a dummy patch to force colour map to range 0-10
    end

    for k=1:iteration-1
        for y = 1:longA
            % xco is a vector containing x-axis coords for the corner points of
            % each strat section grid cell. Yco is the equivalent y-axis vector
            xco = [y*glob.dx, y*glob.dx, (y+1)*glob.dx,(y+1)*glob.dx];
            
            faciesList = glob.facies{y,xPos,k+1};
            oneThickness = glob.strata(y,xPos, k+1) - glob.strata(y,xPos,k);
            
            if max(faciesList) > 0
                cellHeight = glob.deltaT / (glob.numberOfLayers(y,xPos,k+1));
            else
                cellHeight = glob.deltaT;
            end
            cellBase = k*glob.deltaT;

            % Now draw the facies, however many there are...
            % cellBase = cellBase+cellHeight; % to account for in-situ facies cell
            for fLoop = 1:glob.numberOfLayers(y,xPos,k+1)

                tco = [cellBase, cellBase+cellHeight, cellBase+cellHeight, cellBase];
                fCode = faciesList(fLoop);
                if fCode > 0 && oneThickness > 0.01
                    faciesCol = [glob.faciesColours(fCode,1) glob.faciesColours(fCode,2) glob.faciesColours(fCode,3)];
                    patch(xco, tco, faciesCol,'EdgeColor','none');
                end
                cellBase = cellBase + cellHeight;
            end
        end
    end

    % Force 2 ticks on the y axis
    axis([1*glob.dx, (longA+1)*glob.dx, 0, glob.deltaT * iteration]);
    xlabel('Distance (km)','FontSize',11);
    ylabel('E.M.T. (My)','FontSize',11);
    set(gca,'FontSize',11)
end