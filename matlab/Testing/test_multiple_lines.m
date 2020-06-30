function test_multiple_lines
%Tests the multiple line transformation function
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

szI = size(I);
Xmap = MultiLineTransform(fliplr(Pi), fliplr(Qi), fliplr(Pit), fliplr(Qit), szI);

%Out Of Bounds Check
Xmap (Xmap<1) = 1;

[OOBx, OOBy] = find(Xmap(:,:,1) > szI(1));
Xmap(OOBx, OOBy,1) = szI(1);

[OOBx, OOBy] = find(Xmap(:,:,2) > szI(2));
Xmap(OOBx, OOBy,2) = szI(2);

Inew = zeros(szI);

%BL Interpolation
for ii = 1:szI(1)
    for jj = 1:szI(2)
         if Xmap(ii,jj,:) == floor(Xmap(ii,jj))     %Integer pixel
            Inew(ii,jj,:) = I(Xmap(ii,jj,1),Xmap(ii,jj,2),:);
         else
             Inew(ii,jj,:) = BLinter(I,Xmap(ii,jj,1),Xmap(ii,jj,2));
         end
    end
end

f = figure;
set(f, 'NumberTitle', 'Off', 'Name', 'Test 1');
imshow(Inew/255);
for ii = 1:length(X)/2
    arrow(Pi(ii,:), Qi(ii,:), 'EdgeColor', clrs(mod(ii,8),:), 'FaceColor', clrs(mod(ii,8),:));
end
xlabel({'Final Image + Line'; '(Out of original picture bounds - Edge Continuation)'})
end