function CarboCAT_cli(ParamsPath, ProcessPath, OutputName)

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
    [glob, inputSuccessful] = inputOneModelParams(glob, glob.paramsFName,glob.processFName);
    if inputSuccessful
        glob = initialiseModelGridArrays(glob);
        glob = initializeOneModelVariables(glob);
    else
        h1 = msgbox('Model initialise was not successful');
    end
    
    [glob,stats,graph] = runCAModelGUI(glob, stats, graph, OutputName);
    glob.initFlag = 0;

end
