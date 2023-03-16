function glob = initialiseModelGridArrays(glob)
% Create the key model grid matrices here in the global data structure glob, so that they can be referenced
% throughout the rest of initialisation and model run routines
    
    glob.maxIts = 1005; % To allow up to 1My model duration for a reasonable 1ky time step
    glob.maxFacies = 9; % Assumes up to 3 producing facies, 3 transported facies, 1 subaerial exposure, 1 pelagic and 1 spare

    glob.strata = zeros(glob.ySize, glob.xSize, glob.maxIts);
    glob.wd = zeros(glob.ySize, glob.xSize, glob.maxIts);
    
    glob.facies = num2cell(uint8(zeros(glob.ySize,glob.xSize, glob.maxIts)));    
    glob.thickness = num2cell(double(zeros(glob.ySize,glob.xSize, glob.maxIts)));
    glob.numberOfLayers = zeros(glob.ySize, glob.xSize, glob.maxIts);

    glob.transpDist = num2cell(double(zeros(glob.ySize,glob.xSize, glob.maxIts)));
    glob.transVolMap = zeros(glob.ySize, glob.xSize);
end

