%% function out = startMoveStackFocus
%  Start a z position movement that is part of an image stack collection
%% SYNTAX
%   out = startMoveStackFocus
%       out: 0 if successful, 1 if an erorr occurs
%% NOTES
%   It is found that interrupted moves (either the move or the interrupt?) can lead to X/Y position shifts. So we re-use the initially determined X/Y position 
%   in setting each new slice position -- Vijay Iyer 10/16/08
%
%% CHANGES
%   VI100908A: Defer to update relativeMotorPosition() following absZPosition change -- Vijay Iyer 10/09/08
%   VI101008A: Interrupt any pending moves, while warning user -- Vijay Iyer 10/10/08
%   VI101008B: Add output argument and handle case where move start fails -- Vijay Iyer 10/10/08
%   VI101308A: Short-circuit function action if there's a pre-existing error -- Vijay Iyer 10/13/08
%   VI101608A: Compute X/Y/Z positions from initial position, rather than assuming that current values for AbsX/Y/ZPosition is correct. This allows state to be restored if absolute position has been corrupted. -- Vijay Iyer 10/16/18
%
%% CREDITS
% Written By: Thomas Pologruto
% Cold Spring Harbor Labs
% January 5, 2001
%% ************************
function out = startMoveStackFocus

global state

out = 1; %assume failure

if state.motor.errorCond %VI101308A
    fprintf(2,'WARNING (%s): Existing MP-285 error prevented attempt to start stack movement\n',mfilename);
    return;
end

%%%VI101008A%%%%%
if state.motor.movePending
    if MP285Interrupt
        return;
    end
    fprintf(2,'WARNING (%s): Pending move detected upon start of new move. Pending move was interrupted.\n',mfilename);
end
%%%%%%%%%%%%%%%%%


%%%VI101608A%%%%%%%%
% newPos(1,1) = state.motor.absXPosition;		% Set X Position to new value
% newPos(1,2) = state.motor.absYPosition;		% Set Y Position to new value
state.motor.absXPosition = state.internal.initialMotorPosition(1);
state.motor.absYPosition = state.internal.initialMotorPosition(2);
%%%%%%%%%%%%%%%%%%%%

%	updateMotorPosition(0);		% Update Motor Position
%state.motor.absZPosition = state.motor.absZPosition + state.acq.zStepSize; % Calcualte New value, %VI101608A
state.motor.absZPosition = state.internal.initialMotorPosition(3) + state.acq.zStepSize * (state.internal.zSliceCounter + 1); % Calcualte New value, %VI101608A

%%%VI100908A: Defer to updateRelativeMotorPosition() 
% state.motor.relZPosition = state.motor.absZPosition - state.motor.offsetZ; % Calculate relativveZ Position
% updateGUIByGlobal('state.motor.relZPosition');
% state.motor.distance=sqrt(state.motor.relXPosition^2+state.motor.relYPosition^2+state.motor.relZPosition^2);
% updateGUIByGlobal('state.motor.distance');
updateRelativeMotorPosition; 
%%%%%%%%%%%%%%%
   
%oldStatus=state.internal.statusString; %VI101008C
%if MP285StartMove(newPos) %VI101008B, VI101608A
if MP285StartMove([state.motor.absXPosition state.motor.absYPosition state.motor.absZPosition]) %VI101608A
    state.motor.absZPosition = state.motor.absZPosition - state.acq.zStepSize; %restore to previous value if move failed to start
    updateRelativeMotorPosition; 
    return;
end

out = 0;
%setStatusString('Moving stage...'); %VI101008C   
%setStatusString(oldStatus); %VI101008C
