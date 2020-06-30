function TimeString = tac(text_Line, tic_time)
% TimeString = tac(text_Line)
% Read the stopwatch timer.
% TAC, by itself, prints the elapsed time since TIC was used.
% t = TAC saves the elapsed time in "t".
% If the input text_Line entered,
% TimeString is followed by [' for ' text_Line].

% Copyright (c) 1996 by A.Z.Kolotov, MBT, IAI, Israel

global TICTOC;
if ( 0&([~exist('TICTOC')]|isempty(TICTOC)) )
   disp('Start time not fixed.');
   return;
end
if (nargin > 1)
    t = toc(tic_time); % Timegap in sec since a given tic.
else
    t = toc; % Timegap in sec.
end

tD = 86400; % sec in Day.
D = [t-rem(t,tD)]/tD;
t = t-tD*D;
tH = 3600; % sec in hour.
H = [t-rem(t,tH)]/tH;
t = t-tH*H;
tM = 60; % sec in min.
M = [t-rem(t,tM)]/tM;
t = t-tM*M;

if ( D )
   txt_sec = '';
else
   if ( H )
      Sprec = 1; % sec's precision.
   elseif ( M )
      Sprec = 1e-2;
   else
      Sprec = 1e-3;
   end
   S = Sprec*round(t/Sprec);
   txt_sec = [num2str(S) ' sec'];
end
txt = txt_sec;

if ( M|H|D )
   txt = [num2str(M) ' min ' txt];
end
if ( H|D )
   txt = [num2str(H) ' hours ' txt];
end
if ( D )
   txt = [num2str(D) ' days ' txt];
end
% txt = ['Time elapsed = ' txt];

if ( nargin )
	txt = [txt ' for ' text_Line];
end
if ( nargout )
   TimeString = txt;
else
   disp(txt);
end
