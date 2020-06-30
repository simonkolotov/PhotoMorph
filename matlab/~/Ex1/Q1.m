% Ex-1. Q1, Dori Shapira, 033230095, 04/2010
%
% Bi-linear resampling:
%
% 033230095, Dori Shapira, HW-1, 04/2010
src='pink_flower.jpg';
Im = imread(src);
bigIm = BiLinearInterp(Im, 4);

figure(1); clf; ; imshow(Im); title('Source');
figure(2); clf; ; imshow(bigIm); title('Bilinear');
figure(3); clf; ; imshow(imresize(Im, [400,400])); title('NN');




