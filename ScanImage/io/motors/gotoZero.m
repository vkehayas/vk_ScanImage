function gotoZero
% Moves motor to last zeroed position
%
%% CHANGES
%   VI100608A: Defer motor velocity changes to setMotorPosition() -- Vijay Iyer 10/06/08
%   VI101008A: Defer updateRelativeMotorPosition() to setMotorPosition() -- Vijay Iyer 10/10/08
%% ************************************************************

	global state
		
	setStatusString('Moving to (0,0,0)');
	%MP285SetVelocity(state.motor.velocityFast); %VI100608A
	state.motor.absXPosition=state.motor.offsetX;
	state.motor.absYPosition=state.motor.offsetY;
	state.motor.absZPosition=state.motor.offsetZ;
	setMotorPosition;
	%updateRelativeMotorPosition; %VI101008A
	%MP285SetVelocity(state.motor.velocitySlow); %VI100608A
	disp(['*** Staged moved to relative (0,0,0) ***']);
	setStatusString('');
		