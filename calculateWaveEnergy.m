function [glob] = calculateWaveEnergy(glob, iteration)
% Calculates the wave energy dissipation based on the Terrat Et AL, 1995

    % Define basic wave parameters treated as constants in the model
    meanWaveHeight = 1.0; % height of the wave (m), but not really significant because wave energies are normalised
    waveConst = (0.3 * ((meanWaveHeight /.78) / meanWaveHeight)^-2);
    glob.waveBreakDepth = 1.0;

    fetchDistance = zeros(glob.ySize,glob.xSize);
    waveAmplitude = zeros(glob.ySize,glob.xSize);
    
    for x = 1:glob.xSize
        
        % Calculate wave amplitude as a function of water depth across the grid
        for k = glob.ySize: -1: 1
            waveAmplitude(k,x) = (0.3 * (glob.wd(k,x,iteration) / meanWaveHeight)^-2) / waveConst;
        end
        
        % Calculate fetch length as the length of each y axis traverse where water depth > wave break depth
        k = glob.ySize; % Assumed that the waves originate at y = glob.ySize end of the grid
        while k > 1
            oneFetchLength = 0;
            while k >= 1 && glob.wd(k,x,iteration) > waveAmplitude(k,x)
                fetchDistance(k,x) = oneFetchLength * glob.dx;
                oneFetchLength = oneFetchLength + 1;
                k = k - 1;
            end
            k = k - 1;
        end
    end
    
    % Division of zero water depth by ^-2 creates inf amplitude values so replace these with zero
    waveAmplitude(isinf(waveAmplitude)) = 0;
    
    % Use the maximum values in each map to normalise the values
    maxFetchDistance = max(max(fetchDistance));
    maxWaveAmplitude = max(max(waveAmplitude));
    normFetchDistance = fetchDistance ./ maxFetchDistance;
    normWaveAmplitude = waveAmplitude ./ maxWaveAmplitude;

    % Calcluate a wave energy approximation that is a sum of the fetch and amplitude effects
    glob.waveEnergy = normFetchDistance;
    glob.waveEnergy(isnan(glob.waveEnergy)) = 0; % Set any NaN values to zero
    
    % Finally, smooth the wave energy array to represent time-averaged effects of various wave sizes, overrunning platform margin, etc
%     kernel = 0.125 * ones(3); % Create a 3x3 low-pass filter kernel
%     paddedWaveEnergy = zeros(glob.ySize, glob.xSize * 2); % Convolution has unwanted edge effects so need to add padding around wave energy matrix edges
%     padWidth = round(glob.xSize / 2); % Define the size of the padded edges
%     paddedWaveEnergy(:,1:padWidth) = repmat(glob.waveEnergy(:,1), 1, padWidth); % Add the pad on the x=1 side
%     paddedWaveEnergy(:,(round(glob.xSize * 2) - padWidth + 1): round(glob.xSize*2)) = repmat(glob.waveEnergy(:,glob.xSize), 1, padWidth); % Add the pad on the x=xSize side
%     paddedWaveEnergy(:,(padWidth + 1):((round(glob.xSize * 2) - padWidth))) = glob.waveEnergy;
%     
%     paddedWaveEnergy = conv2(paddedWaveEnergy, kernel, 'same');
%     glob.waveEnergy(1:glob.ySize, 1:glob.xSize) = paddedWaveEnergy(1:glob.ySize, (padWidth+1): (round(glob.xSize * 2) - padWidth));
    glob.waveEnergy = glob.waveEnergy ./ max(max(glob.waveEnergy)); % Renormalise 0-1 after smoothing
end