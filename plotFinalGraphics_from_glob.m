function plotFinalGraphics_from_glob(glob, OutputName)
    % plots chronostrat diagram and b asin transect from glob object
    
    %platMarginTraj = calculatePlatformMarginTrajectory(glob, iteration, round(glob.xSize / 2));
    %exportgraphics(gcf,'initial_conditions.pdf','ContentType','vector')    
    fprintf('Drawing the dip section and the chronostrat diagram...');
    iteration=glob.totalIterations;
    % ScreenSize is a four-element vector: [left, bottom, width, height]:
    scrsz = get(0,'ScreenSize'); % vector 
    % position requires left bottom width height values. screensize vector is in this format 1=left 2=bottom 3=width 4=height
    figure('Visible','on','Position',[20 scrsz(2)+20 scrsz(3)*0.9 scrsz(4)*0.6]);

    % plot includes cross section and chronostrat plotted on the same x axis

    xPos = round(glob.xSize / 2); % So line of section half-way across map grid
    
    waveProfilePlot = subplot('Position',[0.03, 0.90, 0.7, 0.09]); % position coords are x,y,width,height
    plotWaveEnergyProfile(xPos, waveProfilePlot, glob);
    
    crossSectionPlot = subplot('Position',[0.03, 0.50, 0.7, 0.40]);
    plotCrossSectionDip2D(xPos, crossSectionPlot, glob, iteration); 

    chronoPlot = subplot('Position',[0.03, 0.075, 0.7, 0.4]);
    plotChronostratSectionDip(xPos,chronoPlot, glob,iteration);
   
    SLPlot = subplot('Position',[0.75, 0.075, 0.1, 0.4]);
    plotEustaticCurve(SLPlot,glob, iteration);   
    fprintf('Done\n');
    
    % autosave figure
    disp('Saving figure, please wait...')
    exportgraphics(gcf,append(OutputName,'_dip_section_and_chronostrat.pdf'),'ContentType','vector')    
    disp('figure saved')
    close all

end 

