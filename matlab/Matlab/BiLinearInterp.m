function Iinterp = BiLinearInterp(I,sizeFact)
%The function Resizes a given image I by a scale sizeFact 
%   with Bilinear Interpolation.

sz = size(I); %Size of the original image
NSz = sz(1:2).*sizeFact;    %Size of the new image
Iinterp = zeros(NSz);   %Initialize the new image

%Uniform Resize Grid
x = linspace(1,sz(1),NSz(1));
y = linspace(1,sz(2),NSz(2));

Iinterp = BLinter (I,x,y);
           
end