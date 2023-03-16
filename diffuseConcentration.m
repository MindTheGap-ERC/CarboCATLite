function [glob]=diffuseConcentration(glob,iteration)
%diffuse

startY=glob.yInitConcentration;
startX=glob.xInitConcentration;
diffusionOnYplus=glob.diffYplus; %of concentration, in m2/yr
diffusionOnYminus=glob.diffYminus; %of concentration, in m2/yr
diffusionOnXplus=glob.diffXplus; %of concentration, in m2/yr
diffusionOnXminus=glob.diffXminus; %of concentration, in m2/yr

totalYears=glob.deltaT.*1000000;

totalLoops=round(sqrt((double(glob.ySize))^2+(double(glob.xSize))^2));
loopT=glob.deltaT*1000000/totalLoops; %in years

%check if this values is small enough, if not decrease by an order of 10 and re-check
testDiffusion=((glob.dx)^2)/(3*loopT);

diffArray=[diffusionOnYplus,diffusionOnYminus,diffusionOnXplus,diffusionOnXminus];
sortedDiffArray=sort(diffArray,'descend');

while sortedDiffArray(1)>=testDiffusion %only check for the larger diffusion value
    loopT=loopT/10;
    testDiffusion=((glob.dx)^2)/(3*loopT);
end

%get the water depth
waterDepthMap=glob.wd(:,:,iteration);
waterDepthMap(waterDepthMap<=0)=0;

%calculate gradient


%loop through cells around radius until cell underwater is found, in case
%the source point has been filled

foundCell=false;

r=0;
leaveOut=0;


while foundCell==false
    
    
    [yArray,xArray,length]=calculateNeighbourCellsFromRadius(r,leaveOut);
    
    for yPoint=1:length
        
        for xPoint=1:length
            
            yco=startY+yArray(yPoint);
            xco=startX+xArray(xPoint);
            
            if yco<1; yco=1; end
            if yco>glob.ySize; yco=glob.ySize; end
            
            if xco<1; xco=1; end
            if xco>glob.xSize; xco=glob.xSize; end
            
            %check if cell is underwater
            oneWaterDepth=waterDepthMap(yco,xco);
            if oneWaterDepth>0
                foundCell=true;
                newY=yco;
                newX=xco;
            end
            
        end
    end
    
    r=r+1;
    leaveOut=leaveOut+1;
    
end


%convert Rate to Volume
glob.volumeCarbonate=glob.inputRateCarbonate.*glob.deltaT.*1000000;
%convert the map from the previous itereation to concentration
initialConcentration=glob.carbonateVolMap./waterDepthMap;
initialConcentration(waterDepthMap<=0)=0;
%calculate the concentration in the initial point
%glob.inputConcentration=glob.volumeCarbonate/waterDepthMap(newY,newX);

totalLoops=totalYears/loopT;

%add input concentration to the grid
%initialConcentration(newY,newX)=glob.inputConcentration+initialConcentration(newY,newX);
inputVolAtEachLoop=glob.volumeCarbonate./totalLoops;


%re-scale de diffusion coeff to time step

diffusionOnYplusScaled=diffusionOnYplus.*loopT;
diffusionOnYminusScaled=diffusionOnYminus.*loopT;
diffusionOnXplusScaled=diffusionOnXplus.*loopT;
diffusionOnXminusScaled=diffusionOnXminus.*loopT;

%totalLoops=50;
for iter=1:totalLoops
    %figure(12); surf(initialConcentration); view([0 90]); caxis([0 glob.inputConcentration]);
        
    %add input concentration to the grid
    initialConcentration(newY,newX)=inputVolAtEachLoop/waterDepthMap(newY,newX)+initialConcentration(newY,newX);

    concxminus= circshift(initialConcentration,[0,-1]);
    concxplus= circshift(initialConcentration,[0,1]);
    concyminus= circshift(initialConcentration,[-1,0]);
    concyplus= circshift(initialConcentration,[1,0]);
    
    wdxminus= circshift(waterDepthMap,[0,-1]);
    wdxplus= circshift(waterDepthMap,[0,1]);
    wdyminus= circshift(waterDepthMap,[-1,0]);
    wdyplus= circshift(waterDepthMap,[1,0]);
    
    nxminus=zeros(glob.ySize,glob.xSize);
    nxplus=zeros(glob.ySize,glob.xSize);
    
    nyminus=zeros(glob.ySize,glob.xSize);
    nyplus=zeros(glob.ySize,glob.xSize);
    
    concxminus(waterDepthMap<=0)=0;
    concxplus(waterDepthMap<=0)=0;
    
    concyminus(waterDepthMap<=0)=0;
    concyplus(waterDepthMap<=0)=0;
    
    %control the diffusion towards exposed cells
    nxminus(wdxminus>0)=nxminus(wdxminus>0)+1;
    nxplus(wdxplus>0)=nxplus(wdxplus>0)+1;
    
    nyminus(wdyminus>0)=nyminus(wdyminus>0)+1;
    nyplus(wdyplus>0)=nyplus(wdyplus>0)+1;
    
    
    dcdx2minus = concxminus - (nxminus.*initialConcentration);
    dcdx2plus = concxplus - (nxplus.*initialConcentration);
    
    dcdy2minus = concyminus - (nyminus.*initialConcentration);
    dcdy2plus = concyplus - (nyplus.*initialConcentration);
    
    %diffusion acts slower when depth increases, and faster when depth
    %decreases
    diffusionOnXminusScaledMap=diffusionOnXminusScaled./waterDepthMap;
    diffusionOnXminusScaledMap(waterDepthMap<1.0)=diffusionOnXminusScaled;
    diffusionOnXplusScaledMap=diffusionOnXplusScaled./waterDepthMap;
    diffusionOnXplusScaledMap(waterDepthMap<1.0)=diffusionOnXminusScaled;
    diffusionOnYminusScaledMap=diffusionOnYminusScaled./waterDepthMap;
    diffusionOnYminusScaledMap(waterDepthMap<1.0)=diffusionOnXminusScaled;
    diffusionOnYplusScaledMap=diffusionOnYplusScaled./waterDepthMap;
    diffusionOnYplusScaledMap(waterDepthMap<1.0)=diffusionOnXminusScaled;
    
    deltaConcentrationxminus = (diffusionOnXminusScaledMap.*dcdx2minus) ./ ((2*glob.dx)^2);
    deltaConcentrationxplus = (diffusionOnXplusScaledMap.*dcdx2plus) ./ ((2*glob.dx)^2);
    
    
    deltaConcentrationyminus = (diffusionOnYminusScaledMap.*dcdy2minus) ./ ((2*glob.dx)^2);
    deltaConcentrationyplus = (diffusionOnYplusScaledMap.*dcdy2plus) ./ ((2*glob.dx)^2);
    
    %re-scale the concentration to the new depth
    %get the volume that has been transferred
    deltaConcentrationxminus(deltaConcentrationxminus>0) = deltaConcentrationxminus(deltaConcentrationxminus>0).*wdxminus(deltaConcentrationxminus>0)./waterDepthMap(deltaConcentrationxminus>0);
    deltaConcentrationxplus(deltaConcentrationxplus>0) = deltaConcentrationxplus(deltaConcentrationxplus>0).*wdxplus(deltaConcentrationxplus>0)./waterDepthMap(deltaConcentrationxplus>0);
    
    
    deltaConcentrationyminus(deltaConcentrationyminus>0) = deltaConcentrationyminus(deltaConcentrationyminus>0).*wdyminus(deltaConcentrationyminus>0)./waterDepthMap(deltaConcentrationyminus>0);
    deltaConcentrationyplus(deltaConcentrationyplus>0) = deltaConcentrationyplus(deltaConcentrationyplus>0).*wdyplus(deltaConcentrationyplus>0)./waterDepthMap(deltaConcentrationyplus>0);
    
    
    deltaConcentration = deltaConcentrationyminus+deltaConcentrationxminus+deltaConcentrationyplus+deltaConcentrationxplus;
    initialConcentration = initialConcentration+deltaConcentration;
end

%transform to volume
glob.carbonateVolMap=initialConcentration.*waterDepthMap;

%in case you want to plot the concentration
% figure(10)
% subplot(1,3,1);
% hold on
% % surf(glob.strata(:,:,1),'edgecolor', 'none'); view([0 90]);  axis square, axis tight ;colorbar ;
% contourf(glob.strata(:,:,1),10); view([0 90]);  axis square, axis tight ;colorbar ;
% contour(glob.strata(:,:,1),[0 0],'w','linewidth',2);
% xlabel(' distance (km)');
% ylabel('distance (km)');
% title('elevation (m)')
% subplot(1,3,2);
% hold on
% contourf(initialConcentration,5); view([0 90]); colorbar; axis square, axis tight;
% contour(glob.strata(:,:,1),[0 0],'w','linewidth',2);
% xlabel(' distance (km)');
% ylabel('distance (km)');
% title('carbonate concentration (m3/m)')
% subplot(1,3,3);
% hold on
% contourf(glob.carbonateVolMap,5); view([0 90]); colorbar; axis square, axis tight;
% contour(glob.strata(:,:,1),[0 0],'w','linewidth',2);
% xlabel(' distance (km)');
% ylabel('distance (km)');
% title('dissolved carbonate (m3)')
end


