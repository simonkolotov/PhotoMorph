function varargout = player(varargin)
% PLAYER M-file for player.fig
%      PLAYER, by itself, creates a new PLAYER or raises the existing
%      singleton*.
%
%      H = PLAYER returns the handle to a new PLAYER or the handle to
%      the existing singleton*.
%
%      PLAYER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PLAYER.M with the given input arguments.
%
%      PLAYER('Property','Value',...) creates a new PLAYER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before player_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to player_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Copyright 2002-2003 The MathWorks, Inc.

% Edit the above text to modify the response to help player

% Last Modified by GUIDE v2.5 05-Apr-2010 11:42:18

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @player_OpeningFcn, ...
                   'gui_OutputFcn',  @player_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before player is made visible.
function player_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to player (see VARARGIN)

% Choose default command line output for player
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes player wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = player_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in bOpenL.
function bOpenL_Callback(hObject, eventdata, handles)
% hObject    handle to bOpenL (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
openUpdate(handles.axL, hObject, handles, 'img');

% --- Executes on button press in bOpenR.
function bOpenR_Callback(hObject, eventdata, handles)
% hObject    handle to bOpenR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
openUpdate(handles.axR, hObject, handles, 'img');

% --- Executes on button press in bOpenLines.
function bOpenLines_Callback(hObject, eventdata, handles)
% hObject    handle to bOpenLines (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
openUpdate(0, hObject, handles, 'data');

function openUpdate(hAxes, hStorage, handles, mode)
% Open an image/data, put it in the appropriate userdata, and recalc data
if (strcmp(mode, 'data'))
    filter = {'*.txt', 'Text files (*.txt)'; '*.*', 'All files'};
else
    filter = {'*.jpg; *.bmp; *.ppm', 'Image files (*.jpg, *.bmp, *.ppm)'; '*.*', 'All files'};
end

[filename, pathname] = uigetfile2(filter, ['Load ', mode], 'MultiSelect', 'off');
fullname = [pathname, filename];
if (strcmp(mode, 'img'))
    temp = imread(fullname);
    axes(hAxes); hold off;
    imagesc(temp);
end
set(hStorage, 'UserData', fullname);


if (strcmp(mode, 'data'))
    Recalc(handles);
end

function Recalc(handles)
% Recalculate the morphing, store in proper places, and call painting
% function.

SourceImg = get(handles.bOpenL, 'UserData');
DestImg = get(handles.bOpenR, 'UserData');
FilePath = get(handles.bOpenLines, 'UserData');

if (isempty(SourceImg) | isempty(DestImg) | isempty(FilePath))
    return
end

set(handles.bRecalc, 'enable', 'off');
drawnow;

% Paint the lines (and the source/dest images):
Table = load(FilePath);
Ptag = Table(:,1:2)';
Qtag = Table(:,3:4)';
P = Table(:,5:6)';
Q = Table(:,7:8)';

axes(handles.axL); imagesc(imread(SourceImg)); line ([Ptag(1,:);Qtag(1,:)], [Ptag(2,:);Qtag(2,:)]);
axes(handles.axR); imagesc(imread(DestImg));   line ([P(1,:);Q(1,:)], [P(2,:);Q(2,:)]);
drawnow;

a = get(handles.aVal, 'value');
b = get(handles.bVal, 'value');

MorphedImage = ImageMorphing(SourceImg, DestImg, FilePath, 1, a, b);

set(handles.figure1, 'UserData', {MorphedImage, double(imread(DestImg))/255});
PaintAll(handles);
set(handles.bRecalc, 'enable', 'on');
% Set colors back to black because it is now considered.
set([handles.aVal, handles.bVal] , 'ForegroundColor', get(handles.bOpenL, 'ForegroundColor'));
drawnow;

function PaintAll(handles)
% Paint the axMix using all properly stored data

ud = get(handles.figure1, 'UserData');
if (numel(ud)~=2)
    return;
end
DstWeight = get(handles.sliderW, 'Value');

MorphedImage = ud{1};
DestImg = ud{2};

mix = (1-DstWeight)* MorphedImage + DstWeight * DestImg;
axes(handles.axMix); hold off; 
imagesc(mix);


if (DstWeight==0)
    % Draw the lines on the mixed image as well
    FilePath = get(handles.bOpenLines, 'UserData');
    Table = load(FilePath);
    Ptag = Table(:,1:2)';
    Qtag = Table(:,3:4)';
    P = Table(:,5:6)';
    Q = Table(:,7:8)';
    line ([P(1,:);Q(1,:)], [P(2,:);Q(2,:)]);
end



function aVal_Callback(hObject, eventdata, handles)
% hObject    handle to aVal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
newVal = str2double(get(hObject, 'string'));
if (isnan(newVal))
    return;
end
set(hObject, 'value', newVal);
set(hObject, 'String', num2str(newVal));
set(hObject, 'ForegroundColor', [1,0,0]);

function bVal_Callback(hObject, eventdata, handles)
% hObject    handle to bVal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
newVal = str2double(get(hObject, 'string'));
if (isnan(newVal))
    return;
end
set(hObject, 'value', newVal);
set(hObject, 'String', num2str(newVal));
set(hObject, 'ForegroundColor', [1,0,0]);


% --- Executes during object creation, after setting all properties.
function bVal_CreateFcn(hObject, eventdata, handles)
% hObject    handle to bVal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes during object creation, after setting all properties.
function aVal_CreateFcn(hObject, eventdata, handles)
% hObject    handle to aVal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function srcW_Callback(hObject, eventdata, handles)
% hObject    handle to srcW (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of srcW as text
%        str2double(get(hObject,'String')) returns contents of srcW as a double


% --- Executes during object creation, after setting all properties.
function srcW_CreateFcn(hObject, eventdata, handles)
% hObject    handle to srcW (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on slider movement.
function sliderW_Callback(hObject, eventdata, handles)
% hObject    handle to sliderW (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
PaintAll(handles);


% --- Executes during object creation, after setting all properties.
function sliderW_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderW (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background, change
%       'usewhitebg' to 0 to use default.  See ISPC and COMPUTER.
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on button press in bexit.
function bexit_Callback(hObject, eventdata, handles)
% hObject    handle to bexit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close(get(hObject, 'Parent'));



% --- Executes on button press in bRecalc.
function bRecalc_Callback(hObject, eventdata, handles)
% hObject    handle to bRecalc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Recalc(handles);


