
SourceImg = 'source.jpg';
DestImg   = 'dest.jpg';
FilePath  = 'data.txt';
Src = double(imread(SourceImg))/255;
Dst = double(imread(DestImg))/255;
Table = load(FilePath);
[xGrid, yGrid] = meshgrid(1:size(Src, 2), 1:size(Src, 1));
Grid = [xGrid(:), yGrid(:)]';
ssz = size(Src); ssz(end+1:3)=1;
dsz = size(Dst); dsz(end+1:3)=1;

% 
% % Test biLinMap:
% xGrid = (1+xGrid).^.5;
% xGrid = (xGrid-min(xGrid(:))) / max(xGrid(:)) * (size(Src, 2)-1) + 1;
% 
% figure(1); clf
% subplot(2,1,1); imagesc(Src);
% subplot(2,1,2); imagesc(biLinMap(Src, xGrid, yGrid));

%{

% Test single line transform:
P=[100;100];
Q=[100;200];
Ptag=[150;50];
Qtag=[50;150];

[Xmap, weight] = SingleLineTransform(P, Q, Grid, Ptag, Qtag);
gg=reshape(Xmap', sz(1), sz(2), 2);
xG = reshape(Xmap(1,:), [sz(2), sz(1)]);
yG = reshape(Xmap(2,:), [sz(2), sz(1)]);
figure(1); clf
subplot(2,1,1); imagesc(Src);  line(Ptag, Qtag);
subplot(2,1,2); imagesc(biLinMap(Src, xG, yG));line (P, Q);

%}

% Test multiple liness transform:
% P=[100;100];
% Q=[100;200];
% Ptag=[150;50];
% Qtag=[50;150];
 
% P=[[100;100], [200;100]];
% Q=[[100;200], [200;200]];
% Ptag=[[150;50],[200;50]];
% Qtag=[[50;150], [100;150]];

% P=[[115;100], [200;100]];
% Q=[[100;200], [200;200]];
% Ptag=[[100;100],[120; 100]];
% Qtag=[[100;200], [120;200]];
% 
Ptag = Table(:,1:2)';
Qtag = Table(:,3:4)';
P = Table(:,5:6)';
Q = Table(:,7:8)';
sz=dsz;

Xmap = MultiLineTransform(P, Q, Ptag, Qtag, sz, .5, .2);
gg=reshape(Xmap', sz(1), sz(2), 2);
xG = reshape(Xmap(1,:), [sz(1), sz(2)]);
yG = reshape(Xmap(2,:), [sz(1), sz(2)]);
warpSrc=biLinMap(Src, xG, yG);
figure(1); clf
subplot(3,1,1); imagesc(Src); line ([Ptag(1,:);Qtag(1,:)], [Ptag(2,:);Qtag(2,:)]);
subplot(3,1,2); imagesc(Dst); line ([P(1,:);Q(1,:)], [P(2,:);Q(2,:)]);
subplot(3,1,3); imagesc(warpSrc); line ([P(1,:);Q(1,:)], [P(2,:);Q(2,:)]);

% 
figure(2); clf;
w=0.3;
imagesc(w*Dst + (1-w)*warpSrc);

