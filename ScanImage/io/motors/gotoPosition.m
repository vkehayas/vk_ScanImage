function out = gotoPosition(pos)
%% function out = gotoPosition(pos)
% Moves motor to saved position 
% 
%% SYNTAX
%   out = gotoPosition(ps)
%       pos: An index identifying saved Position # to go to
%       out: 0 if successful; 1 if not
%% CHANGES
%   VI100608A: Defer motor velocity changes to setMotorPosition() -- Vijay Iyer 10/06/08
%   VI101008A: Defer updateRelativeMotorPosition() to setMotorPosition() -- Vijay Iyer 10/10/08
%   VI090109A: Return whether succesful or not -- Vijay Iyer 9/1/09
%% ************************************************************

	global state
    
    out=1; %VI090109A
	if nargin<1
		pos=state.motor.position;
	end
	
	if size(state.motor.positionVectors,1)<pos
		setStatusString(['Position #' num2str(pos) ' not defined']);
		disp(['gotoPosition: ERROR position #' num2str(pos) ' not defined.  Returning.']);
		return
	end

	if sum(isnan(state.motor.positionVectors(pos,:)))>0
		setStatusString(['Position #' num2str(pos) ' not defined.']);
		disp(['gotoPosition: ERROR position #' num2str(pos) ' not defined (Contains NAN).  Returning.']);
		return
	end

	if abs(state.motor.positionVectors(pos,1)-state.motor.offsetX)>state.motor.maxXYMove ...
			| abs(state.motor.positionVectors(pos,2)-state.motor.offsetY)>state.motor.maxXYMove ...
			| abs(state.motor.positionVectors(pos,3)-state.motor.offsetZ)>state.motor.maxZMove
		setStatusString(['Position #' num2str(pos) ' too far.']);
		disp(['gotoPosition: ERROR position #' num2str(pos) ' is too far from origin.  Returning.']);
		disp(['gotoPosition: If you really want this position, reset origin or change limits in .ini file']);
		return
	end
	
	setStatusString(['Moving to position #' num2str(pos)]);
	%MP285SetVelocity(state.motor.velocityFast); %VI100608A
	state.motor.absXPosition=state.motor.positionVectors(pos,1);
	state.motor.absYPosition=state.motor.positionVectors(pos,2);
	state.motor.absZPosition=state.motor.positionVectors(pos,3);
	if setMotorPosition %VI090109A
        return; %VI090109A
    end
	%updateRelativeMotorPosition; %VI101008A
	%MP285SetVelocity(state.motor.velocitySlow); %VI100608A
	disp(['*** Staged moved to position #' num2str(pos) ' ***']);
	setStatusString('');
    out = 0; %VI090109A