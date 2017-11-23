function out=MP285StartMove(xyz, resolution)
% MP285SetPos controls the position of the MP285
% 
% MP285SetPos 
% 
% Class Support
%   -------------
%   The input variable [x y z] contains the absolute motor target positions in microns. 
%   The optional paramter 'resolution' contains the resolution in nm (nanometers)
%	The value used depends on the MP285 microcode 
%% NOTES
%   The 'resolution' argument is never used by any ScanImage callers -- Vijay Iyer 9/30/08
%
%% CHANGES
% 	Modified 2/5/1 by Bernardo Sabatini to support global state and preset serialPortHandle
%   VI092908A: Use resolutionX/Y/Z instead of calibrationFactorX/Y/Z -- Vijay Iyer 9/29/08
%   VI100908A: Interrupt any pending moves before starting -- Vijay Iyer 10/9/09
%   VI101008A: Add 'out' argument to signal to caller whether move start was successful -- Vijay Iyer 10/10/08
%
%% CREDITS
%   Karel Svoboda 8/28/00 Matlab 6.0R
%	svoboda@cshl.org
%% ***********************************************

global state

out = 1; %VI101008A: assume an error, unless completed fully 

if state.motor.motorOn==0
	return
end

if nargin < 1
     disp(['-------------------------------']);  
     disp([' MP285SetPos v',version])
     disp(['-------------------------------']);
     disp([' usage: MMP285SetPos([x y z])']);
     error(['### incomplete parameters; cannot proceed']); 
end 

if nargin < 2
     resolution=100; % 100nm resolution default
end

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
	return;
end
 
if state.motor.movePending
    %%%VI100908A
    % 	disp('MP285StartMove: Error: Move already pending');
    % 	setStatusString('Move pending');
    % 	out=1;
    if MP285Interrupt
        return;
    end
    %%%%%%%%%%%%%%%%%
end

% convert microns to units of nm  mod resolution (i.e. 100nm resolution);
%xyz2=fix(xyz*10).*[state.motor.calibrationFactorX state.motor.calibrationFactorY state.motor.calibrationFactorZ];
xyz2=xyz./[state.motor.resolutionX state.motor.resolutionY state.motor.resolutionZ]; %VI092908A

% flush all the junk out
MP285Flush;
state.motor.movePending=1;
state.motor.requestedPosition=xyz;

% Set velocity to slow
% if MP285SetVelocity(state.motor.velocitySlow,1) %use fine resolution mode
%     return;
% end

% send move command
try
	fwrite(state.motor.serialPortHandle, 'm');
	fwrite(state.motor.serialPortHandle, xyz2, 'long');
	fwrite(state.motor.serialPortHandle, 13);
    out = 0; %VI101008A
catch
	%disp('MP285StartMove: MP285 communication error');
    MP285Error('Communication error starting move');
end
