function varargout = Editor(varargin)
% EDITOR M-file for Editor.fig
%      EDITOR, by itself, creates a new EDITOR or raises the existing
%      singleton*.
%
%      H = EDITOR returns the handle to a new EDITOR or the handle to
%      the existing singleton*.
%
%      EDITOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EDITOR.M with the given input arguments.
%
%      EDITOR('Property','Value',...) creates a new EDITOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Editor_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Editor_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Copyright 2002-2003 The MathWorks, Inc.

% Edit the above text to modify the response to help Editor

% Last Modified by GUIDE v2.5 05-Apr-2010 22:24:39

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Editor_OpeningFcn, ...
                   'gui_OutputFcn',  @Editor_OutputFcn, ...
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


% --- Executes just before Editor is made visible.
function Editor_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Editor (see VARARGIN)

% Choose default command line output for Editor
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Editor wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Editor_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in bAdd.
function bAdd_Callback(hObject, eventdata, handles)
% hObject    handle to bAdd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on button press in bexit.
function bexit_Callback(hObject, eventdata, handles)
% hObject    handle to bexit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close(get(hObject, 'Parent'));



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



% --- Executes on button press in bSaveLines.
function bSaveLines_Callback(hObject, eventdata, handles)
% hObject    handle to bSaveLines (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
filter = {'*.txt', 'Text files (*.txt)'; '*.*', 'All files'};
[path, file] = uiputfile2(filter, 'Save data');
theData = get(handles.bOpenLines, 'UserData');
dlmwrite([path, file], d, 'delimiter', '\t');



function PaintLines(handles)

% Draw the lines on the images
FilePath = get(handles.bOpenLines, 'UserData');
Table = load(FilePath);
Ptag = Table(:,1:2)';
Qtag = Table(:,3:4)';
P = Table(:,5:6)';
Q = Table(:,7:8)';

line ([P(1,:);Q(1,:)], [P(2,:);Q(2,:)]);



