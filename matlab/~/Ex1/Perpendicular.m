function perp=Perpendicular(vect)
% function perp=Perpendicular(vect)
%
% Give a perpendiclar vector to vect;
perp = [0, 1; -1, 0] * vect;
