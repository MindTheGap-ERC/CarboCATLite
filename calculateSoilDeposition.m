function glob = calculateSoilDeposition (glob,iteration)
% deposit soil and diffuse it

rate=0; %m My-1
thicknessToDeposit=rate.*glob.deltaT;
soilThickness=zeros(glob.ySize,glob.xSize);
wdMap=glob.SL(iteration)-glob.strata(:,:,iteration);
%calculate
soilThickness(wdMap<=0)=thicknessToDeposit;
newThickness=zeros(glob.ySize,glob.xSize);
%add to topo



%diffuse
k=500; %in m^2 yr-1
%scale

loopT=glob.deltaT*1000000; 

testDiffusion=((glob.dx)^2)/(3*loopT); %in m^2 yr-1

%check if the diff coeff is small enough
while k>=testDiffusion
loopT=loopT/10; %decrease deltaT
testDiffusion=((glob.dx)^2)/(3*loopT);
end

totalLoops=(glob.deltaT*1000000)/loopT;
k=k*loopT;
%get the elevation after production and deposition od suspended sediment
elev = glob.strata(:,:,iteration)+soilThickness;

originalBasement = glob.strata(:,:,iteration);

basement=originalBasement;

for l=1:totalLoops
%Calculate the second derivative in each dimension
dzdx2 = circshift(elev,[0,-1]) + circshift(elev,[0,1]) - (2.*elev);
dzdy2 = circshift(elev,[-1,0]) + circshift(elev,[1,0]) - (2.*elev);

%Diffuse

deltaHx = (k.*dzdx2) ./ ((2*glob.dx)^2);
deltaHy = (k.*dzdy2) ./ ((2*glob.dx)^2);

%create new elevation by adding each dimension
elevAfterDiffusion = (elev+deltaHy+deltaHx);
elev=elevAfterDiffusion;
end


thickMap=elevAfterDiffusion-originalBasement;
thickMap(thickMap<0)=0;
%correct for exposed cells

for y=1:glob.ySize
    for x=1:glob.xSize

        if glob.facies{y,x,iteration}(1)==9;
           if thickMap(y,x)>0 
            if glob.numberOfLayers(y,x,iteration)>1
                glob.thickness{y,x,iteration}(glob.numberOfLayers(y,x,iteration)+1)=thickMap(y,x);
                glob.strata(y,x,iteration)=glob.strata(y,x,iteration)+thickMap(y,x);
                glob.facies{y,x,iteration}(glob.numberOfLayers(y,x,iteration)+1)=9;
            else
                glob.thickness{y,x,iteration}(1)=thickMap(y,x);
                glob.strata(y,x,iteration)=glob.strata(y,x,iteration)+thickMap(y,x);
                glob.facies{y,x,iteration}(1)=9;
            end
           end

        end
    end
end

end
