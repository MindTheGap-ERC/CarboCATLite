function plotFinalGraphics(glob, stats, iteration, OutputName)

    %platMarginTraj = calculatePlatformMarginTrajectory(glob, iteration, round(glob.xSize / 2));
    %exportgraphics(gcf,'initial_conditions.pdf','ContentType','vector')    
    fprintf('Drawing the dip section and the chronostrat diagram...');
    plotDipSections(glob, stats, iteration); %cross and chrono
    fprintf('Done\n');
    
    % autosave figure
    disp('Saving figure, please wait...')
    exportgraphics(gcf,append(OutputName,'_dip_section_and_chronostrat.pdf'),'ContentType','vector')    
    disp('figure saved')
    close all
    %fprintf('Drawing the 3D block diagram...');
    %plot3DBlock(glob, iteration); %cross and chrono
    %fprintf('Done\n');
end 

