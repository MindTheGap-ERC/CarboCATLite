function [glob,stats,graph] = runCAModelGUI(glob, stats, graph, OutputName)
% Run the model by executing all the functions specified in the processes input file

    order = 1; % rotates the order of facies neighbour checking in calculateFaciesCA to avoid bias for any one facies
    iteration = 2;


    while iteration <= glob.totalIterations

        fprintf('It:%d EMT %4.3f ', iteration, glob.deltaT * iteration);

        glob.strata(:,:,iteration) = glob.strata(:,:,iteration-1);
        
        glob = calculateSubsidence(glob, iteration);

        glob = calculateWaterDepth(glob, iteration); % NB water depth required for facies distrib so needs to be calculated first

        if strcmp(glob.waveRoutine,'on') == 1
            glob = calculateWaveEnergy(glob,iteration);
        end

        % Choose if the carbonate concentration routine should be included-------------------------------------
        if strcmp(glob.concentrationRoutine,'on') == 1
            glob = diffuseConcentration(glob,iteration);
        end

        % Calculate facies distribtion whichever CA routine has been selected ----------------------------------------------------------------------
        switch glob.CARoutine
            case 'simpleWave'
                glob = calculateFaciesWaveDependentSimple(glob, iteration);
            case 'orderedCA'
                glob = calculateFaciesCARotationOrder(glob, iteration, order);
            case 'productionCA'
                glob = calculateFaciesCAProdDependent(glob, iteration);
            case 'waveCA'
                glob = calculateFaciesCAWaveDependent(glob, iteration);
            case 'waveHybridCA'
                glob = calculateFaciesCAWaveDependentHybrid(glob, iteration);
            otherwise
                glob = calculateFaciesCARotationOrder(glob, iteration, order); % Simplest CA option is the default
        end    

        % input and diffusionally transport siliciclastics---------------------------------------------------------------------
        if strcmp(glob.siliciclasticsRoutine,'on') == 1
            glob = diffuseSiliciclastic (glob,iteration);
        end

        % Carbonate production-----------------------------------------------------------------------------------
        glob = calculateProduction(glob, iteration);

        % Choose carbonate transportation--------------------------------------------------------------------        
        if strcmp(glob.transportationRoutine,'steepestSlope') == 1
            glob = calculateTransport(glob, iteration);
        else
            glob = calculateTransportCrossPlatform (glob, iteration);
        end

        % Choose if the soil deposition routine should be included---------------------------------------------------------------
        checkProcess=strcmp(glob.soilRoutine,'on');
        if checkProcess==1
            glob = calculateSoilDeposition (glob,iteration);
        end    

        stats = recordFaciesVolumes(glob, stats, iteration);
        
        % Control cycle through facies for neighbour checking
        order = order + 1;
        if order > glob.maxProdFacies; order = 1; end
        iteration = iteration + 1;
        fprintf('\n');  
    end

    %close (theMovie);

    % Reverse the effect of the final increment to avoid problems with array overflows in graphics etc
    if iteration > glob.totalIterations
        iteration = iteration - 1;
    end
        
    % save model outputs
    save(append(OutputName,".mat"), "glob")

    fprintf('Model complete after %d iterations and output saved\n',iteration);

end
