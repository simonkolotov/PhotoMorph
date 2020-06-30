function Iinterp = BiLinearInterp2(I,sizeFact)
%The function Resizes a given image I by a scale sizeFact 
%   with Bilinear Interpolation.

sz = size(I); %Size of the original image
NSz = sz(1:2).*sizeFact;    %Size of the new image
Iinterp = zeros(NSz);   %Initialize the new image

%Grid
x = 1+(0:NSz(1)-1)/sizeFact(1);
y = 1+(0:NSz(2)-1)/sizeFact(2);
[X, Y] = ndgrid(x, y);

%Bilinear Coefficients
X = repmat(X-floor(X), [1,1,sz(3)]);
Y = repmat(Y-floor(Y), [1,1,sz(3)]);

%Interpolation
Iinterp = (1-Y).*((1-X).*I(floor(x), floor(y), :) + ...
					X.*I(ceil(x), floor(y), :)) + ...
			Y.*((1-X).*I(floor(x), ceil(y), :) + ...
					X.*I(ceil(x), ceil(y), :));
            
end