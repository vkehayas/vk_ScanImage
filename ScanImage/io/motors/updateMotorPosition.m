%% updateMotorPosition.m****
% Function that will read the settings from the MP285 and update the values on the screen.
%
%% CHANGES
%   VI100908A: Defer error handling to MP285Error -- Vijay Iyer 10/09/08
%% CREDITS
% Written By: Thomas Pologruto
% Cold Spring Harbor Labs
% February 1, 2001
%% **************************

function out=updateMotorPosition(updateHeader)

if nargin<1
	updateHeader=1;
end

global state gh
out=[]; 

if state.motor.motorOn == 1       
	%setStatusString('Talking to MP285...'); %VI100208A
	currentPos = MP285GetPos;	% Get current Position
	% Set the absolute values
	if isempty(currentPos)
        %%%VI100908A: This is no longer needed, as read error will thrwn an MP-285 error
		%disp('updateMotorPosition: No position information available');
		%setStatusString('MP285 Error');
        %%%%%%%%%%%%%%%%%%%%%%
		return;
    end   
    
	state.motor.absXPosition = currentPos(1,1);
	state.motor.absYPosition = currentPos(1,2);
	state.motor.absZPosition = currentPos(1,3);
	if updateHeader
		updateHeaderString('state.motor.absXPosition');
		updateHeaderString('state.motor.absYPosition');
		updateHeaderString('state.motor.absZPosition');
	end
	% Set the relative values
	updateRelativeMotorPosition(updateHeader);
	out=currentPos;
	%setStatusString(''); %VI100608A
end
