%% function moveStackFocus
%% NOTES
%   This function does not appear to be used anywhere, but I've ma-- Vijay Iyer 10/09/08
%% CHANGES
%   VI100908A: Changes to better match startMoveStackFocus(), even though this function is probably not used at all -- Vijay Iyer 10/09/08
%
%% CREDITS
% Written By: Thomas Pologruto
% Cold Spring Harbor Labs
% January 5, 2001
%% *****************************************************

function moveStackFocus
global state

%updateMotorPosition(0);		% Update Motor Position  (REMOVED-VI100908A)

state.motor.absZPosition = state.motor.absZPosition + state.acq.zStepSize; % Calcualte New value

%%%VI100908A: Defer to updateRelativeMotorPosition() 
% state.motor.relZPosition = state.motor.absZPosition - state.motor.offsetZ; % Calculate relativveZ Position
% updateGUIByGlobal('state.motor.relZPosition');
% state.motor.distance=sqrt(state.motor.relXPosition^2+state.motor.relYPosition^2+state.motor.relZPosition^2);
% updateGUIByGlobal('state.motor.distance');
updateRelativeMotorPosition; 
%%%%%%%%%%%%%%%

newPos(1,1) = state.motor.absXPosition;		% Set X Position to new value
newPos(1,2) = state.motor.absYPosition;		% Set X Position to new value
newPos(1,3) = state.motor.absZPosition;		% Set X Position to new value

oldStatus=state.internal.statusString;
setStatusString('Moving stage...');
MP285SetPos(newPos, [], 0);
setStatusString(oldStatus);

