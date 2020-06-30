% uigetfile2() - same as uigetfile but remember folder location.
%
% Usage: >> uigetfile2(...)
%
% Inputs: Same as uigetfile
%
% Author: Arnaud Delorme & Hilit Serby, Scott Makeig, SCCN, UCSD, 2004
%         Thanks to input from Bas Kortmann
%
% Copyright (C) Arnaud Delorme & Hilit Serby, Scott Makeig, SCCN, UCSD, 2004
%
% Modified by Dorish

function varargout = uigetfile2(varargin);

if nargin < 1
  help uigetfile2;
  return;
end;

% remember old folder
%% search for the (mat) file which contains the latest used directory 
% -------------------
olddir = pwd;
try,
  tmp_fld = getenv('TEMP');
  if isempty(tmp_fld) & isunix
	if exist('/tmp') == 7
	  tmp_fld = '/tmp';
	end;
  end;
  if exist(fullfile(tmp_fld,'eeglab.cfg'))
	load(fullfile(tmp_fld,'eeglab.cfg'),'Path','-mat');
	s = ['cd([''' Path '''])'];
	if exist(Path) == 7, eval(s); end;
  end;

catch
 sprintf('An error occured in uigetfile2. Could not load preferences. Behaving asuigetfile.\n');
end
 
%% Show the open dialog and save the latest directory to the file
% ---------------------------------------------------------------
[varargout{1} varargout{2}] = uigetfile(varargin{:});
try,
  if varargout{1} ~= 0
	  Path = varargout{2};
	  try, save(fullfile(tmp_fld,'eeglab.cfg'),'Path','-mat','-V6'); % Matlab 7
	  catch, 
		try,  save(fullfile(tmp_fld,'eeglab.cfg'),'Path','-mat');
		catch, disp('Error in uigetfile2: save error, out of space or file permission problem');
		end
	  end
	  if isunix
		eval(['cd ' tmp_fld]);
		system('chmod 777 eeglab.cfg');
	  end
	end;

catch
 sprintf('An error occured in uigetfile2. Could not save preferences. Behaving as uigetfile.\n');
end
cd(olddir) 

