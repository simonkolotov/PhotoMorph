function [Xsource, weight] = SingleLineTransform(Pi, Qi, Xdest, PiTag, QiTag, a, b)
% function [Xsource, weight] = SingleLineTransform(Pi, Qi, Xdest, PiTag, QiTag, a, b)
% 
% Input: points Pi,Qi (Pi(x,y) - line start, Qi(x,y) - line end) and destination pixel Xdest. 
% Output: mapping of the destination pixel Xdest to its origin in the source image Xsource. 
% a.  Calculate u,v. 
% b.  Calculate X' 
%
% Inputs:
%
% PI - line's coordinates as [x;y], or as [[x;y],[x';y']]
% QI - line's coordinates as [x;y], or as [[x;y],[x';y']]
% XDEST - Destination coordinates, in the form of [[x;y] ...] (i.e. can be an N*2 matrix)
% PITAG - If PI,QI is only [x;y] then this is the [x';y']
% QITAG - If PI,QI is only [x;y] then this is the [x';y']
% A - Distance i-linearity factor (default = 0.2);
% B - Line's equallity factor (default = 0.5)
%
% 033230095, Dori Shapira, HW-1, 04/2010

if (~exist('PiTag', 'var'))
  % Since it's unclear, I assume that Pi and Qi are in the form of [[x;y],[x';y']]
  % as I can't see how to calculate X' without having the Pi' and Qi'
  % (unless of course PiTag and QiTag are given)
  PiTag = Pi(:,2); Pi=Pi(:,1);
  QiTag = Qi(:,2); Qi=Qi(:,1);
end

if (~exist('a', 'var'))
  a = 0.2;
  b = 0.5;
end


Pi = Pi(:); PiTag = PiTag(:);
Qi = Qi(:); QiTag = QiTag(:);

if (numel(Xdest)~=2)
  if (size(Xdest, 1)~=2)
	error('XDest should be made by vectors of [x;y]');
  end
else
  Xdest = Xdest(:);
end

Q2P = (Qi-Pi);
Q2PLen = sqrt(Q2P' * Q2P);
Q2Ptag = (QiTag-PiTag);

u = Q2P'                * (Xdest-repmat(Pi, [1, size(Xdest, 2)])) / (Q2PLen * Q2PLen);
v = Perpendicular(Q2P)' * (Xdest-repmat(Pi, [1, size(Xdest, 2)])) /  Q2PLen;

Xsource = repmat(PiTag, [1, size(v, 2)]) + Q2Ptag * u + Perpendicular(Q2Ptag)*v / sqrt(Q2Ptag' * Q2Ptag);
dists = abs(v);
distToP = sqrt( sum( (Xdest - repmat(Pi, [1, size(Xdest, 2)])).^2));
distToQ = sqrt( sum( (Xdest - repmat(Qi, [1, size(Xdest, 2)])).^2));

dists(u<0) = distToP(u<0);
dists(u>1) = distToQ(u>1);
weight = (Q2PLen ./ (a + dists ) ).^b;
