%% function setMotorPosition.m(newPos)
% Function that updates the MP285 motor position with the global state.motor.absX/Y/ZPosition
%% SYNTAX
%   out = setMotorPosition()
%   out = setMotorPosition(newPos)
%       out: 0 if successful; 1 if not
%       newPos: 1x3 array of absolute X/Y/Z positions to which motor should go. If empty, the absX/Y/ZPosition state variable is used. 
%
%% NOTES
%   MP285SetVelocity() failures will automatically cause MP285SetMove failures; thus there is no explicit error-checking for MP285SetVelocity() calls -- Vijay Iyer 10/10/08
%% CHANGES
%   VI100208A: Don't restore old status string -- Vijay Iyer 10/02/08
%   VI100608A: Use updateMotorPosition() to restore state following move timeout and malposition -- Vijay Iyer 10/06/08
%   VI100608B: Do large moves in two steps, teh first at high velocity. Always finish moves at low velocity. -- Vijay Iyer 10/06/08
%   VI100808A: Soft-reset the MP285 following moves to ensure ROE/controller states are synchronized. This seems to be an MP-285 bug.  -- Vijay Iyer 10/08/08
%   VI100908A: Interrupt any pending moves before starting -- Vijay Iyer 10/09/08
%   VI101008A: Update absolute position state var and call updateRelativeMotorPosition() here, as it was done in /every/ call here -- Vijay Iyer 10/10/08
%   VI101008B: Add output argument signalling success/failure -- Vijay Iyer 10/10/08
%   VI101208A: Put pause in at end of good move, so user sees 'in motion' status string and always 'feels' motion.  -- Vijay Iyer 10/12/08
%
%% CREDITS
% Written By: Thomas Pologruto
% Modified: Bernardo Sabatini 1/12/1 - combined set[X,Y,Z]MotorPosition functions into this one
% Cold Spring Harbor Labs
% January 5, 2001
%% *********************
function out = setMotorPosition(newPos)
global state

out = 1; %VI101008B

%%%VI100908A%%%%%
if state.motor.movePending
    if MP285Interrupt
        return;
    end
    fprintf(2,'WARNING (%s): Pending move detected upon start of new move. Pending move was interrupted.\n',mfilename);
    pause(.5); %Wait a moment following an interrupt
end
%%%%%%%%%%%%%%%%%

if nargin<1
    newPos(1,1) = state.motor.absXPosition;		% Set X Position to new value
    newPos(1,2) = state.motor.absYPosition;		% Set X Position to new value
    newPos(1,3) = state.motor.absZPosition;		% Set X Position to new value
elseif ~isvector(newPos) || length(newPos) ~= 3
    newPos(1,1) = state.motor.absXPosition;		% Set X Position to new value
    newPos(1,2) = state.motor.absYPosition;		% Set X Position to new value
    newPos(1,3) = state.motor.absZPosition;		% Set X Position to new value
elseif size(newPos,1) ~= 1
    newPos = newPos'; %ensure it's a column vector
end

updateHeaderString('state.motor.absXPosition');
updateHeaderString('state.motor.absYPosition');
updateHeaderString('state.motor.absZPosition');

%oldStatus=state.internal.statusString; %VI100208A
oldPos = MP285GetPos;
if isempty(oldPos) %in an error condition
    return; 
end

goodMove = true;
setStatusString('Moving stage...'); %it might take a few moments
%%%VI100608B: For large moves, do first pass at high velocity
distance = sum((oldPos-newPos).^2./[state.motor.resolutionX state.motor.resolutionY state.motor.resolutionZ]);
if distance > state.motor.fastMotionThreshold
    MP285SetVelocity(state.motor.velocityFast,0); %low resolution mode
    if MP285SetPos(newPos,0) %Don't check position at end
        goodMove = false;
        %error reported during move (e.g. timeout error)
        if ~state.motor.errorCond %check that reset is not requited
            updateMotorPosition; %VI100608A: get actual position following incomplete move, ensuring stable state    
        end
    end
end
%%%%%%%%%%%%%%%%%%%%

MP285SetVelocity(state.motor.velocitySlow,1); %VI100608B: Always finish moves at low velocity (and high resolution mode)
if MP285SetPos(newPos) 
    goodMove = false;
    %error reported during or after move
    if ~state.motor.errorCond %check that reset is not requited
        updateMotorPosition; %VI100608A: get actual position following incomplete move, ensuring stable state
    end
end

%%%VI101008A%%%%%%%%
if goodMove
    state.motor.absXPosition = newPos(1);
    state.motor.absYPosition = newPos(2);
    state.motor.absZPosition = newPos(3);
    updateRelativeMotorPosition;
    pause(1); %VI101208A 
    setStatusString(''); %VI101208A: No need to report end of motion..pause forces noticeable display of 'Moving stage...' status 
    out = 0; %VI101008B
end
%%%%%%%%%%%%%%%%%%%%%%



% else
%     setStatusString('');
%     %setStatusString(oldStatus); %VI100208A
% end





