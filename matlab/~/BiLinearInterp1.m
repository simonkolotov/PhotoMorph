function Iinterp = BiLinearInterp1(I,sizeFact)
%The function Resizes a given image I by a scale sizeFact 
%   with Bilinear Interpolation.

%Pad the original image with a border to deal with edge effects
Ipad = padarray(I,[1 1], 'replicate', 'both');   

sz = size(I); %Size of the original image
NSz = sz(1:2).*sizeFact;    %Size of the new image
Iinterp = zeros(NSz);   %Initialize the new image

tic

for ii = 1:NSz(1)
    for jj = 1: NSz(2)
        for kk = 1:3
        
            crdnt = [ii, jj]./sizeFact; %Coordinate in the old image
            fctr = crdnt - floor(crdnt);    %Factor in the Bilinear equation
            
            %Corner Pixel Coordinates
            PXL1 = Ipad(floor(crdnt(1)) + 1,floor(crdnt(2)) + 1, kk);
            PXL2 = Ipad(floor(crdnt(1)) + 2,floor(crdnt(2)) + 1, kk);
            PXL3 = Ipad(floor(crdnt(1)) + 1,floor(crdnt(2)) + 2, kk);
            PXL4 = Ipad(floor(crdnt(1)) + 2,floor(crdnt(2)) + 2, kk);
            
            F = [PXL1, PXL2; PXL3, PXL4];
            
            Iinterp (ii, jj, kk) = [1-fctr(1), fctr(1)]*F*[1-fctr(2), fctr(2)]';
            
        end
    end
end
tac
end