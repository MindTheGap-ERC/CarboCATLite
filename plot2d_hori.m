    
%% plot the horizontal transect of sensitivity test (neighbor)
    %facies_1 = cell2mat(glob.facies(:,:,100));
    faciesM=zeros(glob.ySize,glob.xSize);
    testX = 1:glob.xSize;
    testY = 1:glob.ySize;
    z = [10; 100; 200; 500; 700; 1000; 1200; 1500;2000];
    for y=1:glob.ySize
        for x=1:glob.xSize
            for z_num = 1:length(z);
            faciesM(y,x,z(z_num))=glob.facies{y,x,z(z_num)}(1);

        end
        end
    end
    for num = 1:length(z)
        figure (num+1);
    p(num)=pcolor(testX, testY, double(faciesM(:,:,z(num))));
    colormap(glob.faciesColours);
    end
    
    set(p,'LineStyle','none');
    %view([0 90]);
    xlabel('X Distance (grid points)');
    ylabel('Y Distance (grid points)');
    axis square
    %view([135, 45]);
    colormap(glob.faciesColours);
   