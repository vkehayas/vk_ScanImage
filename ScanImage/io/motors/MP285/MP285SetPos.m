
function out=MP285SetPos(xyz, checkPosition)
% MP285SetPos controls the position of the MP285
% 
% MP285SetPos 
% 
% Class Support
%   -------------
%   The input variable [x y z] contains the absolute motor target positions in microns. 
%   The optional paramter 'resolution' contains the resolution in nm (nanometers)
%	The value used depends on the MP285 microcode 
%% CHANGES
% 	Modified 2/5/1 by Bernardo Sabatini to support global state and preset serialPortHandle
%   VI092908A: Use resolutionX/Y/Z instead of calibrationFactorX/Y/Z -- Vijay Iyer 9/29/08
%   VI093008A: Improve robustness/checking code -- Vijay Iyer 9/30/08
%   VI100108A: User MP285ReadAnswer instead of fread -- Vijay Iyer 10/1/08
%   VI100208A: Interrupt move if a timeout occurs -- Vijay Iyer 10/2/08
%   VI100608A: Removed resolution input argument. Resolution state var now used for end-of-move position error checking. -- Vijay Iyer 10/6/08
%   VI100908A: Interrupt any pending moves before starting -- Vijay Iyer 10/9/09
%   VI101008A: Short-circuit action if an error condition is present -- Vijay Iyer 10/10/08
%		
%% CREDITS
%   Karel Svoboda 8/28/00 Matlab 6.0R
%	svoboda@cshl.org
%% **********************************

out=1;
global state
if state.motor.motorOn==0
	return
end

if state.motor.errorCond %VI101008A
    return;
end

if nargin < 1
     disp(['-------------------------------']);  
     disp([' MP285SetPos v',version])
     disp(['-------------------------------']);
     disp([' usage: MMP285SetPos([x y z])']);
     error(['### incomplete parameters; cannot proceed']); 
end 

%%%VI100608A: Commented out
% if nargin < 2
%      resolution=state.motor.resolution;
% end
%%%%%%%%%%%%%%

if nargin < 2 %VI100608A: was 3
	checkPosition=1;
end

%%%VI100608A: Commented out
% if isempty(resolution)
%      resolution=state.motor.resolution;
% end
%%%%%%%%%%%%%%

if isempty(checkPosition)
	checkPosition=1;
end
%fprintf(2, 'MP285SetPos(%s, %s, %s)\n', num2str(xyz), num2str(resolution), num2str(checkPosition)); %Don't show this! 
if length(xyz) ~=3
     disp(['-------------------------------']);  
     disp([' MP285SetPos v',version])
     disp(['-------------------------------']);
     disp([' usage: MP285SetPos([x y z])'])
     error(['### incomplete or ambiguous parameters; cannot proceed']); 
end 

if length(state.motor.serialPortHandle) == 0
	disp(['MP285SetPos: MP285 not configured']);
	state.motor.lastPositionRead=[];
	out=1;
	return;
end

%%%VI100908A%%%%%
if state.motor.movePending
    if MP285Interrupt
        return;
    end
end
%%%%%%%%%%%%%%%%%

 
% convert microns to units of nm  mod resolution (i.e. 100nm resolution);
% xyz2=fix(xyz*state.motor.resolution).*	...
% 	[state.motor.calibrationFactorX state.motor.calibrationFactorY state.motor.calibrationFactorZ];
xyz2 = xyz./[state.motor.resolutionX state.motor.resolutionY state.motor.resolutionZ]; %VI092908A

% flush all the junk out
MP285Flush;

% temp=MP285Comp14ByteArr(xyz);
try
	fwrite(state.motor.serialPortHandle, 'm');
	fwrite(state.motor.serialPortHandle, xyz2, 'long');
	fwrite(state.motor.serialPortHandle, 13);
	%out=fread(state.motor.serialPortHandle,1); %VI100108A
catch
	%disp(['MP285SetPos: MP285 communication eror.']);
    MP285Error('Communication error starting move');
	return
end

%%%%VI100208A
if isempty(MP285ReadAnswer) 
    fprintf(2,'WARNING(%s): Motion did not complete within timeout period.  Consider increasing value in INI file.\n', mfilename);
    setStatusString('Move incomplete');
    MP285Interrupt;
    return;
end
%%%%%%%%%%%%%%%
%%%%VI100108A: Replaced with MP285ReadAnswer()
% if out ~= 13; 
% 	disp(['MP285SetPos: MP285 return an error.  Unsure of movement status.']); 
% 	MP285Flush;
% 	state.motor.lastPositionRead=[];
% 	out=1;
% 	return;
% end				% check if CR was returned
%%%%%%%%%%%%%

% check if position was attained
if checkPosition
	xyzN=MP285GetPos;
	if isempty(xyzN) %if it is empty, MP285GetPos has reported an error
        out=1;
        return;
    elseif any(abs(xyz-xyzN) > state.motor.posnResolution) %VI093008A, VI100608A
        fprintf(2,'WARNING (%s): Requested position not attained. Note actual position.\n',mfilename);
        setStatusString('Unexpected Position');
        %disp(['MP285SetPos: Requested position not attained; check hardware']);
        %state.motor.lastPositionRead=[];
        out=1;
        return;
    end
end

out=0;



