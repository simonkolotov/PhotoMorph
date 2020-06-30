function res=biLinMap(Im, xGrid, yGrid, defColor)
% function res=biLinMap(Im, xGrid, yGrid, defColor)
%
% Perform bilinear mapping (warping) of points, according to the grids.
%
% IM - Source image
% XGRID - A grid with X coordinates for the destination image
% YGRID - A grid with Y coordinates for the destination image
%
% XGRID and YGRID must be with the same dimentions.
% Any points outside the image will contain the background color, default=Black
%
% 033230095, Dori Shapira, HW-1, 04/2010

orgClass=class(Im(1));
Im=double(Im);
sz = size(Im); sz(end+1:3)=1;
Im = double(Im);

if (any(size(xGrid)-size(yGrid)))
  error('xGrid and yGrid must be with the same dimensions');
end

if (~exist('defColor', 'var'))
  defColor = zeros(1, 1, sz(3));
end

% Round up and down:
xHi = ceil(xGrid);
yHi = ceil(yGrid);
xLo = floor(xGrid);
yLo = floor(yGrid);

% Weights of the "square edges": L=Left, R=Right, B=Bottom, T=Top, W=Weight
wL = xHi - xGrid;
wB = yHi - yGrid;
wR = 1-wL;
wT = 1-wB;

% Blend only the legal points:
goodPnts = xHi <= sz(2) & xLo >= 1 & yHi <= sz(1) & yLo >= 1;
goodPnts = find(goodPnts(:));

% Calculate indexes of corners: L=Left, D=Down, R=Right, U=Up, I=Index
iLD = sub2ind(sz(1:2), yLo(goodPnts), xLo(goodPnts));
iLU = sub2ind(sz(1:2), yHi(goodPnts), xLo(goodPnts));
iRD = sub2ind(sz(1:2), yLo(goodPnts), xHi(goodPnts));
iRU = sub2ind(sz(1:2), yHi(goodPnts), xHi(goodPnts));


% Generate result's base:
res = repmat(defColor, size(xGrid));

% These two use to scan the layers:
levOffsetS=0;
levOffsetD=0;

for lev=1:sz(3)
    % Fill in the legal points:
    res(goodPnts + levOffsetD) = ...
        wL(goodPnts) .* ( wB(goodPnts) .* Im(iLD + levOffsetS) + wT(goodPnts) .* Im(iLU + levOffsetS)) + ...
        wR(goodPnts) .* ( wB(goodPnts) .* Im(iRD + levOffsetS) + wT(goodPnts) .* Im(iRU + levOffsetS));

	levOffsetD = levOffsetD + numel(xGrid); 
    levOffsetS = levOffsetS + sz(1)*sz(2); 
end

if (strcmp(orgClass, 'uint8'))
    res = uint8(res);
else
    if (~strcmp(orgClass, 'double'))
        warning('Don''t know how to convert output back. Leaving as double.');
    end
end
