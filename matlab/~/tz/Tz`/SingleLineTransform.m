function  [ Xsource dist] = SingleLineTransform(Pi_source,Qi_source,Pi_dest,Qi_dest,Xdest)
% also returns the distance


Norm  = (Qi_dest-Pi_dest) * (Qi_dest-Pi_dest)';
u = (Xdest - Pi_dest) *(Qi_dest-Pi_dest)'  / (Norm);
v = (Xdest-Pi_dest)*Perp(Pi_dest, Qi_dest)'/sqrt(Norm);
Xsource = Pi_source + u*(Qi_source-Pi_source) + v * Perp( Pi_source,Qi_source) / sqrt((Qi_source-Pi_source)*(Qi_source-Pi_source)');
if (u<0)
    dist = sqrt((Xdest-Pi_dest)*(Xdest-Pi_dest)');
elseif (u>1)
    dist = sqrt((Xdest-Qi_dest)*(Xdest-Qi_dest)');
else
    dist = v;
end

if (imag(Xsource)~=0)
    a=0;
end

end

function PL = Perp(Pi, Qi)
%Find the line perpendicular to PiQi and of equal length

PL = fliplr (Qi-Pi)*[-1 0; 0 1];

end