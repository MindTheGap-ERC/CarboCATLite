function plotInitialGraphics(glob, graph, iteration)

    %cla % Clear all existing plots in the window
    figure(graph.main);
    
    % Initial Subsidence map, position [left, bottom, width, height] all in range 0.0 to 1.0.
    subsPlot = subplot('Position',[0.04 0.2 0.20 0.5]);
    cla
    reset(subsPlot);
    p=surf(glob.subRateMap);
    set(p,'LineStyle','none');
    xlabel('X Distance (grid points)');
    ylabel('Y Distance (grid points)');
    view([135, 45]);
    colormap gray;
    title('Subsidence map');

    %% Initial bathymetry map
    % position [left, bottom, width, height] all in range 0.0 to 1.0.
    wdMapPlot = subplot('Position',[0.52 0.2 0.20 0.5]);
    cla
    reset(wdMapPlot);
    p=surface(double(-glob.wd(:,:,1)));
    set(p,'LineStyle','none');
    view([-85 25]);
    grid on;
    xlabel('X Distance (grid points)');
    ylabel('Y Distance (grid points)');
    view([135, 45]);
    colormap gray;
    title('Initial bathymetry');
   
    %% Initial Facies map
    % position [left, bottom, width, height] all in range 0.0 to 1.0.
    faciesMapPlot = subplot('Position',[0.28 0.2 0.20 0.5]);
    cla
    reset(faciesMapPlot);
    faciesM=zeros(glob.ySize,glob.xSize);
    testX = 1:glob.xSize;
    testY = 1:glob.ySize;
    for y=1:glob.ySize
        for x=1:glob.xSize
            faciesM(y,x)=glob.facies{y,x,iteration}(1);
        end
    end
    p=pcolor(testX, testY, double(faciesM));
    set(p,'LineStyle','none');
    view([0 90]);
    xlabel('X Distance (grid points)');
    ylabel('Y Distance (grid points)');
    axis square
    view([135, 45]);
    colormap(glob.faciesColours);
    title('Initial facies distribution');

    %% Initial sea-level and carbonate production curves
    wlPlot = subplot('Position',[0.04 0.8 0.6 0.15]);
    cla
    reset(wlPlot);
    yyaxis left;
    p = plot((1:glob.totalIterations) .* glob.deltaT, glob.SL(1:glob.totalIterations), 'linewidth', 3, 'color', [0, 0, 1]);
    hold on
    yyaxis right
    p = plot((1:glob.totalIterations) .* glob.deltaT, glob.carbProdCurve(1:glob.totalIterations), 'linewidth', 3, 'color', [1, 0.1, 0]);
    xlabel('Time (My)');
    ylabel('Carb prod modifier');
    yyaxis left;
    ylabel('Eustatic Sea Level (m)');
    axis tight
    
    %% Production-depth curve plot
    % initialise production depth curve plot
    depthProdPlot = subplot('Position',[0.76 0.2 0.20 0.55]);
    cla
    reset(depthProdPlot);

    set(depthProdPlot, 'YDir', 'reverse');
    ylabel('Water depth (m)');
    xlabel('Production rates (m/My)');
    minMax = max(glob.prodRate/glob.deltaT);
    axis([-(minMax*0.05) minMax*1.05 0 100]);
    grid on;
    depth=0:100;

    for j=1:glob.maxProdFacies
        if glob.surfaceLight(j)>500
            %use this if you want to use Schlager's production profile
            prodDepth = (glob.prodRate(j)/glob.deltaT) * tanh((glob.surfaceLight(j) * exp(-glob.extinctionCoeff(j) * depth))/ glob.saturatingLight(j));
        else
            %use this if you want to use new production profile
            prodDepth = (glob.prodRate(j)./glob.deltaT).* (1./ (1+((depth-glob.profCentre(j))./glob.profWidth(j)).^(2.*glob.profSlope(j))) );
        end
        lineCol = [glob.faciesColours(j,1) glob.faciesColours(j,2) glob.faciesColours(j,3)];
        line(prodDepth, depth, 'color', lineCol, 'LineWidth',4);
    end

    %% CA Rules
    CARPlot=subplot('Position',[0.76 0.8 0.20 0.15]);
    cla
    reset(CARPlot);
    radius=glob.CARules(1:glob.maxProdFacies,1);
    bigRadius=max(radius(:));

    % glob.faciesColours(1,2:4)=[27 170 185]./255;
    % glob.faciesColours(2,2:4)=[197 202 32]./255;
    % glob.faciesColours(3,2:4)=[140 84 161]./255;

    baseF=+0.5;
    for f=1:glob.maxProdFacies
        minS=glob.CARules(f,2);
        maxS=glob.CARules(f,3);
        minT=glob.CARules(f,4);
        maxT=glob.CARules(f,5);
        Col = [glob.faciesColours(f,1) glob.faciesColours(f,2) glob.faciesColours(f,3)];
        patch([minS maxS maxS minS],[baseF+0+0.1 baseF+0+0.1 baseF+0.5 baseF+0.5],Col,'linewidth',3);
        patch([minT maxT maxT minT],[baseF+0.5 baseF+0.5 baseF+1-0.1 baseF+1-0.1],Col,'edgeColor','k','linewidth',3);

        posX=(minS+(maxS-minS)/2);
        posY=baseF+.3;
        text(posX,posY,'S');
        posX=(minT+(maxT-minT)/2);
        posY=baseF+0.7;
        text(posX,posY,'T');
        baseF=baseF+1;
    end
    axis([0 (((bigRadius*2+1))^2)-1 0.5 glob.maxProdFacies+.5]);
    xTicks=[0:2:(((bigRadius*2+1))^2)-1];
    yTicks=[1:1:glob.maxProdFacies];

    set(gca,'XTick',xTicks)
    set(gca,'YTick',yTicks)

    xlabel('CA rules');
    ylabel('Facies');
end
