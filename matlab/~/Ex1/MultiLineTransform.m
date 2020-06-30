function Xmap=MultiLineTransform(P,Q, Ptag, Qtag, sz, a, b, xGrid, yGrid) 
% function Xmap=MultiLineTransform(P,Q, Ptag, Qtag) 
%
% Input: pairs of points P,Q of directed line segment. 
% Output: mapping of all the pixels in destination image to the pixel in the source image. 
% Use the line weighting (as shown in class and demonstrated in the paper).  
% Use a=0.2, b=0.5 
%
% Inputs:
%
% P - Lines' coordinates as [[x;y],...]
% Q - Lines' coordinates as [[x;y],...]
% PTAG - Lines' coordinates as [[x;y],...]
% QTAG - Lines' coordinates as [[x;y],...]
% SZ - Dimensions of the image (y first as in Matlab)
% A - Distance i-linearity factor (default = 0.2);
% B - Line's equallity factor (default = 0.5)
%
% 033230095, Dori Shapira, HW-1, 04/2010

% Make sure image is trated as 3D array:
sz(end+1:3)=1;

if (~exist('a', 'var'))
  a = 0.2;
  b = 0.5;
end

if (~exist('xGrid', 'var'))
    % Generate grids:
    [xGrid, yGrid] = meshgrid(1:sz(2), 1:sz(1));
end

Grid = [xGrid(:), yGrid(:)]';

Xmap    = zeros(2, size(Grid, 2));
weights = zeros(1, size(Grid, 2));

% Scan the lines:
for idx=1:size(P,2)
  Pi = P(:, idx);
  Qi = Q(:, idx);
  PiTag = Ptag(:, idx);
  QiTag = Qtag(:, idx);
  
  
  [tempLocs, dists] = SingleLineTransform(Pi, Qi, Grid, PiTag, QiTag, a, b);
  
  Xmap = Xmap + tempLocs .*[dists; dists];
  weights = weights + dists;  
  
end

% Normalize by total weight
Xmap = Xmap ./ [weights; weights];

