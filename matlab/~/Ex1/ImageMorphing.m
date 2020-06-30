function [MorphImage, Src] = ImageMorphing(SourceImg, DestImg, FilePath, srcWeight, a, b)
% function MorphImage = ImageMorphing(SourceImg, DestImg, FilePath, srcWeight, a, b)
% 
% Input: - source and destination images paths. The image names are "source.jpg" and 
% "dest.jpg" - path for input file of corresponding line segment. 
% Output: morphed image. 
% This function should read the source and destination images specified by the file path, 
% read the line segments from the file "LineSegments.txt" (supplied with the data). 
% Find the mapping of each pixel. 
% Sample the source image in the specified location to get the output image. Use the 
% function you wrote in question 1. 
% Show result. 
%
% Inputs:
%
% SOURCEIMG - Filename of image 0
% DESTIMG   - Filename of image 1
% FILEPATH  - Data file containing the lines as Px,Py,Qx,Qy,Px',Py',Qx',Qy'
% SRCWEIGHT - Weight of source image (0=only source, 1=only dest)
% A         - A parameter for morphing alg
% B         - B parameter for morphing alg
%
% 033230095, Dori Shapira, HW-1, 04/2010

if (~exist('srcWeight', 'var'))
    srcWeight = 0.25;
end

if (~exist('a', 'var')), a=0.5; end
if (~exist('b', 'var')), b=0.2; end

Src = double(imread(SourceImg))/255;
Dst = double(imread(DestImg))/255;
Table = load(FilePath);

sz = size(Dst); sz(end+1:3)=1;

Ptag = Table(:,1:2)';
Qtag = Table(:,3:4)';
P = Table(:,5:6)';
Q = Table(:,7:8)';

Xmap = MultiLineTransform(P, Q, Ptag, Qtag, sz, a, b);
xG = reshape(Xmap(1,:), [sz(1), sz(2)]);
yG = reshape(Xmap(2,:), [sz(1), sz(2)]);

MorphImage = srcWeight * biLinMap(Src, xG, yG) + (1-srcWeight) * Dst;

	 
if (nargout==0)
    clear;
end
