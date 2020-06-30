
SourceImg = 'source.jpg';
DestImg   = 'dest.jpg';
FilePath  = 'data.txt';
srcWeight = 0.5;

[MorphImage, Src] = ImageMorphing(SourceImg, DestImg, FilePath, srcWeight);

figure(1); clf; imshow(MorphImage);