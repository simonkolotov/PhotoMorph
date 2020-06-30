function Imid=ImageMorphing1(Is,P,Q,Pt,Qt, szId)
%Load Image Files
% Is = double(imread(SourceImg));
% Id = double(imread(DestImg));

%Load Coordinates
% data = load(FilePath);
% P = fliplr(data(:,5:6));
% Q = fliplr(data(:,7:8));
% Pt = fliplr(data(:,1:2));
% Qt = fliplr(data(:,3:4));
szI = size(Is);

Xmap = MultiLineTransform(P,Q, Pt, Qt, szId);

%Out Of Bounds Check
Xmap (Xmap<1) = 1;

[OOBx, OOBy] = find(Xmap(:,:,1) > szI(1));
Xmap(OOBx, OOBy,1) = szI(1);

[OOBx, OOBy] = find(Xmap(:,:,2) > szI(2));
Xmap(OOBx, OOBy,2) = szI(2);

Imid = BLint (Is, Xmap);

end
