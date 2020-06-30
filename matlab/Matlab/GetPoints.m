function GetPoints
%The function receives corresponding lines and writes them into the text
%file for image morphing.
clear vars; close all; home;

dat_pth = uigetfile('myFiona.txt', 'Select existing Data File');
if length(dat_pth)>1
    Dat = load(dat_pth);
    Pt = Dat(:,1:2);
    Qt = Dat(:,3:4);
    P = Dat(:,5:6);
    Q = Dat(:,7:8);
else
    m_pth = uigetfile('myPoints.mat', 'Select existing Mat-File');
    
    if length(m_pth)>1
        load (m_pth);
    else
        Pt = [];
        Qt = [];
        P = [];
        Q = [];
        save  ('myPoints', 'Pt', 'P', 'Qt', 'Q')
    end
end

subplot(1,2,1);
Is_pth = uigetfile('fiona1.jpg', 'Select Source Image');
imshow(imread(Is_pth));
pic1=gca;
hold on;
ColOrd = get (gca,'ColorOrder');
title ('Original Image');

subplot(1,2,2);
Id_pth = uigetfile('fiona2.jpg', 'Select Destination Image');
imshow(imread(Id_pth));
pic2=gca;
hold on;
title ('Destination Image');

if size(P,1)>0
    axes(pic1);
    for ii = 1:size(P,1)
        cur_col = ColOrd(mod(ii,7)+1,:);
        arrow (Pt(ii,:), Qt(ii,:), 'EdgeColor', cur_col, 'FaceColor', cur_col, 'Length', 3);
    end
    
    axes(pic2);
    for ii = 1:size(P,1)
        cur_col = ColOrd(mod(ii,7)+1,:);
        arrow (P(ii,:), Q(ii,:), 'EdgeColor', cur_col, 'FaceColor', cur_col, 'Length', 3);
    end
end

ii=0;
while 1
    cur_col = ColOrd(mod(ii,7)+1,:);
    ii= ii+1;
    [x_s,y_s,button] = ginput(2);
    if (isempty(button))
        break;
    end
    axes(pic1);
    arrow([x_s(1),y_s(1)],[x_s(2),y_s(2) ], 'EdgeColor', cur_col, 'FaceColor', cur_col, 'Length', 3);
    
    [x_d,y_d,button] = ginput(2);
    if (isempty(button))
        break;
    end
    axes(pic2);
    arrow([x_d(1),y_d(1)],[x_d(2),y_d(2) ], 'EdgeColor', cur_col, 'FaceColor', cur_col, 'Length', 3);
    
    
    Pt = [Pt ; x_s(1) y_s(1)] ;
    Qt = [Qt ; x_s(2) y_s(2)] ;
    P = [P ; x_d(1) y_d(1)] ;
    Q= [Q ; x_d(2) y_d(2)] ;
    
    save  myPoints Pt P Qt Q
end
Pt =round(Pt);
Qt =round(Qt);
P =round(P);
Q= round(Q);

if length(dat_pth)>1
    file = fopen(dat_pth,'w');
else
    file = fopen('myData.txt','w');
end
for i=1:size(Pt,1)
    fprintf (file,'%.0f %.0f %.0f %.0f %.0f %.0f %.0f %.0f \n',Pt(i,1),Pt(i,2),Qt(i,1),Qt(i,2),P(i,1),P(i,2),Q(i,1),Q(i,2));
    
end
fclose(file);

