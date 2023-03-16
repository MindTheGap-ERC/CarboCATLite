function [glob, inputSuccessFlag] = inputOneModelParams(glob, fName, fPName)

    inputSuccessFlag = 1; % Assume initialisation works, unless the flag is reset to zero below, for example by file read error

    %read the processes file
    fileIn = fopen(fPName);
    if (fileIn < 0)
        fprintf('\n WARNING: file %s not found, code about to terminate\n', fPName);
        inputSuccessFlag = 0;
    else
        fprintf('\n Reading parameters from filename %s\n', fPName);
    end

    glob.CARoutine = fscanf(fileIn,'%s', 1);
    dummyLabel = fgetl(fileIn); % Read to the end of the line to skip any label text
    glob.transportationRoutine = fscanf(fileIn,'%s', 1);
    dummyLabel = fgetl(fileIn); % Read to the end of the line to skip any label text
    glob.waveRoutine = fscanf(fileIn,'%s', 1);
    dummyLabel = fgetl(fileIn); % Read to the end of the line to skip any label text
    glob.siliciclasticsRoutine = fscanf(fileIn,'%s', 1);
    dummyLabel = fgetl(fileIn); % Read to the end of the line to skip any label text
    glob.concentrationRoutine = fscanf(fileIn,'%s', 1);
    dummyLabel = fgetl(fileIn); % Read to the end of the line to skip any label text
    glob.soilRoutine = fscanf(fileIn,'%s', 1);
    dummyLabel = fgetl(fileIn); % Read to the end of the line to skip any label text
    glob.refloodingRoutine = fscanf(fileIn,'%s', 1);
    dummyLabel = fgetl(fileIn); % Read to the end of the line to skip any label text
    glob.seaLevelRoutine = fscanf(fileIn,'%s', 1);
    dummyLabel = fgetl(fileIn); % Read to the end of the line to skip any label text
    glob.wrapRoutine = fscanf(fileIn,'%s', 1);
    dummyLabel = fgetl(fileIn); % Read to the end of the line to skip any label text

    fprintf('CA routine is %s based \n', glob.CARoutine);
    fprintf('Transport routine is %s \n', glob.transportationRoutine);
    fprintf('Wave routine is %s \n', glob.waveRoutine);
    fprintf('Siliciclastics are %s \n', glob.siliciclasticsRoutine);
    fprintf('Carbonate concentration in water is %s \n', glob.concentrationRoutine);
    fprintf('Soild deposition is %s \n', glob.soilRoutine);
    fprintf('Reflooded cells are %s \n', glob.refloodingRoutine);
    fprintf('Sea-level curve from %s \n', glob.seaLevelRoutine);
    fprintf('Model edges are treated as %s \n \n', glob.wrapRoutine);

    fileIn = fopen(fName);
    if (fileIn < 0)
        fprintf('WARNING: file %s not found, code about to terminate\n', fName);
    else
        fprintf(' Reading parameters from filename %s\n', fName);
    end

    glob.modelName = fscanf(fileIn,'%s', 1);
    dummyLabel = fgetl(fileIn); % Read to the end of the line to skip any label text

    % Read parameters from the main parameter values file
    glob.xSize = fscanf(fileIn,'%d', 1);
    dummyLabel = fgetl(fileIn);
    glob.ySize = fscanf(fileIn,'%d', 1);
    dummyLabel = fgetl(fileIn);
    glob.dx = fscanf(fileIn,'%d', 1);
    dummyLabel = fgetl(fileIn);
    glob.totalIterations = fscanf(fileIn,'%d', 1);
    dummyLabel = fgetl(fileIn);
    glob.deltaT = fscanf(fileIn,'%f', 1);
    dummyLabel = fgetl(fileIn);

    glob.SLPeriod1 = fscanf(fileIn,'%f', 1);
    dummyLabel = fgetl(fileIn);
    glob.SLAmp1 = fscanf(fileIn,'%f', 1);
    dummyLabel = fgetl(fileIn);
    glob.SLPeriod2 = fscanf(fileIn,'%f', 1);
    dummyLabel = fgetl(fileIn);
    glob.SLAmp2 = fscanf(fileIn,'%f', 1);
    dummyLabel = fgetl(fileIn);

    glob.CADtMin = fscanf(fileIn,'%d', 1);
    dummyLabel = fgetl(fileIn);
    glob.CADtMax = fscanf(fileIn,'%d', 1);
    dummyLabel = fgetl(fileIn);

    glob.BathiLimit =  fscanf(fileIn,'%f', 1);
    dummyLabel = fgetl(fileIn);

    glob.maxProdFacies = fscanf(fileIn,'%d', 1);
    dummyLabel = fgetl(fileIn);

    for j = 1:glob.maxProdFacies
        glob.prodRate(j) = fscanf(fileIn,'%f', 1);
        dummyLabel = fgetl(fileIn);

        glob.surfaceLight(j) = fscanf(fileIn,'%f', 1);
        dummyLabel = fgetl(fileIn);
        if glob.surfaceLight(j) > 500
            glob.extinctionCoeff(j) = fscanf(fileIn,'%f', 1);
            dummyLabel = fgetl(fileIn);
            glob.saturatingLight(j) = fscanf(fileIn,'%f', 1);
            dummyLabel = fgetl(fileIn); 
        else
            glob.profCentre (j)= glob.surfaceLight(j);
            glob.profWidth (j)= fscanf(fileIn,'%f', 1);
            dummyLabel = fgetl(fileIn);
            glob.profSlope (j)= fscanf(fileIn,'%f', 1);
            dummyLabel = fgetl(fileIn);
        end
        
        fprintf('Facies %d produced at %3.2f m/My\n', j, glob.prodRate(j));
        
        glob.transportProductFacies(j) = fscanf(fileIn,'%d', 1);
        dummyLabel = fgetl(fileIn); 
        glob.transportFraction(j) = fscanf(fileIn,'%f', 1);
        dummyLabel = fgetl(fileIn); 
        glob.transportGradient(j) = fscanf(fileIn,'%f', 1);
        dummyLabel = fgetl(fileIn); 
        glob.transContinueProb(j) = fscanf(fileIn,'%f', 1);
        dummyLabel = fgetl(fileIn);  
        fprintf('Breakdown of facies %d creates facies %d at rate %3.2f of accumulated thickness \n', j, glob.transportProductFacies(j), glob.transportFraction(j));
        
        glob.prodWaveThresholdLow(j) = fscanf(fileIn,'%f', 1);
        dummyLabel = fgetl(fileIn); 
        glob.prodWaveThresholdHigh(j) = fscanf(fileIn,'%f', 1);
        dummyLabel = fgetl(fileIn); 
        fprintf('Facies %d produced from wave energy %4.3f to %4.3f\n', j, glob.prodWaveThresholdLow(j), glob.prodWaveThresholdHigh(j));
        
        glob.prodRate(j) = glob.prodRate(j) * glob.deltaT; % Adjust production rates for timestep

        % Calculate the water depth cutoff below which production rate is effectively zero
        % Factory types will only occur above this water depth cutoff
        wd = 0.0;
        if glob.surfaceLight(j)>500
            while tanh((glob.surfaceLight(j) * exp(-glob.extinctionCoeff(j) * wd))/ glob.saturatingLight(j)) > 0.000001 && wd < 10000
                glob.prodRateWDCutOff(j) = wd;
                wd = wd + 0.1;
            end
        else
            while  (1/ (1+((wd-glob.profCentre(j))./glob.profWidth(j)).^(2.*glob.profSlope(j))) ) > 0.000001 && wd < 10000
                glob.prodRateWDCutOff(j) = wd;
                wd = wd + 0.1;
            end 
        end
        fprintf('Facies %d has production cutoff at %3.2f m water depth\n', j, glob.prodRateWDCutOff(j));
    end

    glob.subsidenceFName = fscanf(fileIn,'%s', 1);
    dummyLabel = fgetl(fileIn); 
    fprintf('Subsdience map filename %s \n', glob.subsidenceFName);

    glob.CARulesFName = fscanf(fileIn,'%s', 1);
    dummyLabel = fgetl(fileIn); 
    fprintf('CA rules filename %s \n', glob.CARulesFName);

    glob.initFaciesFName = fscanf(fileIn,'%s', 1);
    dummyLabel = fgetl(fileIn); 
    fprintf('Initial condition facies map filename %s \n', glob.initFaciesFName);

    glob.initBathymetryFName = fscanf(fileIn,'%s', 1);
    dummyLabel = fgetl(fileIn); 
    fprintf('Initial bathymetry map filename %s \n', glob.initBathymetryFName);

    glob.concFName = fscanf(fileIn,'%s', 1);
    dummyLabel = fgetl(fileIn); 
    fprintf('Carbonate concentration filename %s \n', glob.concFName);

    glob.siliFName = fscanf(fileIn,'%s', 1);
    dummyLabel = fgetl(fileIn); 
    fprintf('Carbonate siliciclastic supply filename %s \n', glob.siliFName);

    glob.SLCurveFName = fscanf(fileIn,'%s', 1);
    dummyLabel = fgetl(fileIn); 
    fprintf('Sea-level curve filename %s \n', glob.SLCurveFName);
    
    glob.carbProdCurveFName = fscanf(fileIn,'%s', 1);
    dummyLabel = fgetl(fileIn); 
    fprintf('Maximum carbonate production rate time curve filename %s \n', glob.carbProdCurveFName);
    
    glob.faciesColoursFilename  = fscanf(fileIn,'%s', 1);
    dummyLabel = fgetl(fileIn); 
    fprintf('Model facies colour map filename %s \n', glob.faciesColoursFilename);

    % Read the cellular automata rules from file name in glob.CARulesFName
    if exist(glob.CARulesFName, 'file') == 2
        import = importdata(glob.CARulesFName,' ',1);
        glob.CARules = import.data;
    else
        message = sprintf('Could not find %s\nCheck path and filename exist.', glob.CARulesFName);
        h1 = msgbox(message,'Loading CA rules not successful');
        inputSuccessFlag = 0;
    end

    % Read the number and ages of time lines to be plotted on cross sections. Age = iteration number
    glob.timeLineCount = fscanf(fileIn,'%d', 1);
    dummyLabel = fgetl(fileIn);
    glob.timeLineAge = zeros(1,glob.timeLineCount+1);

    glob.timeLineAge = fscanf(fileIn,'%d', glob.timeLineCount); % reads glob.timeLineCount values from the file
    dummyLabel = fgetl(fileIn);
    fprintf('Plotting %d timelines from iteration %d to %d\n', glob.timeLineCount, glob.timeLineAge(1), glob.timeLineAge(glob.timeLineCount));

    % Finally, read the number and ages of maps to be plotted in the relevant figure. Age = iteration number
    glob.mapCount = fscanf(fileIn,'%d', 1);
    dummyLabel = fgetl(fileIn);
    glob.mapAge = zeros(1,glob.mapCount+1);
end