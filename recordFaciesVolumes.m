function stats = recordFaciesVolumes(glob, stats, iteration)

    faciesThicknesses = zeros(glob.ySize, glob.xSize, glob.maxFacies);

    % Loop across the model grid
    for x = 1:glob.xSize
        for y = 1:glob.ySize
            for f = 1:glob.maxFacies % Loop through each facies
                
                % for the current iteration, each xy point for each facies f, sum the thicknesses of layers with facies code f
                faciesThicknesses(y,x,f) = sum(glob.thickness{y,x,iteration}(glob.facies{y,x,iteration}==f));
            end
        end
    end
    
    % For each facies, find the sum thickness across the whole bvolume and
    % multiply by grid cell size to get volume in m3
    gridCellArea = glob.dx * glob.dx;
    f = 1:glob.maxFacies;
    stats.totalFaciesVolume(iteration, f) = sum(sum(faciesThicknesses(:,:,f))) * gridCellArea;
    
    fprintf('Facies vols ');
    for f=1:glob.maxProdFacies * 2; % all the produced facies and the transported facies
        fprintf('%d:%4.3E ',f, stats.totalFaciesVolume(iteration, f));
    end
end