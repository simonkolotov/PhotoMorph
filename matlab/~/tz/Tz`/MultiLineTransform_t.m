function Xmap =MultiLineTransform_t(P_s,Q_s,P_d,Q_d,siz)
a=0.2;
b=0.5;
p=0;
lineLength  = sqrt( diag( (P_d - Q_d) * (P_d - Q_d)' ) ) ;
lineLength = lineLength.^p;

Xmap = zeros(siz(1),siz(2),2);

for x=1:siz(1)
    for y = 1:siz(2)
        DSUM = [0,0];
        weightsum = 0;
        for line=1:size(P_s,1)
%            [ x_source dist] = SingleLineTransform(P_s(line,:),Q_s(line,:),P_d(line,:),Q_d(line,:),[x,y]);
           [ x_source dist] = SingleLineTransform_s(P_d(line,:),Q_d(line,:),[x,y],P_s(line,:),Q_s(line,:));
            weight = (lineLength(line) / (a + dist )  )^b;
            weightsum  = weightsum+ weight;
            DSUM = DSUM + weight * x_source;
        end
        Xmap(x,y,:) =  DSUM ./ weightsum;        
    end
end
% Xmap=real(Xmap); %calculation errors