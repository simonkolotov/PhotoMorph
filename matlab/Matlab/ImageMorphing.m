function MorphImage=ImageMorphing(SourceImg,DestImg,FilePath)
%Load Image Files
Is = double(imread(SourceImg));
Id = double(imread(DestImg));
Imid = zeros(size(Id));

%Load Coordinates
data = load(FilePath);
P = fliplr(data(:,5:6));
Q = fliplr(data(:,7:8));
Pt = fliplr(data(:,1:2));
Qt = fliplr(data(:,3:4));

Xmap = MultiLineTransform(P,Q, Pt, Qt, size(Id));

szI = size(Is);

%Out Of Bounds Check
Xmap (Xmap<1) = 1;

[OOBx, OOBy] = find(Xmap(:,:,1) > szI(1));
Xmap(OOBx, OOBy,1) = szI(1);

[OOBx, OOBy] = find(Xmap(:,:,2) > szI(2));
Xmap(OOBx, OOBy,2) = szI(2);


%BL Interpolation
tic; disp ('Interpolating Image...');

for ii = 1:size(Id,1)
    for jj = 1:size(Id,2)
         if Xmap(ii,jj,:) == floor(Xmap(ii,jj))     %Integer pixel
            Imid(ii,jj,:) = Is(Xmap(ii,jj,1),Xmap(ii,jj,2),:);
         else
             Imid(ii,jj,:) = BLinter(Is,Xmap(ii,jj,1),Xmap(ii,jj,2));
         end
    end
end
tac('Image Interpolation');



MorphImage = (Imid+Id)/2;



end
