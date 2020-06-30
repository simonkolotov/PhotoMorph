% Make lines for an image

% imgFile = 'Lennon.jpg';
% linesFiles='Lennon.txt';
% imgNum=1;

imgFile = 'Washington.jpg';
linesFiles='Washington.txt';
imgNum=2;

figure(imgNum); clf;
imgData = imread(imgFile);
sz = size(imgData);
imagesc(imgData);
hold on;
try
    Table = load(linesFile);
    if (size(Table, 2)>4)
        error ('Expecting a one-sided lines table');
    end
catch
    Table = ones(0,4);
end




% User adds lines:
while 1
    P = Table(:,1:2)';
    Q = Table(:,3:4)';

    lh = line([P(1,:);Q(1,:)], [P(2,:);Q(2,:)]);
    dh = plot(P(1,:), P(2,:), 'o');
    [x1,y1,b] = ginput(1);
    if (b==3 | x1<1 | y1<1 | x1>sz(2) | y1 > sz(1))
        break;
    end

    hdot = plot(x1,y1, 'b+');

    [x2,y2,b] = ginput(1);
    if (b==3)
        break;
    end

    Table(end+1, :) = [x1,y1,x2,y2];
    delete (hdot);
    delete (lh);
end



dlmwrite(linesFiles, Table, 'delimiter', '\t');