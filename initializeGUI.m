function glob = initializeGUI(glob, stats, graph)

    iteration = 0;
    dummyMap = zeros(glob.ySize, glob.xSize);

    %  Create and then hide the GUI window as it is being constructed.

    % ScreenSize is a four-element vector: [left, bottom, width, height]:
    scrsz = get(0,'ScreenSize'); % vector
    % position requires left bottom width height values. screensize vector
    % is in this format 1=left 2=bottom 3=width 4=height
    graph.main = figure('Visible','off','Position',[scrsz(1) scrsz(4) scrsz(3)/1.5 scrsz(4)/1.5]);

    % Make main the current figure for plotting, gui elements etc
    figure(graph.main);

    % Subsidence map
    % position [left, bottom, width, height] all in range 0.0 to 1.0.
    temp = subplot('Position',[0.04 0.15 0.20 0.5]);
    dummymap = zeros(50,50);
    surface(double(dummyMap));
    axis square;
    axis tight;
    view(180,45);

    % Initial condition facies map 
    % position [left, bottom, width, height] all in range 0.0 to 1.0.
    temp = subplot('Position',[0.28 0.15 0.20 0.5]);
    dummymap = zeros(50,50);
    pcolor(double(dummyMap));
    axis square;
    axis tight;
    view(180,45);

    % Initial condition bathymetry map
    % position [left, bottom, width, height] all in range 0.0 to 1.0.
    temp = subplot('Position',[0.52 0.15 0.20 0.5]);
    dummymap = zeros(50,50);
    %pcolor(double(dummyMap));
    surface(double(dummyMap));
    axis square;
    axis tight;
    view(180,45);

    % Production profiles
    subplot('Position',[0.76 0.15 0.20 0.55]);
    axis ij;
    plot(1:10, 1:10);

    %WaterLevel Curve
    temp=subplot('Position',[0.04 0.8 0.6 0.15]);
    plot([1 100],[0 0]);
    axis xy;

    % CA Rules plot template
    temp = subplot('Position',[0.76 0.8 0.20 0.15]);
    Col=[0.5 1 1];
    patch([4 10 10 4],[.5+0+0.1 .5+0+0.1 .5+1-0.1 .5+1-0.1],Col,'linewidth',2);
    patch([6 8 8 6],[.5+0.25+0.1 .5+0.25+0.1 .5+0.75-0.1 .5+0.75-0.1],Col,'edgeColor','w','linewidth',3);
    axis([0 24 0.5 1.5]);
    axis xy;
    xTicks=[0:2:24];
    yTicks=[1:1:2];
    set(gca,'XTick',[])
    set(gca,'YTick',[])

    %  Construct the components.
    hInit = uicontrol('Style','pushbutton','String','Initialize',...
        'Position',[50,20,100,25],...
        'Callback',{@initButton_Callback});
    hRun = uicontrol('Style','pushbutton','String','Run CA model',...
        'Position',[170,20,100,25],...
        'Callback',{@runButton_Callback});

    hDraw = uicontrol('Style','pushbutton','String','Plot run',...
        'Position',[300,20,80,25],...
        'Callback',{@plotButton_Callback});

    hReset = uicontrol('Style','pushbutton','String','Close output windows',...
        'Position',[400,20,140,25],...
        'Callback',{@resetButton_Callback});

    %hSave = uicontrol('Style','pushbutton','String','Save cmap',...
    %       'Position',[400,20,100,25],...
    %     'Callback',{@saveButton_Callback});
    %hLoad = uicontrol('Style','pushbutton','String','Load Results',...
    %       'Position',[290,20,70,25],...
    %       'Callback',{@loadButton_Callback});

    hParamsProcessesFnameLabel = uicontrol('style','text','string','Processes filename:','Position',[700,45,120,15]);
    hProcessesFname = uicontrol('Style','edit','String','params/DbPlatform/paramsProcesses.txt','Position',[700 20 190 25]);

    hParamsFnameLabel = uicontrol('style','text','string','Parameters filename:','Position',[900,45,120,15]);
    hParamsFname = uicontrol('Style','edit','String','params/DbPlatform/paramsInputValues.txt','Position',[900 20 190 25]);

    % Assign the GUI a name to appear in the window title.
    set(graph.main,'Name','CarboCAT')
    % Move the GUI to the center of the screen.
    movegui(graph.main,'center')
    % Make the GUI visible.
    set(graph.main,'Visible','on');
    


        function initButton_Callback(source, eventdata)

            glob.paramsFName = get(hParamsFname,'String');
            glob.processFName=get(hProcessesFname,'String');
            [glob, inputSuccessful] = inputOneModelParams(glob, glob.paramsFName,glob.processFName);
            if inputSuccessful
                glob = initialiseModelGridArrays(glob);
                glob = initializeOneModelVariables(glob);
                plotInitialGraphics(glob, graph, 1);
            else
                h1 = msgbox('Model initialise was not successful');
            end
        end

        function runButton_Callback(source, eventdata)

            [glob,stats,graph] = runCAModelGUI(glob, stats, graph);
            glob.initFlag = 0;

        end

        function plotButton_Callback(source, eventdata)
            iteration=glob.totalIterations;
            plotFinalGraphics(glob, stats, iteration);
            glob.initFlag = 0;

        end

        function resetButton_Callback(source, eventdata)
            %
            close(graph.f1);
            close(graph.f2);
            close(graph.f3);
            close(graph.f4);
            close(graph.f5);
            close(graph.f6);
            close(graph.f7);
            close(graph.f8);
        end

        function getDataButton_Callback(source,eventdata)
            glob = getData(glob,stats);

        end

    %
    %    function saveColorMapsButton_Callback(source, eventdata)
    %    % Save the two different CA facies colour maps in case they have been changed
    %       CA3FaciesCMap = get(graph.main,'Colormap');
    %       save('colorMaps\colorMapCA3Facies','CA3FaciesCMap');
    %       CA7FaciesCMap = get(graph.f1,'Colormap');
    %       save('colorMaps\colorMapCA7Facies','CA7FaciesCMap');
    %    end
    % 
    %     function loadButton_Callback(source,eventdata)
    %         
    %     end
    % 
    %     function saveButton_Callback(source,eventdata)
    %         %oneCMap = get(graph.main,'Colormap');
    %         %save('params/colorMapCA3Facies','oneCMap')
    %     end



end