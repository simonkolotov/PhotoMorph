function Iinterp = BLinter (I,x,y);
%The function performs bilinar interpolation of the 2D or 3D function I
% over 4NN of points given in (x,y).


%Bilinear Coefficients Grid
[X, Y] = ndgrid(x, y);
X = repmat(X-floor(X), [1,1,size(I,3)]);
Y = repmat(Y-floor(Y), [1,1,size(I,3)]);

%Interpolation
Iinterp = (1-Y).*((1-X).*I(floor(x), floor(y), :) + ...
					X.*I(ceil(x), floor(y), :)) + ...
			Y.*((1-X).*I(floor(x), ceil(y), :) + ...
					X.*I(ceil(x), ceil(y), :));
end