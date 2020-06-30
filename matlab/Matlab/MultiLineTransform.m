function Xmap =MultiLineTransform(P,Q, Pt, Qt, Newsize)
%The function maps all the pixels in the destination image to the source
%image from the corresponding lines P,Q (dest.)and Pt,Qt (Source).

%Weighting Constants
a = 0.2;
b = 2;
p = 0;

nLines = size(P, 1);
Xsources = zeros(nLines,2);
Xweights = zeros(1,nLines);
Xmap = repmat(zeros(Newsize(1:2)),[1,1,2]);

%Preprocessing - Line lengths
lineLengths_exp = sqrt(diag((Q-P)*(Q-P)')).^p;



t = tic;
disp(['Transforming Lines...']);

for ii = 1:Newsize(1)
    for jj = 1:Newsize(2)
        for kk = 1: nLines
            %Calculating Xi`
            [Xsources(kk,:),Xdist] = SingleLineTransform(P(kk,:),Q(kk,:),[ii,jj], Pt(kk,:), Qt(kk,:));
            Xweights(kk) = (lineLengths_exp(kk)/(a+Xdist))^b;
            
            %Weighting the pixels
            Xmap(ii,jj,:) = Xweights*Xsources/sum(Xweights);
        end
    end
    
end

tac([num2str(nLines) ' Lines'], t);


end
