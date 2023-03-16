function [glob,graph] = plot3DBlock(glob, iteration)

    % ScreenSize is a four-element vector: [left, bottom, width, height]:
    scrsz = get(0,'ScreenSize'); % vector 
    % Position requires left bottom width height values. screensize vector is in this format 1=left 2=bottom 3=width 4=height
    figure('Visible','on','Position',[1 scrsz(2)+20 scrsz(3)*0.8 scrsz(4)*0.8]);
    
    plotCrossSectionDip3D(1, glob, iteration);
    plotCrossSectionStrike3D(glob.ySize, glob, iteration);
    plot3DPlanView(glob, iteration);
    
    % Draw the final sea-level as a rectangle
    yco = [glob.dx, glob.ySize*glob.dx, glob.ySize*glob.dx, glob.dx];
    zco = [glob.SL(iteration), glob.SL(iteration), glob.SL(iteration), glob.SL(iteration)];
    xco = [glob.dx, glob.dx, (glob.xSize+1)*glob.dx, (glob.xSize+1)*glob.dx];
    line(xco, yco, zco, 'LineWidth',2, 'color', 'blue');
    
    xlabel('X Distance (m)','FontSize',11);
    ylabel('Y Distance (m)','FontSize',11);
    zlabel('Elevation (m)','FontSize',11);
    grid on;
    view(-135,50);
    ax = gca;
    ax.DataAspectRatio = [1, 3, 0.03]; % x-scale=1, y-scale = 3, z-scale = 0.002 Change these scalings to alter the aspect ratio of the 3d plot
end

function plot3DPlanView(glob, iteration)

    % Loop along the section and through timelines to draw the cross section
    for x = 1:glob.xSize
        
        for y = 1:glob.ySize-1
         
            % Find the youngest iteration that has deposition
            t = iteration;
            while ((glob.numberOfLayers(y,x, t)) == 0 || sum(glob.thickness{y,x,t}(:)) < 0.01)  && t > 1
                t = t - 1;
            end
           
            topCell = glob.numberOfLayers(y,x, t);
            if topCell > 0
                
                fCode = glob.facies{y,x,t}(topCell); % Note this is zero for no depositon, 9 for subaerial hiatus
                if fCode > 0 
                    faciesCol = [glob.faciesColours(fCode,1) glob.faciesColours(fCode,2) glob.faciesColours(fCode,3)];
                else
                    faciesCol = [1,1,1]; 
                end
                
                % Draw the top planform patch
                zco = [glob.strata(y,x,t), glob.strata(y,x,t), glob.strata(y,x,t), glob.strata(y,x,t)];
                xco = [((x-0.5)*glob.dx), ((x+0.5)*glob.dx), ((x+0.5)*glob.dx), ((x-0.5)*glob.dx)];
                yco = [double(y-0.5)*glob.dx, double(y-0.5)*glob.dx, double(y+0.5)*glob.dx, double(y+0.5)*glob.dx];
                patch(xco, yco, zco, faciesCol , 'EdgeColor','none');
                
                % Draw the front vertical panel patch
                zco = [glob.strata(y,x,t), glob.strata(y,x,t), glob.strata(y+1,x,t), glob.strata(y+1,x,t)];
                xco = [((x-0.5)*glob.dx), ((x+0.5)*glob.dx), ((x+0.5)*glob.dx), ((x-0.5)*glob.dx)];
                yco = [double(y+0.5)*glob.dx, double(y+0.5)*glob.dx, double(y+0.5)*glob.dx, double(y+0.5)*glob.dx];
                patch(xco, yco, zco, faciesCol , 'EdgeColor','none');
            end
        end
    end
    
    % Draw dip-direction line along cell boundaries
    for x = 1:glob.xSize
        xco = ones(1,glob.ySize) .* double(x*glob.dx);
        yco = double(1:glob.ySize) .* glob.dx;
        zco = glob.strata(1:glob.ySize,x,iteration);
        line(xco, yco, zco, 'LineWidth',2, 'color', 'black');
    end
    
    xco = ones(1,glob.ySize) .* double((x+1)*glob.dx);
    line(xco, yco, zco, 'LineWidth',2, 'color', 'black');
end