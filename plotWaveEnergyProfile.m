function plotWaveEnergyProfile(xPos, waveProfilePlot, glob)

    subplot(waveProfilePlot);

    if strcmp(glob.waveRoutine,'on') == 1
        y = 1:glob.ySize;
        waveEnergyProfile = glob.waveEnergy(y,xPos);
        line(y, waveEnergyProfile, 'Color', [0.7,0.0,1.0], 'LineWidth',2, 'LineStyle','-.');
    end   
    
    ylabel('Wave energy');
    grid on;
end