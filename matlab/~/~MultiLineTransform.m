function Inew =MultiLineTransform(Iold, P,Q, Pt, Qt, Newsize)
%The function maps all the pixels in the destination image to the source
%image from the corresponding lines P,Q (dest.)and Pt,Qt (Source).

%Weighting Constants
a = 0.2;
b = 0.5;
p = 0;

Inew = zeros(Newsize);

nLines = size(P, 1);
Xsources = zeros(nLines,2);
Xweights = zeros(1,nLines);

%Preprocessing - Line lengths
lineLengths_exp = sqrt(diag((Q-P)*(Q-P)')).^p;
  

for ii = 1:Newsize(1)
    for jj = 1:Newsize(2)
        
        %Calculating Xi`
        for kk = 1: nLines
            [Xsources(kk,:),Xdist] = SingleLineTransform(P(kk,:),Q(kk,:),[ii,jj], Pt(kk,:), Qt(kk,:));
            Xweights(kk) = (lineLengths_exp(kk)/(a+Xdist))^b;
        end
        
        %Weighting the pixels
        Xsource = Xweights*Xsources/sum(Xweights);
        
        if (prod(Xsource)<=0)||(Xsource(1)<=0)||(prod(Xsource-Newsize(1:2))<=0)||(Xsource(1)>=Newsize(1)) %Out of Bounds
            Inew(ii,jj,:) = [0 0 255];
        elseif Xsource == floor(Xsource)     %Integer pixel
            Inew(ii,jj,:) = Iold(Xsource(1),Xsource(2),:);
        else                                %BL interpolation
            
            if Xsource(1)<1                 %Edges
                Xsource(1) = 1 + Xsource(1);
            end
            
            if Xsource(2)<1
                Xsource(2) = 1 + Xsource(2);
            end
            
            Inew(ii,jj,:) = BLinter(Iold,Xsource(1), Xsource(2));
        end
        
    end
end


end