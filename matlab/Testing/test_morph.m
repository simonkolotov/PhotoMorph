function test_morph
%Tests the Image Morphing function
clearvars; close all; home;

MorphImage = ImageMorphing('source.jpg','dest.jpg','data.txt');


Is = double(imread(uigetfile('source.jpg', 'Select the Source Image')));
Id = double(imread(uigetfile('dest.jpg', 'Select the Destination Image')));

figure;
subplot(1,3,1)
imshow(Is/255);

subplot(1,3,2)
imshow(MorphImage/255);

subplot(1,3,3)
imshow(Id/255);

end