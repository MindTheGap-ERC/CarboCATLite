function [glob] = calculateSubsidence(glob, iteration)
% Calculate subsidence over the whole model grid for all strata up to current iteration
% Assumes that subs.subRateMap is the correct maxX and maxY size and contains the subsidence rate appropriate for the model timestep

    % Implicit loop to calculate the subsidence rate to all previous layers of strata, up to current iteration
    k = 1:iteration;
    glob.strata(:,:,k) = glob.strata(:,:,k) - glob.subRateMap;
end




