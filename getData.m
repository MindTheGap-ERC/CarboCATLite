function glob = getData(glob,stats)
%get data from the model, use this function for taking variables outside
%the GUI workspace, otherwise unavailable from the command window
%for example
%assignin('base','strata',glob.strata(:,:,1));
%puts on the workspace the variable strata with the values from
%glob.strata(:,:,1)
nameLogs={'w11-3' 'w11-1' 'w11-2' 'Durslton Head' 'Swanworth Quarry' 'Hells Bottom (incomplete)' 'Worborrow Tout' 'Mupe Bay' 'Poxwell (incomplete)' 'North Portland' 'South Portland' 'Portesham'};
xpoint=[10 12 13 25 37 46 55 64 81 88 90 103 0];
ypoint=[26 29 35 41 39 35 36 36 29 49 57 24 0];
numberOfLocations=size(xpoint,2)-1;
% 
% for it=1:glob.totalIterations
%     for locations=1:numberOfLocations-1
%         waterDepthATPoint(it,1,locations)=glob.wd(ypoint(locations),xpoint(locations),it);
%         
%         if glob.numberOfLayers(ypoint(locations),xpoint(locations),it)>0
%             for layer=1:glob.numberOfLayers(ypoint(locations),xpoint(locations),it)
%                 faciesATPoint(it,layer,locations)=glob.facies{ypoint(locations),xpoint(locations),it}(layer);
%                 thicknessATPoint(it,layer,locations)=glob.thickness{ypoint(locations),xpoint(locations),it}(layer);
%             end
%         else
%             faciesATPoint(it,1,locations)=0;
%             thicknessATPoint(it,1,locations)=0;
%         end
%     end
% end
% 
% assignin('base','faciesATPoint',faciesATPoint);
% assignin('base','thicknessATPoint',thicknessATPoint);
% assignin('base','waterDepthATPoint',waterDepthATPoint);



[ average] = calculateSurfaceVariation( glob );
%average=average/0.007;
assignin('base','averageSurfVarA',average);

for t=2:glob.totalIterations
%     totalThickness=glob.strata(:,:,t)-glob.strata(:,:,t-1);
%     wd=glob.wd(:,:,t);
%     wd(wd<0)=0;
%     wdprev=glob.wd(:,:,t);
%     wdprev(wdprev<0)=0;
%     dwd=wd;
%     accomm(:,:,t) = totalThickness + wd;
%     %dWaterD=dWaterD+(glob.wd(:,:,t)-glob.wd(:,:,t-1));
%     %accommodation = dWaterD+totalThickness(:,:,t);
    accomm(:,:,t)=(glob.wd(:,:,t)-glob.wd(:,:,t-1))+(glob.strata(:,:,t)-glob.strata(:,:,t-1));
end
wd=glob.wd(:,:,1);
wd(wd<0)=0;
totalAccommodation=sum(accomm(:)) + sum(wd(:));
%Calculate thickness
initStrata=glob.strata(:,:,1);
finalStrata=glob.strata(:,:,glob.totalIterations);
thickness=sum(sum(finalStrata-initStrata));

thicknessIndex=thickness/totalAccommodation;
assignin('base','thicknessIndexA',thicknessIndex);


%calculate transitions
maxTransitions=double(glob.ySize) * double(glob.xSize) * double(glob.totalIterations);
transitions=0;
for t = 2: glob.totalIterations
    for y=1:glob.ySize
        for x=1:glob.xSize
            prodFaciesPrev=glob.facies{y,x,t-1}(1);
            if prodFaciesPrev>glob.maxProdFacies
                prodFaciesPrev=0;
            end
            prodFacies=glob.facies{y,x,t}(1);
            if prodFacies>glob.maxProdFacies
                prodFacies=0;
            end
            if prodFacies~=prodFaciesPrev
                transitions=transitions+1;
            end
        end
    end
end

transitionsIndex=transitions/maxTransitions;

assignin('base','transitionsIndexA',transitionsIndex);

%calculate heterogeneity fortwo facies
transitionsIndex=transitions/maxTransitions;


countF1=0;
countAll=0;
for t = 1: glob.totalIterations
    for y=1:glob.ySize
        for x=1:glob.xSize
            prodFacies=glob.facies{y,x,t}(1);
            if prodFacies==1
            %count facies 1
            countF1=countF1+1;
            countAll=countAll+1;
            else
            if prodFacies==2
                countAll=countAll+1;
            end
            end           
       end
    end
end

fractionFacies=countF1/countAll;

assignin('base','fractionFaciesA',fractionFacies);

% figure (20) 
% for a=1:12; 
%     hold on
%     if a<=6;
%     colorArray=[a/6 0 (6-a)/6];
%     else
%      colorArray=[(a-6)/6 1 (6-(a-6))/6];
%     end
%     plot(waterDepthATPoint(:,1,a),'color',colorArray); 
% 
% end
%     legend(nameLogs);


%calculate the simillarity between measured and calculated logs

% thicknessAndFraction=load('carbo-CAT/params/Purbeck/logsThickness.txt');
% posit=[1 5 9 13];
% errorFraction=zeros(numberOfLocations,1);
% for logs=1:numberOfLocations
%     x=xpoint(logs);
%     y=ypoint(logs);
%     %Calculate thickness of calculated
% initStrata=glob.strata(y,x,1);
% finalStrata=glob.strata(y,x,glob.totalIterations);
%     totalThickness=finalStrata-initStrata;
% %get thickness of measured    
% minThick= int16.empty(4,0);
% maxThick= int16.empty(4,0);
% minFr= int16.empty(4,0);
% maxFr= int16.empty(4,0);
%    for p=1:4
%    minThick(p)=thicknessAndFraction(logs,posit(p));
%    %max values
%    maxThick(p)=thicknessAndFraction(logs,posit(p)+1);
%    %min fr
%    minFr(p)=thicknessAndFraction(logs,posit(p)+2);
%    %max fr
%    maxFr(p)=thicknessAndFraction(logs,posit(p)+3);
%    end
%    totalMaxThick=sum(maxThick(:));
%    totalMinThick=sum(minThick(:));
%   
%   
%    if totalThickness>totalMaxThick
%         if totalMaxThick<999
%        errorFraction(logs)=(totalThickness-totalMaxThick)/totalMaxThick;
%         end
%    else
%        if totalThickness<totalMinThick
%             if totalMinThick<999
%        errorFraction(logs)=(totalThickness-totalMinThick)/totalMinThick;
%             end
%        end
%    end
%    
% end 
% fullError=(sum(abs(errorFraction(:))))/numberOfLocations;
% assignin('base','errorFraction',errorFraction);
% assignin('base','fullError',fullError);

end