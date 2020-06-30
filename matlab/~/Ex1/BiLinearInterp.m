function linterp=BiLinearInterp(Im, sizeFact)
% function linterp=BiLinearInterp(Im, sizeFact)
%
% Perform Bi-Linear interpulation for an image.
% 
% IM - An input image
% SIZEFACT - Factor scales vector (2 elements)
%
% 033230095, Dori Shapira, HW-1, 04/2010

if (size(sizeFact)==1)
    sizeFact = [sizeFact, sizeFact];
end

resSize = round(size(Im(:,:,1)) .* sizeFact);

% Calculate a map of positions:
sz = size(Im);
[xGrid,yGrid] = meshgrid(linspace(1,sz(2), resSize(2)), linspace(1,sz(1), resSize(1)));

% Send to actual function:
linterp = biLinMap(Im, xGrid, yGrid);




