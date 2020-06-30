function test_multiple_lines
%Tests the single line transformation function
clearvars; close all; home;

% Get a file
I = double(imread(uigetfile('~test.jpg', 'Pick an Image')));

f = figure;
set(f, 'NumberTitle', 'Off', 'Name', 'Test 1');
imshow(I/255);

clrs = get(gca,'ColorOrder');

title ('Select Start and End points for the original lines, ENTER to stop.');
[X,Y] = ginput;
Pit = [X(1:2:end-1) Y(1:2:end-1)];
Qit = [X(2:2:end) Y(2:2:end)];

for ii = 1:length(X)/2
    arrow(Pit(ii,:), Qit(ii,:), 'EdgeColor', clrs(mod(ii,8),:), 'FaceColor', clrs(mod(ii,8),:));
end

title ('Select Start and End points for the transformed lines, ENTER to stop.');
[X,Y] = ginput;
Pi = [X(1:2:end-1) Y(1:2:end-1)];
Qi = [X(2:2:end) Y(2:2:end)];

title('');
xlabel({'Original Image + Line'})

Xmap = MultiLineTransform_t(fliplr(Pi), fliplr(Qi), fliplr(Pit), fliplr(Qit), size(I));

% 
% Xmap =MultiLineTransform(P_s,Q_s,P_d,Q_d,size(destI));
Inew = zeros(size(I));
for x=1:size(Xmap,1)
    for y=1:size(Xmap,2)
        Inew(x,y,:)  = GetBiLinPoint(I,Xmap(x,y,:));
    end
end


f = figure;
set(f, 'NumberTitle', 'Off', 'Name', 'Test 1');
imshow(Inew/255);

for ii = 1:length(X)/2
    arrow(Pi(ii,:), Qi(ii,:), 'EdgeColor', clrs(mod(ii,8),:), 'FaceColor', clrs(mod(ii,8),:));
end
xlabel({'Final Image + Line'; '(Blue - out of original picture bounds)'})
end



function [val inIm]= GetBiLinPoint(SourceIm,pointEst)
inIm=true;
if (pointEst(1)<1)
    pointEst(1)=1;
    inIm=false;
end
if (pointEst(2)<1)
    pointEst(2)=1;
    inIm=false;
end
if (pointEst(1)>size(SourceIm,1))
    pointEst(1)=size(SourceIm,1);
    inIm=false;
end
if (pointEst(2)>size(SourceIm,2))
    pointEst(2)=size(SourceIm,2);
    inIm=false;
end
val = zeros(1,1,size(SourceIm,3));
xLow = floor(pointEst(1));
xUp = ceil(pointEst(1));
tmp = pointEst(1)-xLow; % / (xLow+xup);
if (tmp==0 || tmp==1)
    xFact=1;
else
    xFact = [1-tmp tmp ];
end
yLow = floor(pointEst(2));
yUp = ceil(pointEst(2));
tmp = (pointEst(2)-yLow); % \yLow-YEst + yUp-yEst  ;
if (tmp==0 || tmp==1)
    yFact =1;
else
    yFact = [1-tmp tmp ];
end
for color = 1:size(SourceIm,3)
    val(color) =xFact * SourceIm(xLow:xUp,yLow:yUp,color) * yFact';
end
end