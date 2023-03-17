function [glob] = initializeOneModelVariables(glob)
% Initialise the various vectors and matrices used in the model using the
% values already read from the parameter input files

    rng(1); % Seed the random number generator to ensure the same model is produced each run if other parameters are not changed

    % Load the initial facies map file using the file name specified in the paramter file
    oneFaciesMap = load(glob.initFaciesFName, '-ASCII');

    mapSizeCheck = size(oneFaciesMap);
    if mapSizeCheck(1) ~= glob.ySize || mapSizeCheck(2) ~= glob.xSize
        fprintf('WARNING: initial facies map is %d %d in size, different to the %d %d model grid\n', mapSizeCheck(1:2), glob.ySize, glob.xSize);
    end

    checkMaxFacies = max(max(oneFaciesMap));
    fprintf('%d facies on the initial facies map\n', checkMaxFacies);
    if checkMaxFacies > glob.maxProdFacies
        fprintf('WARNING: %d producing facies in the initial facies map from %s versus %d maximum facies in from the parameter file\n',checkMaxFacies, glob.initFaciesFName, glob.maxProdFacies);
    end
    
    for f = 1:9
        faciesTotals(f) = sum(oneFaciesMap(:) == f);
        fprintf('Facies %d total initial cells is %d\n', f, faciesTotals(f));
    end

    for y=1:glob.ySize
        for x= 1:glob.xSize
            glob.facies{y,x,1}(1) = oneFaciesMap(y,x);
            if glob.facies{y,x,1}(1)>0
                glob.numberOfLayers(y,x,1)=1;
            else
                glob.numberOfLayers(y,x,1)=0;    
            end
        end
    end

    % Load the initial bathymetry map using the file name specified in the parameter file
    oneBathymetryMap = (load(glob.initBathymetryFName, '-ASCII'));
    mapSizeCheck = size(oneBathymetryMap);
    if mapSizeCheck(1) ~= glob.ySize || mapSizeCheck(2) ~= glob.xSize
        fprintf('WARNING: initial bathymetry map is %d %d in size, different to the %d %d model grid\n', mapSizeCheck(1:2), glob.ySize, glob.xSize);
    end

    % Set the initial water depth and the elevation of the initial stratal surface to the initial water depth
    % Note that zero is the model datum so initial surface elevation is zero - initial water depth
    glob.wd(:,:,1) = oneBathymetryMap;
    glob.strata(:,:,1) = -glob.wd(:,:,1); 
    glob.strataOriginalPosition = glob.strata;

    % Load a subsidence map from an external file.
    oneSubsidenceMap = (load(glob.subsidenceFName, '-ASCII')); % The path to the file with the subsidence map
    glob.subRateMap = oneSubsidenceMap;
    glob.subRateMap = glob.subRateMap * glob.deltaT;% Adjust production rates for timestep

    if strcmp(glob.seaLevelRoutine,'file') ==0
        % initialize sea-level curve 
        j = 1:glob.maxIts; % implicit loop on iterations
        emt = double(j) * glob.deltaT; % create a vector of emt values
        glob.SL = ((sin(pi*((emt/glob.SLPeriod1)*2)))* glob.SLAmp1)+ (sin(pi*((emt/glob.SLPeriod2)*2)))* glob.SLAmp2;
    else
        % read the SL/water level curve and initialise the curve array in glob
        imported = importdata(glob.SLCurveFName);
        glob.SL = imported;
    end
    
    % read the carbonate production rate time curve and initialise the curve array in glob
    imported = importdata(glob.carbProdCurveFName);
    glob.carbProdCurve = imported;

    % Correct the transport gradient with the cell size information
    glob.transportGradient(:)=glob.transportGradient(:).*glob.dx./1000;

    % Set up the CA iteration counting arrays
    glob.CADtCount=zeros(glob.ySize, glob.xSize); % Set Dt counter to zero
    glob.CADtPerIteration = ones(glob.ySize, glob.xSize) * glob.CADtMax; % Set the timesteps required per iteration to the input parameter value

    % Set up the wave energy array map
    glob.waveEnergy = zeros(glob.ySize, glob.xSize);
    
    %Initialize the carbonate concentration array
    %Read the concentration data
    fileInConcentration = fopen(glob.concFName);
    glob.inputRateCarbonate=fscanf(fileInConcentration,'%f', 1);
    dummyLabel = fgetl(fileInConcentration);
    glob.yInitConcentration=fscanf(fileInConcentration,'%f', 1);
    dummyLabel = fgetl(fileInConcentration);
    glob.xInitConcentration=fscanf(fileInConcentration,'%f', 1);
    dummyLabel = fgetl(fileInConcentration);
    glob.diffYplus=fscanf(fileInConcentration,'%f', 1);
    dummyLabel = fgetl(fileInConcentration);
    glob.diffYminus=fscanf(fileInConcentration,'%f', 1);
    dummyLabel = fgetl(fileInConcentration);
    glob.diffXplus=fscanf(fileInConcentration,'%f', 1);
    dummyLabel = fgetl(fileInConcentration);
    glob.diffXminus=fscanf(fileInConcentration,'%f', 1);
    dummyLabel = fgetl(fileInConcentration);
    glob.initialVolumeValue=fscanf(fileInConcentration,'%f', 1);
    dummyLabel = fgetl(fileInConcentration);

    glob.carbonateVolMap=zeros(glob.ySize,glob.xSize);
    %set an homogeneus initial concentration value (sea water is typical 0.15kg/m3)
    glob.carbonateVolMap(:,:)=glob.initialVolumeValue;

    % this is for the diffusion silicilastic model
    glob.productionBySiliciclasticMap=ones(glob.ySize,glob.xSize,glob.maxProdFacies);
    %Initialize the siliciclastics array
    fileInConcentration = fopen(glob.siliFName);
    glob.inputSili=fscanf(fileInConcentration,'%f', 1);
    dummyLabel = fgetl(fileInConcentration);

    glob.yInitSili=fscanf(fileInConcentration,'%f', 1);
    dummyLabel = fgetl(fileInConcentration);
    glob.xInitSili=fscanf(fileInConcentration,'%f', 1);
    dummyLabel = fgetl(fileInConcentration);

    glob.sourceLength=fscanf(fileInConcentration,'%f', 1);
    dummyLabel = fgetl(fileInConcentration);

    glob.diffY = fscanf(fileInConcentration,'%f', 1);
    dummyLabel = fgetl(fileInConcentration);
    glob.diffX = fscanf(fileInConcentration,'%f', 1);
    dummyLabel = fgetl(fileInConcentration);

    % Finally, load a colour map for the CA facies and hiatuses
    glob.faciesColours = load(glob.faciesColoursFilename);

    % Set producing facies controls that depend on number of neighbour parameters
    oneFacies = 1:glob.maxProdFacies;
    glob.prodScaleMin(oneFacies) = glob.CARules(oneFacies,2);
    glob.prodScaleMax(oneFacies) =  glob.CARules(oneFacies,3);
    glob.prodScaleOptimum(oneFacies) = ((glob.prodScaleMax(oneFacies) - glob.prodScaleMin(oneFacies)) / 2)+glob.prodScaleMin(oneFacies);
    glob.prodWaveOptimum(oneFacies) = glob.prodWaveThresholdLow(oneFacies) + ((glob.prodWaveThresholdHigh(oneFacies) - glob.prodWaveThresholdLow(oneFacies)) / 2.0);
    
    if size(glob.faciesColours,1) < glob.maxFacies % So if too few rows in the colour map, give a warning...
        fprintf('Only %d colours in colour map colorMaps/faciesColourMap.txt but %d facies in model\n', size(1), glob.maxFacies);
        fprintf('This could get MESSY!\n\n\n\n');
    end
    
    stats.totalFaciesVolume = zeros(glob.maxIts, glob.maxFacies);

    disp("Initialization done")
end






