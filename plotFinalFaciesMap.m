%%% find the bathymetry
wd = round(glob.wd(:,:,2000));

testX = 1:glob.xSize;
testY = 1:glob.ySize;

    for y=1:glob.ySize
        for x=1:glob.xSize
            faciesM(y,x)=glob.facies{y,x,wd(y,x)+1}(1);
        end
    end
    figure;
    p = pcolor(testX, testY, double(faciesM));
    colormap(glob.faciesColours);
    colorbar;
    figure;
    colorfacies = double(faciesM);
    surf(testX,testY,-wd,colorfacies);
    colormap(glob.faciesColours);
    colorbar;
    set(p,'LineStyle','none');
    view([0 90]);
    xlabel('X Distance (grid points)');
    ylabel('Y Distance (grid points)');
    axis square
    view([135, 45]);
    title('final surface facies distribution');

 %%% output csv files
 FinalBath = writematrix(-wd,'FinalBathmap.csv');
 FinalFacies = writematrix(double(faciesM)),'FinalFaciesMap');
 