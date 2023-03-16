function plotEustaticCurve(SLPlot, glob, iteration)
    
    subplot(SLPlot);

    % Sealevel curve

    % Force four ticks on the y axis and plot the y axis on the right hand side of the plot
    set(SLPlot,'YAxisLocation','right');
    set(SLPlot,'YTick',[0 (glob.deltaT * iteration * 0.25) (glob.deltaT * iteration * 0.5) (glob.deltaT * iteration * 0.75) (glob.deltaT * iteration)]);

    for k=1:iteration-1
        % now plot the sea-level curve line for the same time interval
        lineColor = [0.0 0.2 1.0];
        x = [double(glob.ySize)+glob.SL(k) double(glob.ySize)+glob.SL(k+1)];
        y = [double(k)*glob.deltaT double(k+1)*glob.deltaT];
        line(x,y, 'color', lineColor);
    end

    xlabel('Eustatic Sealevel (m)','FontSize',11);
    set(SLPlot,'YTick',[0 glob.deltaT * iteration]);
    set(gca,'FontSize',11)

end