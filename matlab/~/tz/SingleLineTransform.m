function  [ Xsource dist] = SingleLineTransform(Pi_s,Qi_s,Pi_d,Qi_d,Xdest)
% also returns the distance


Norm  = (Qi_d-Pi_d) * (Qi_d-Pi_d)';
u = (Xdest - Pi_d) *(Qi_d-Pi_d)'  / (Norm);
v = (Xdest-Pi_d)*Perp(Pi_d, Qi_d)'/sqrt(Norm);
Xsource = Pi_s + u*(Qi_s-Pi_s) + v * Perp( Pi_s,Qi_s) / sqrt((Qi_s-Pi_s)*(Qi_s-Pi_s)');
if (u<0)
    dist = sqrt((Xdest-Pi_d)*(Xdest-Pi_d)');
elseif (u>1)
    dist = sqrt((Xdest-Qi_d)*(Xdest-Qi_d)');
else
    dist = v;
end
end

function PL = Perp(Pi, Qi)
%Find the line perpendicular to PiQi and of equal length

PL = fliplr (Qi-Pi)*[-1 0; 0 1];

end