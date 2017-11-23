function out=MP285Config
% MP285Config configures the serial port for the MP285 Sutter controler
%
% MP285Config sets up the serial port (given by sPort, i.e. 'COM2') for communication with
% Sutter's MP285 stepper motor controller.
%
% Class Support
%   -------------
%   The input char variable is the specification of the serial port, 'COM1' or 'COM2'
%	The defulat if 'COM2'. The output is the object handle for the serial port
%
%% CHANGES
%   VI100608A: Eliminate resolutionBit state variable -- Vijay Iyer 10/6/08
%   VI100808A: Use 'firmware' state var to determine resolution. Eliminate use of 'AbsOrRel' state var. -- Vijay Iyer 10/8/08
%   VI100808B: Remove attempt to limit choices to COM1 and COM2 -- Vijay Iyer 10/8/08
%   VI100808C: Use 'R' command to force MOVE screen display following reset, etc for WD/KS/SA units -- Vijay Iyer 10/8/08
%   VI103008A: Ensure that patch described in Matlab bug report 250986 is installed or disable motor -- Vijay Iyer 10/30/08
%   VI110308A: Ensure motor controls are off if the motor is turned off in the INI file -- Vijay Iyer 11/03/08
%   VI121108A: Allow for Sutter calibration fudge-factor
%   VI121308A: Eliminate use of state.motor.firmware, and have users directly enter resolutionX/Y/Z vis-a-vis umPerStepX/Y/Z
%
%% CREDITS
%   Karel Svoboda 10/1/00 Matlab 6.0R
%	 svoboda@cshl.org
%	Modified 2/5/1 by Bernardo Sabatini to support global state variable
%% *************************************************

global state
state.motor.lastPositionRead=[];

%%% VI100608A: ResolutionBit state var not used
%     if state.motor.resolutionBit==0
%         state.motor.resolution=10;
%     else
%         state.motor.resolution=40;
%     end
%%%%%%%%%%%%%%%%%%%%%%%%

if state.motor.motorOn==0
    updateMotorOn; %VI110308A
    return
end

%VI103008A: Ensure that Patch described in Matlab bug report 250986 is installed or disable motor
if verLessThan('matlab','7.6') && ~exist([matlabroot filesep 'java' filesep 'patch' filesep 'com'],'dir')
    uiwait(warndlg('The patch described in Matlab Bug Report 250986 must be installed to use the MP-285 with versions 7.0 through 2007b. See documentation for details. Motor operation has been disabled.', 'MP-285 WARNING', 'modal'));
    state.motor.motorOn = 0;
    updateMotorOn;
    return;
end
%%%%%%%%%%

%%%VI121308A%%%%%%%%%%%%%%%%
%The serial port interface transacts in microsteps, with factor of 50 microsteps-per-step (matches the ROE fine mode operation)
state.motor.resolutionX = state.motor.umPerStepX / 50;
state.motor.resolutionY = state.motor.umPerStepY / 50;
state.motor.resolutionZ = state.motor.umPerStepZ / 50;

% % Set resolution X/Y/Z based on firmware (VI100808A)
% switch lower(state.motor.firmware)
%     case {'native' 'wd'}
%         state.motor.resolutionX = .04;
%         state.motor.resolutionY = .04;
%         state.motor.resolutionZ = .04;
%     case 'ks'
%         state.motor.resolutionX = .05;
%         state.motor.resolutionY = .05;
%         state.motor.resolutionZ = .01;
%     case 'sa'
%         state.motor.resolutionX = .025;
%         state.motor.resolutionY = .025;
%         state.motor.resolutionZ = .01;
%     otherwise
%         error('Unrecognized firmware type. Valid types are ''native'', ''WD'', ''KS'', and ''SA''');
%         return;
% end
% 
% %%%VI121108A%%%%%%%%%%
% state.motor.resolutionX = state.motor.resolutionX / state.motor.calibrationAdjustX;
% state.motor.resolutionY = state.motor.resolutionY / state.motor.calibrationAdjustY;
% state.motor.resolutionZ = state.motor.resolutionZ / state.motor.calibrationAdjustZ;
% %%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% VI100808B
% 	if state.motor.port ~= 'COM1' & state.motor.port ~= 'COM2'
% 		disp(['MP285Config:  Serial port set to ' state.motor.port '?  Will use defualt COM2.']);
% 		state.motor.port='COM2';
% 	end

% close all open serial port objects on the same port and remove
% the relevant object form the workspace
port=instrfind('Port',state.motor.port);
if length(port) > 0;
    fclose(port);
    delete(port);
    clear port;
end

% make serial object named 'MP285'
state.motor.serialPortHandle = serial(state.motor.port);
set(state.motor.serialPortHandle, 'BaudRate', state.motor.baud, 'Parity', 'none' , 'Terminator', 'CR', ...
    'StopBits', 1, 'Timeout', state.motor.timeout, 'Name', 'MP285');

% open and check status
fopen(state.motor.serialPortHandle);
stat=get(state.motor.serialPortHandle, 'Status');
if ~strcmp(stat, 'open')
    disp([' MP285Config: trouble opening port; cannot to proceed']);
    state.motor.serialPortHandle=[];
    out=1;
    return;
end

%%%VI100808C: Use special macro for WD/KS/SA family
%if ismember(lower(state.motor.firmware),{'wd' 'ks' 'sa'})%VI121208A
    if isempty(MP285Talk('R'))
        MP285Error('Error placing MP-285 into special serial port MOVE mode');
    end
%end %VI121208A
%%%%%%%%%%%%%%%%%%

%Soft-resets the MP-285
try
    %setStatusString('Resetting MP285...');
    fwrite(state.motor.serialPortHandle,[114 13]); %VI101408A
catch
    beep;
    state.motor.motorOn = 0;
    warndlg('Unable to initialize MP-285. Motor has been turned off. If motor is required, ScanImage must be restarted','MP-285 Initialization Error','modal');;
    return;
end

%Verify communication with MP-285
MP285Recover;

%MP285Talk(state.motor.AbsORRel); %VI100808A
if isempty(MP285Talk('a')) %VI100808A: We always use absolute coordinates
    MP285Error('Error initializing MP-285 to use absolute coordinates');
end
MP285SetVelocity(state.motor.velocitySlow,1);
% if isempty(MP285Talk('n')) % updateScreen
%     MP285Error('Error refreshing MP-285 display',mfilename);
% end

if state.motor.verboseError
    devicePath = fileparts(mfilename('fullpath'));
    state.motor.logFile = fopen([devicePath filesep 'log.txt'],'w');
end

out=0;

