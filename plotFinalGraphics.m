function plotFinalGraphics(glob, stats, iteration)

    %platMarginTraj = calculatePlatformMarginTrajectory(glob, iteration, round(glob.xSize / 2));

    fprintf('Drawing the dip section and the chronostrat diagram...');
    plotDipSections(glob, stats, iteration); %cross and chrono
    fprintf('Done\n');
    
    %fprintf('Drawing the 3D block diagram...');
    %plot3DBlock(glob, iteration); %cross and chrono
    %fprintf('Done\n');
end 

