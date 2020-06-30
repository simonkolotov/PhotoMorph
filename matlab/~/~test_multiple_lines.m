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

Inew = MultiLineTransform(I, fliplr(Pi), fliplr(Qi), fliplr(Pit), fliplr(Qit), size(I));

f = figure;
set(f, 'NumberTitle', 'Off', 'Name', 'Test 1');
imshow(Inew/255);
for ii = 1:length(X)/2
    arrow(Pi(ii,:), Qi(ii,:), 'EdgeColor', clrs(mod(ii,8),:), 'FaceColor', clrs(mod(ii,8),:));
end
xlabel({'Final Image + Line'; '(Blue - out of original picture bounds)'})
end