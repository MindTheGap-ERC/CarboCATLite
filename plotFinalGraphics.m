function plotFinalGraphics(glob, stats, iteration)

    %platMarginTraj = calculatePlatformMarginTrajectory(glob, iteration, round(glob.xSize / 2));

    fprintf('Drawing the dip section and the chronostrat diagram...');
    plotDipSections(glob, stats, iteration); %cross and chrono
    fprintf('Done\n');

     % autosave figure
    disp('Saving figure, please wait...')
    exportgraphics(gcf,'dip_section_and_chronostrat_scenarioA.pdf','ContentType','vector')    
    disp('figure saved')
    
    %fprintf('Drawing the 3D block diagram...');
    %plot3DBlock(glob, iteration); %cross and chrono
    %fprintf('Done\n');
end 

