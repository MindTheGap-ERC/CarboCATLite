function plotFaciesVolumeCurves(PPlot,glob, stats, iteration)
% Plot the production rate supply curve through time for each facies

    subplot(PPlot);
    t = 1:iteration;
    
    for f = 1:glob.maxProdFacies * 2    % So plot the producing facies, and each transported facies derivative
        xco = stats.totalFaciesVolume(t, f);
        lineCol = [glob.faciesColours(f,1) glob.faciesColours(f,2) glob.faciesColours(f,3)];
        line(xco, t, 'color', lineCol, 'LineWidth', 2);
    end
    
    xlabel('Facies volumes (m3)','FontSize',11);
    set(gca,'FontSize',11);  
    grid on; 
end