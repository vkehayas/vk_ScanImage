function executeGrabOneStackCallback(h)

% executeGrabOneCallback(h).m******
% In Main Controls, This function is executed when the Grab One or Abort button is pressed.
% It will on abort requeu the data appropriate for the configuration.
% 
%% CREDITS
% Written by: Thomas Pologruto and Bernardo Sabatini
% Cold Spring Harbor Labs
% January 26, 2001
%% CHANGES
%   VI100608A: Defer motor velocity changes to setMotorPosition() -- Vijay Iyer 10/06/08
%   VI101008A: Defer updateRelativeMotorPosition() to setMotorPosition() -- Vijay Iyer 10/10/08
%% *********************************

	global state gh
	
	if length(state.motor.stackStart)~=3
		disp('*** Stack starting position not defined.');
		setStatusString('Need to set start');
		return
	end

	if length(state.motor.stackStop)~=3
		disp('*** Stack ending position not defined.');
		setStatusString('Need to set end');
		return
	end
	val=get(gh.mainControls.grabOneButton, 'String');
	visible=get(gh.mainControls.grabOneButton, 'Visible');
	
	if strcmp(visible, 'off')
		return
	end
	
	if strcmp(val, 'GRAB')
		%MP285SetVelocity(state.motor.velocityFast); %VI100608A
		setMotorPosition(state.motor.stackStart);
		%updateRelativeMotorPosition; %VI101008A
		executeGrabOneCallback(gh.mainControls.grabOneButton);
		%MP285SetVelocity(state.motor.velocitySlow); %VI100608A
	else
		executeGrabOneCallback(gh.mainControls.grabOneButton);
	end
	
	