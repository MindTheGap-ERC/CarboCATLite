function [glob]=diffuseSiliciclastic(glob,iteration)
%diffuse

topog = glob.strata(:,:,iteration-1);
availableSpace=glob.SL(iteration)-topog(:,:);

glob.productionBySiliciclasticMap = zeros(glob.ySize,glob.xSize,glob.maxProdFacies);

%The coordinates of the point source. Either directly or from the file
startY=glob.yInitSili;
startX=glob.xInitSili;% point source
sLength = glob.sourceLength;   %line source

%Concentration rate. It describes how far the siliciclastic will spread in
%each direction. High values means it goes farther.
diffusionOnY=glob.diffY; %of concentration, in m2/yr 
diffusionOnX=glob.diffX; %of concentration, in m2/yr

totalYears=glob.deltaT.*1000000; 

loopT=100; %in years, %defines the number of difussion steps for each iteration. High steps more smooth deposition

%check if this values is small enough, if not decrease by an order of 10
%and re-check. Finite difference stability.
testDiffusion=((glob.dx)^2)/(3*loopT);
while diffusionOnY>=testDiffusion
loopT=loopT/10;
testDiffusion=((glob.dx)^2)/(3*loopT);
end

while diffusionOnX>=testDiffusion
loopT=loopT/10;
testDiffusion=((glob.dx)^2)/(3*loopT);
end

%get the water depth
waterDepthMap=glob.wd(:,:,iteration);

waterDepthMap(waterDepthMap<=0)=0;


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
            xco=startX+ceil(sLength/2)+xArray(xPoint);
            
            if yco<1; yco=1; end
            if yco>glob.ySize; yco=glob.ySize; end
            
            if xco<1; xco=1; end
            if xco>glob.xSize; xco=glob.xSize; end
            
            %check if cell is underwater
            oneWaterDepth=glob.wd(yco,xco);
            if oneWaterDepth>0
                foundCell=true;
                newY=yco;
%                 newX=xco;
            end
            
        end
    end
    
    r=r+1;
    leaveOut=leaveOut+1;
    
end

%Keep the coordinates of the source constant.
newX = startX;



%get the initial concentration from the previous time-step or zero
initialConcentration=zeros(glob.ySize,glob.xSize);

%add input concentration to the grid
initialConcentration(newY,newX:newX+sLength)=glob.inputSili;



    totalLoops=totalYears/loopT;
    if totalLoops>5000;totalLoops=5000;end %not necessary. Time consuming is totalLoops>10.000
    
    
    %re-scale de diffusion coeff to time step

    diffusionOnYScaled=diffusionOnY.*loopT; 
    diffusionOnXScaled=diffusionOnX.*loopT;

   
    for iter=1:totalLoops

        dcdx2 = circshift(initialConcentration,[0,-1]) + circshift(initialConcentration,[0,1]) - (2.*initialConcentration);%propagation in -x and +x direction
%         dcdx2 = circshift(initialConcentration,[0,-1])  - (1.*initialConcentration);%propagation only in -x or +x direction
%         dcdy2 = circshift(initialConcentration,[-1,0]) + circshift(initialConcentration,[1,0]) - (2.*initialConcentration);%propgation in -y and +y direction
        dcdy2 = circshift(initialConcentration,[1,0]) -(1.*initialConcentration);%propgation only in -y or +y direction
    
        

        deltaConcentrationx = (diffusionOnXScaled.*dcdx2) ./ ((2*glob.dx)^2);%diffusion along x-axis
        deltaConcentrationy = (diffusionOnYScaled.*dcdy2) ./ ((2*glob.dx)^2);%diffusion along y-axis
       
       %correct for material beeing diffused over cells above water
       
        for y=1:glob.ySize
            for x=1:glob.xSize
                
                
                if waterDepthMap(y,x)<=0
                    
                    
                    if deltaConcentrationx(y,x)> 0 %check for concentration shifts in the x direction
                        
                        %check the surrounding cells
                        
                        yco(1)=y;
                        yco(2)=y;
                        xco(1)=x-1; if xco(1)<1; xco(1)=1; end
                        xco(2)=x+1; if xco(2)>glob.xSize; xco(2)=glob.xSize; end
                        
                        conc(1)=initialConcentration(yco(1),xco(1));
                        conc(2)=initialConcentration(yco(2),xco(2));
                        
                        
                        %put the concentration back into original cell
                        differenceBetweenConcentrations=initialConcentration(y,x)-conc;
                        diffuseBack = (-diffusionOnXScaled.*differenceBetweenConcentrations) ./ ((2*glob.dx)^2);
                        deltaConcentrationx(y,x)=0;
                        deltaConcentrationx(yco(1),xco(1))=deltaConcentrationx(yco(1),xco(1))+diffuseBack(1);
                        deltaConcentrationx(yco(2),xco(2))=deltaConcentrationx(yco(2),xco(2))+diffuseBack(2);
                        
                        
                    end
                    if deltaConcentrationy(y,x)>0%check for concentration shifts in the y direction
                        
                        %check the surrounding cells
                        
                        xco(1)=x;
                        xco(2)=x;
                        yco(1)=y-1; if yco(1)<1; yco(1)=1; end
                        yco(2)=y+1; if yco(2)>glob.ySize; yco(2)=glob.ySize; end
                        
                        conc(1)=initialConcentration(yco(1),xco(1));
                        conc(2)=initialConcentration(yco(2),xco(2));
                        
                        
                        %put the concentration back into original cell
                        differenceBetweenConcentrations=initialConcentration(y,x)-conc;
                        diffuseBack = (-diffusionOnYScaled.*differenceBetweenConcentrations) ./ ((2*glob.dx)^2);
                        
                        deltaConcentrationy(y,x)=0;
                        deltaConcentrationy(yco(1),xco(1))=deltaConcentrationy(yco(1),xco(1))+diffuseBack(1);
                        deltaConcentrationy(yco(2),xco(2))=deltaConcentrationy(yco(2),xco(2))+diffuseBack(2);
                        
                        
                    end
                end 
            end
        end



        %change the concentration by the deltaConcentration
        deltaConcentration = deltaConcentrationy+deltaConcentrationx;
        initialConcentration = initialConcentration+deltaConcentration;



    end


    %delete concetrations below the facies cut off thickness
    initialConcentration(initialConcentration<glob.faciesThicknessPlotCutoff) = 0;
    
    
    initialConcentration(2,newX) = initialConcentration(3,newX);
    initialConcentration(1,:) = initialConcentration(2,:); 
    
    %store the concentration in the global array
    glob.concentration(:,:,iteration)=initialConcentration;

    %add a facies with its thickness to the relevant global arrays
    for y=1:glob.ySize
        for x=1:glob.xSize
            if glob.concentration(y,x,iteration) > 0
                glob.numberOfLayers(y,x,iteration)=glob.numberOfLayers(y,x,iteration)+1;
                glob.facies{y,x,iteration}(glob.numberOfLayers(y,x,iteration)) = 8;
                glob.thickness{y,x,iteration}(glob.numberOfLayers(y,x,iteration)) = glob.concentration(y,x,iteration);
            end
                       
            if glob.concentration(y,x,iteration) > availableSpace(y,x)
                glob.strata(y,x,iteration) = glob.strata(y,x,iteration-1)+availableSpace(y,x);
                glob.thickness{y,x,iteration}(glob.numberOfLayers(y,x,iteration)) = availableSpace(y,x);
            else
                glob.strata(y,x,iteration) = glob.strata(y,x,iteration-1) + glob.concentration(y,x,iteration);
            end
            
        end
    end
    
    %update the water depth array
    glob.wd(:,:,iteration) = glob.wd (:,:,iteration)- glob.concentration(:,:,iteration);
    glob.wd(glob.wd<0)=0;
  
%calculate the effect od siliciclastic to production.
%The effect is calculated as the ratio of the value at each cell over the
%value that kills production completely (kill value)
%Higher kill value =lower effect of the small concentrations, siliciclastic effect is apparent only close to the source
%Lower kill value = higher effect of small concentrations, siliciclastic effect is apparent farther from the source

%The effect of siliciclastic on each carbonate factory is quantified by the
%kill value for the factory.
killValue1 = 1; %siliciclastic effect on factory 1
killValue2 = .5; %siliciclastic effect on factory 2
killValue3 = .1; %siliciclastic effect on factory 3

for i=1:glob.maxProdFacies
    if i==1
        glob.productionBySiliciclasticMap(:,:,i) = 1.-(initialConcentration / killValue1);
    elseif i==2
        glob.productionBySiliciclasticMap(:,:,i) = 1.-(initialConcentration / killValue2);
    else
        glob.productionBySiliciclasticMap(:,:,i) = 1.-(initialConcentration / killValue3);
    end
glob.productionBySiliciclasticMap(glob.productionBySiliciclasticMap<0)=0;
    
    %calculate scale from 0-1

%     a=1/(glob.maxConcValue-glob.minConcValue);
%     b=-a*glob.minConcValue;
%     
%     glob.productionByConcentrationMap=a.*initialConcentration+b;
%     
%     glob.productionByConcentrationMap(glob.productionByConcentrationMap<0)=0;
%     glob.productionByConcentrationMap(glob.productionByConcentrationMap>1)=1;
    
end


