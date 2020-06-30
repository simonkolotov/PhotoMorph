function [Xsource Xdist] = SingleLineTransform_s(Pi,Qi,Xdest, Pit, Qit)
%The function retrieves the transformation Xdest from
%the line given by Pi and Qi in the destination image, and
%the line given by Pit and Qit in the source image.

u = (Xdest-Pi)*(Qi-Pi)'/((Qi-Pi)*(Qi-Pi)');

v = (Xdest-Pi)*Perp(Pi, Qi)'/sqrt((Qi-Pi)*(Qi-Pi)');

Xsource = Pit + u*(Qit-Pit) + v*Perp(Pit, Qit)/sqrt((Qit-Pit)*(Qit-Pit)');


if u<0
    Xdist = sqrt((Xdest-Pi)*(Xdest-Pi)');
elseif u>1
    Xdist = sqrt((Xdest-Qi)*(Xdest-Qi)');
else
    Xdist = abs(v);
end

end

function PL = Perp(Pi, Qi)
%Find the line perpendicular to PiQi and of equal length

PL = fliplr (Qi-Pi)*[-1 0; 0 1];

end