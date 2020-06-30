function Imid = BLint (Is, Xmap)
sz = size(Xmap);
Imid = zeros(sz(1),sz(2),3);
tic; disp ('Interpolating Image...');

for ii = 1:size(Xmap,1)
    for jj = 1:size(Xmap,2)
         if Xmap(ii,jj,:) == floor(Xmap(ii,jj))     %Integer pixel
            Imid(ii,jj,:) = Is(Xmap(ii,jj,1),Xmap(ii,jj,2),:);
         else
             Imid(ii,jj,:) = BLinter(Is,Xmap(ii,jj,1),Xmap(ii,jj,2));
         end
    end
end
tac('Image Interpolation');

end