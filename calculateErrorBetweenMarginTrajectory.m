clear all
clc

%%load saved data
strata=load('C:\EquinorProject\Meeting\28Apr\WaveNorth\strata.mat');
glob.strata=strata.strata;
numberOfLayers=load('C:\EquinorProject\Meeting\28Apr\WaveNorth\numberOfLayers.mat');
glob.numberOfLayers=numberOfLayers.numberOfLayers;
facies=load('C:\EquinorProject\Meeting\28Apr\WaveNorth\facies.mat');
glob.facies=facies.facies;
glob.ySize=size(glob.strata,1);
glob.xSize=size(glob.strata,2);
iteration=size(glob.strata,3);
glob.dx=250; %cell size
deltaT=100;  %calculate platform margin at every 100 iterations
T=linspace(deltaT,iteration,iteration/deltaT);

% %%for diagonal cross section where y=x;
% long=min(glob.xSize,glob.ySize);
% gradDiag=zeros(long,iteration);
% PfDiag=zeros(long,iteration);
% Zdiag=zeros(long,iteration);
% for y=1:long-1
%     xPos=y;
%     for t=2:iteration
%         
%         g=glob.strata(y+1,xPos+1,t)-glob.strata(y,xPos,t);
%         gradDiag(y,t)=g/25;
%         for m=1:glob.numberOfLayers(y,xPos,t)
%             if glob.facies{y+1,xPos,t}(1)==10 && glob.facies{y,xPos,t}(m)==1
%                 PfDiag(y,t)=1;
%                 Zdiag(y,t)=glob.strata(y,xPos,t);
%             elseif glob.facies{y,xPos,t}(m)==10 && glob.facies{y,xPos,t}(m)==11 && glob.facies{y+1,xPos,t}(1)==1
%                 PfDiag(y,t)=1;
%             end
%         end
%         
%         
%     end
% 
% end
% gradDiag(gradDiag>1)=1;
% gradDiag=abs(gradDiag);
% for i=1:length(T)
%     t=T(i);
%     PDiag(:,i)=gradDiag(:,t).*PfDiag(:,t);
% end
% [Xdiag,Zdiag] = find(PDiag);
% for i=1:size(Xdiag,1)
%     Z2diag(i)=glob.strata(Xdiag(i),Xdiag(i),Zdiag(i)*deltaT);    
% end
% figure
% subplot(2,1,1)
% scatter(Xdiag,Zdiag,200,'r');
% ylabel('EMT','FontSize',18,'FontWeight','bold');
% xlabel('km','FontSize',18,'FontWeight','bold');
% title(['Diagonal, t= ', num2str(0.001*iteration),'My'],'FontSize',20);
% xticks([1,  0.25*(long+2), 0.5*(long+2),  0.75*(long+2),long+1]);
% xticklabels (round([0 ,long*1.414*glob.dx/4000 ,long*1.414*glob.dx/2000,long*1.414*3*glob.dx/4000,long*1.414*glob.dx/1000]));
% % yticks([0 ,5, 10]);
% % yticklabels ([0 0.5*iteration/1000,iteration/1000]);
% axis([1 long+1 0 iteration/deltaT])
% ax=gca;
% ax.LineWidth = 0.6;
% ax.FontSize = 24;
% ax.FontWeight = 'bold';
% 
% subplot(2,1,2)
% scatter(Xdiag,Z2diag,200,'r');
% ylabel('Elevation (m)','FontSize',18,'FontWeight','bold');
% xlabel('km','FontSize',18,'FontWeight','bold');
% xticks([1,  0.25*(long+2), 0.5*(long+2),  0.75*(long+2),long+1]);
% xticklabels (round([0 ,long*1.414*glob.dx/4000 ,long*1.414*glob.dx/2000,long*1.414*3*glob.dx/4000,long*1.414*glob.dx/1000]));
% % yticks([0 ,5, 10]);
% % yticklabels ([0 0.5*iteration/1000,iteration/1000]);
% axis([1 long+1 0 1500])
% ax=gca;
% ax.LineWidth = 0.6;
% ax.FontSize = 24;
% ax.FontWeight = 'bold';


%%for othogonal cross section along y axis
xPos=glob.xSize/2;
gradY=zeros(glob.ySize,iteration); %to store elevation difference between adjacent cells
Pfy=zeros(glob.ySize,iteration); %to store probability of facies transition
Zy=zeros(glob.ySize,iteration); %to store elevation values of platform margins
for y=1:glob.ySize-1
    
    for t=2:iteration
        
        g=glob.strata(y+1,xPos,t)-glob.strata(y,xPos,t);
        gradY(y,t)=g/50; 
        for m=1:glob.numberOfLayers(y,xPos,t)
            if glob.facies{y+1,xPos,t}(1)==10 && glob.facies{y,xPos,t}(m)==1
                Pfy(y,t)=1;
                Zy(y,t)=glob.strata(y,xPos,t);
            elseif glob.facies{y,xPos,t}(m)==10 && glob.facies{y,xPos,t}(m)==11 && glob.facies{y+1,xPos,t}(1)==1
                Pfy(y,t)=1;
            end
        end
        
        
    end
end
%turn the calculated gradient into a value between 0 and 1
gradY(gradY>1)=1;
gradY=abs(gradY);
for i=1:length(T)
    t=T(i);
    Py(:,i)=gradY(:,t).*Pfy(:,t);
end
[X1,Z] = find(Py);
for i=1:size(X1,1)
    Z2(i)=glob.strata(X1(i),xPos,Z(i)*deltaT);    
end

%%plot figure in time
figure
subplot('Position',[0.14, 0.55, 0.72 0.35])
scatter(X1,Z,200,'r');
ylabel('EMT','FontSize',18,'FontWeight','bold');
xlabel('y(km)','FontSize',18,'FontWeight','bold');
title(['t= ', num2str(0.001*iteration),'My'],'FontSize',20);
xticks([1 10 20 30 40 50 60 70 80 90 100]);
xticklabels (0:(glob.dx/100):20);
% yticks([0 ,5, 10]);
% yticklabels ([0 0.5*iteration/1000,iteration/1000]);
axis([1 glob.ySize 0 iteration/deltaT])
ax=gca;
ax.LineWidth = 0.6;
ax.FontSize = 24;
ax.FontWeight = 'bold';

%%for othogonal cross section along x axis
yPos=glob.ySize/2;
gradX=zeros(glob.xSize,iteration);
Pfx=zeros(glob.xSize,iteration);
for x=1:glob.xSize-1
    
    for t=2:iteration
        g=glob.strata(yPos,x+1,t)-glob.strata(yPos,x,t);
        gradX(x,t)=g/50;
        for m=1:glob.numberOfLayers(yPos,x,t)
            if glob.facies{yPos,x+1,t}(1)==10 && glob.facies{yPos,x,t}(m)==1
                Pfx(x,t)=1;
            elseif glob.facies{yPos,x,t}(m)==10 && glob.facies{yPos,x,t}(m)==11 && glob.facies{yPos,x+1,t}(1)==1
                Pfx(x,t)=1;
            end
        end
        
        
    end
end
gradX(gradX>1)=1;
gradX=abs(gradX);
[row, col] = find(Pfx(:,1:iteration)>0); 
for i=1:length(T)
    t=T(i);
    Px(:,i)=gradX(:,t).*Pfx(:,t);
end

[X2,Z] = find(Px);
for i=1:size(X2,1)
    Z3(i)=glob.strata(yPos,X2(i),Z(i)*deltaT);    
end
subplot('Position',[0.14, 0.1, 0.68 0.35])
scatter(X2,Z,200,'r');
ylabel('EMT','FontSize',18,'FontWeight','bold');
xlabel('x(km)','FontSize',18,'FontWeight','bold');
xticks([1 10 20 30 40 50 60 70 80 90 100]);
xticklabels (0:(glob.dx/100):20);
% yticks([0 ,5, 10]);
% yticklabels ([0 0.5*iteration/1000,iteration/1000]);
axis([1 glob.xSize 0 iteration/deltaT])
ax=gca;
ax.LineWidth = 0.6;
ax.FontSize = 24;
ax.FontWeight = 'bold';


%%plot cross section in depth
figure
subplot('Position',[0.14, 0.55, 0.72 0.35])
scatter(X1,Z2,200,'r');
ylabel('Elevation (m)','FontSize',18,'FontWeight','bold');
xlabel('y(km)','FontSize',18,'FontWeight','bold');
title(['t= ', num2str(0.001*iteration),'My'],'FontSize',20);
xticks([1 10 20 30 40 50 60 70 80 90 100]);
xticklabels (0:(glob.dx/100):20);
axis([1 glob.ySize 0 1500])
ax=gca;
ax.LineWidth = 0.6;
ax.FontSize = 24;
ax.FontWeight = 'bold';

subplot('Position',[0.14, 0.1, 0.68 0.35])
scatter(X2,Z3,200,'r');
ylabel('Elevation (m)','FontSize',18,'FontWeight','bold');
xlabel('x(km)','FontSize',18,'FontWeight','bold');
xticks([1 10 20 30 40 50 60 70 80 90 100]);
xticklabels (0:(glob.dx/100):20);
axis([1 glob.xSize 0 1500])
ax=gca;
ax.LineWidth = 0.6;
ax.FontSize = 24;
ax.FontWeight = 'bold';