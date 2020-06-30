%%Excercise 1 in Image Processing Applications
%            Image Morphing
%Student ID 306760455, Spring 2010

function main
clear vars; close all; home;

%% -_-_-_-_-_-_-_-_-_-_-_-_-_-_-Question 1-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_%

sizeFact = [4 4];   %Scaling Factor

% Get a file
I = double(imread(uigetfile('pink_flower.jpg', 'Pick an Image')));

% Iinterp = imgrescale(I,[400, 400]);
Iinterp = BiLinearInterp(I,sizeFact);


f = figure;
set(f, 'NumberTitle', 'Off', 'Name', 'Question 1');
imshow(I/255);
title ('Original Image');

f = figure;
set(f, 'NumberTitle', 'Off', 'Name', 'Question 1');
imshow(Iinterp/255);
title ('Resized Image');


%---------Comparison----------%

Icomp = imresize(I, sizeFact.*size(I(:,:,1)), 'nearest');
f = figure;
set(f, 'NumberTitle', 'Off', 'Name', 'Question 1 - Comparison');
subplot(1,2,1);
imshow(Iinterp/255);
title ('Resized Image');
subplot(1,2,2);
imshow(Icomp/255);
title ('Comparison - Nearest Neighbor Iterpolation');

%% -_-_-_-_-_-_-_-_-_-_-_-_-_-_-Question 2-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_%

src_pth = uigetfile('fiona1.jpg', 'Select the Source Image');
dst_pth = uigetfile('fiona2.jpg', 'Select the Destination Image');
dat_pth = uigetfile('myFiona.txt', 'Select the Data File');

Is = double(imread(src_pth));
Id = double(imread(dst_pth));
Dat = load(dat_pth);
Pt = Dat(:,1:2);
Qt = Dat(:,3:4);
P = Dat(:,5:6);
Q = Dat(:,7:8);

t = tic;
MorphImage = ImageMorphing(src_pth,dst_pth,dat_pth);
tac ('the whole operation', t);

f = figure;
set(f, 'NumberTitle', 'Off', 'Name', 'Question 2 - Morphed Image');
imshow((MorphImage-0.5*Id)/255);
title ('Morphed Image');
ColOrd = get (gca,'ColorOrder');


f = figure;
set(f, 'NumberTitle', 'Off', 'Name', 'Question 2 - Morphing');
subplot(1,3,1)
imshow(Is/255);
title ('Source');
hold on;
for ii = 1:size(Dat,1)
    arrow (Pt(ii,:), Qt(ii,:), 'EdgeColor', ColOrd(mod(ii,7)+1,:), 'FaceColor', ColOrd(mod(ii,7)+1,:), 'Length', 3);
end

subplot(1,3,2)
imshow(MorphImage/255);
title ('Midway');

subplot(1,3,3)
imshow(Id/255);
title ('Destination');
for ii = 1:size(Dat,1)
    arrow (P(ii,:), Q(ii,:), 'EdgeColor', ColOrd(mod(ii,7)+1,:), 'FaceColor', ColOrd(mod(ii,7)+1,:), 'Length', 3);
end
end