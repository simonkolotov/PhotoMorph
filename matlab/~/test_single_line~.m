function test_single_line1
%Tests the single line transformation function
clearvars; close all; home;

% Get a file
I = double(imread(uigetfile('test0.jpg', 'Pick an Image')));


f = figure;
set(f, 'NumberTitle', 'Off', 'Name', 'Test 1');
imshow(I/255);

title ('Select Start and End points for the original line.');
[X,Y] = ginput(2);
Pit = [X(1) Y(1)];
Qit = [X(2) Y(2)];
% Pit = fliplr([26, 71])';
% Qit = fliplr([26,20])';
arrow(Pit, Qit, 'EdgeColor', [1 0 0], 'FaceColor', [1 0 0]);

title ('Select Start and End points for the transformed line.');
[Y,X] = ginput(2);
Pi = [X(1) Y(1)];
Qi = [X(2) Y(2)];
% Pi = fliplr([26, 71])';
% Qi = fliplr([26,50])';
title('');
xlabel({'Original Image + Line'})

Inew = SingleLineMap(I, P, Qi, Pit, Qit);

f = figure;
set(f, 'NumberTitle', 'Off', 'Name', 'Test 1');
imshow(Inew/255);
arrow(Pi, Qi, 'EdgeColor', [1 0 0], 'FaceColor', [1 0 1]);
xlabel({'Final Image + Line'; '(Blue - out of original picture bounds)'})
end