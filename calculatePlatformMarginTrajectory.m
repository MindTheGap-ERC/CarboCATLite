function platMarginTraj = calculatePlatformMarginTrajectory(glob, iteration, xPos)

    platMarginTraj = zeros(1, iteration);
    rateOfChangeOfGradZ = zeros(glob.ySize, iteration);
    marginFaciesTransition = zeros(glob.ySize, iteration);
    pMap = zeros(glob.ySize, iteration);
    waveSensitiveFacies = 1;

    for t=2:iteration
        for y = 2:glob.ySize-1

            % Calculate the rate of change of topographic gradient along the depositional surface
            zDiffLeft = glob.strata(y-1,xPos,t) - glob.strata(y,xPos,t);
            zDiffRight = glob.strata(y,xPos,t) - glob.strata(y+1,xPos,t);
            rateOfChangeOfGradZ(y,t) = (zDiffLeft - zDiffRight) / glob.dx; 
            
            faciesCount = zeros(1,glob.maxFacies);
            m = 1:glob.numberOfLayers(y,xPos,t);
            oneFacies = glob.facies{y,xPos,t}(m);
            faciesCount(oneFacies) = faciesCount(oneFacies) + 1;
            [~,mostFreqFacies] = max(faciesCount);
            if mostFreqFacies == waveSensitiveFacies
                marginFaciesTransition(y,t) = 1;
            end
        end
    end
    
    rateOfChangeOfGradZ = rateOfChangeOfGradZ / max(max(rateOfChangeOfGradZ));
    pMap = abs(rateOfChangeOfGradZ) .* marginFaciesTransition;
    [~,platMarginTraj] = max(pMap);
%     platMargintraj = platMarginTraj ; % Scale to correct y coordinate scale
    
    figure;
    yGridVector = (1:glob.ySize) .* glob.dx;
    zGridVector = (1:iteration) .* glob.deltaT;
    handle = pcolor(zGridVector, yGridVector, pMap);
    set(handle, 'EdgeColor', 'none');
    xlabel('Elapsed model time (iteration) (My)');
    ylabel('Y distance (m)');
    hold on
    scatter((1:iteration).*glob.deltaT, platMarginTraj.* glob.dx, 'MarkerEdgeColor',[0 .5 .5], 'MarkerFaceColor',[1 .3 0]);
end
