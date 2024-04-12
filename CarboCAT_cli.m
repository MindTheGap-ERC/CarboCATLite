function CarboCAT_cli(ParamsPath, ProcessPath, OutputName, SeaLevelPath, makePlot)
% Input variables
% ParamsPath: string, relative path to the file with parameters, e.g.
%   "params/DbPlatform/paramsInputValues.txt"
% ProcessPath: string, relative path to the file with the process settings,
% e.g. "params/DbPlatform/paramsProcesses.txt"
% OutputName: string, name to which model outputs are saved, e.g.
% "model_run_42"
% SeaLevelPath: string, relative path to the file with the sea level curve,
% e.g. "params/DbPlatform/seaLevelConst3000iterations.txt"
% makePlot: logical, true or false. Should the chronostratigraphic plot be
% generated?
%
% Example usage:
% CarboCAT_cli("params/DbPlatform/paramsInputValues.txt", "params/DbPlatform/paramsProcesses.txt", "model_run_42", "params/DbPlatform/seaLevelConst3000iterations.txt", true)

    graph.main = 0;
    graph.f1 = 0;
    graph.f2 = 0;
    graph.f3 = 0;
    graph.f4 = 0;
    graph.f5 = 0;
    graph.f6 = 0;
    
    
    
    % Create initial members of global structures used throughout the code,
    % only those that are needed for the initial GUI display
    glob.modelName = '';
    glob.xSize = 10;
    glob.ySize = 100;
    stats.totalFaciesVolume = 0;
    
    set(0,'RecursionLimit',1000);
    
    
    glob.paramsFName = ParamsPath;
    glob.processFName = ProcessPath;
    [glob, inputSuccessful] = inputOneModelParams(glob, glob.paramsFName,glob.processFName, SeaLevelPath);
    if inputSuccessful
        glob = initialiseModelGridArrays(glob);
        glob = initializeOneModelVariables(glob);
    else
        h1 = msgbox('Model initialise was not successful');
    end
    
    [glob,stats,graph] = runCAModelGUI(glob, stats, graph, OutputName);
    glob.initFlag = 0;

    if makePlot
        iteration=glob.totalIterations;
        plotFinalGraphics(glob, stats, iteration, OutputName);

    end
    fprintf(append('Done with model run ', OutputName,'\n'));
end
