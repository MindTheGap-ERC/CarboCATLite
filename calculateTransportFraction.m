function [transportFraction] =  calculateTransportFraction(y,x,oneFacies,glob,iteration)

waveBase=60; %The wave base depth. Max depth where transportation occurs

%The minimum depth for transportation. Above this depth transportation decreases to zero.
minD=zeros(4,1);

for i=1:4
    if i==1
        minD(i)=0.5;
    elseif i==2
        minD(i)=0.3;
    elseif i==3
        minD(i)=0.0;
    else
        minD(i)=0.5;
    end
end

% %The transported fraction is zero at the surface, increases down to a min depth and decreases with depth
%and below wave base (or a user defined depth) the transported fraction becomes zero

if glob.wd(y,x,iteration)<minD(oneFacies)
    transportFraction=glob.wd(y,x,iteration)*glob.transportFraction(oneFacies);
else
    ratio=1-((glob.wd(y,x,iteration)-minD(oneFacies))/waveBase);
    transportFraction=glob.transportFraction(oneFacies)*ratio;
    if transportFraction<0;transportFraction=0;end
end

end