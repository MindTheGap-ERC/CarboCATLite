function [faciesProdAdjust]=calculateFaciesProductionAdjustementFactor(glob,y,x,oneFacies,neighbours)

% Production adjustment is calculated based on
% the number of neighbours for this cell, which has already been
% calculated at the start of this function.
% Note calculation of prod adjust needs to be done regardless of
% iteration count at y x because surrounding cells may have
% iterated and their count changed

if oneFacies > 0 && oneFacies <= glob.maxProdFacies

    oneNeighbours = neighbours(y,x,oneFacies);
    
    
    if oneNeighbours < glob.prodScaleMin(oneFacies) % So fewer than minimum neighbours
        faciesProdAdjust = 0.0;
        
    elseif oneNeighbours <= glob.prodScaleOptimum(oneFacies) % More than min, fewer than optimum
        
        faciesProdAdjust = (oneNeighbours-(glob.prodScaleMin(oneFacies)-1))/(glob.prodScaleOptimum(oneFacies)-(glob.prodScaleMin(oneFacies)-1));
        
    elseif oneNeighbours <= glob.prodScaleMax(oneFacies) % More than optimum, fewer than max
        
        faciesProdAdjust = ((glob.prodScaleMax(oneFacies)+1)-oneNeighbours)/((glob.prodScaleMax(oneFacies)+1)-glob.prodScaleOptimum(oneFacies));
        
    else % More than maximum number of neighbours
        faciesProdAdjust = 0.0;
    end
else
    faciesProdAdjust=0.0;
end
end