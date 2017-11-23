%% function MP285Error(errorMsg)
%Function to 'throw' an MP285 error, signalling the need for a user-initiated MP285Reset to restore state
%% SYNTAX
%   MP285Error()
%   MP285Error(errorMsg)
%       errorMsg: String specifying information about the error condition 
%% NOTES
%   If an empty errorMsg string is supplied, then no error reporting is given. The MP285 is simply transitioned to the 'error' state.
%   This is useful if the calling function handles the error reporting in a specific way.
%
%% CHANGES
%   VI101008A: Set absolute positions to be unknown during an error condition -- Vijay Iyer 10/10/08
%   VI110109A: Do not display MP285 error message when in first attempt of a 'robust' action -- Vi
%   
%% CREDITS
%   Created 10/06/08 by Vijay Iyer
%% ****************************************************

function MP285Error(errorMsg)
global state

state.motor.errorCond = 1;
state.motor.movePending=0;
state.motor.lastPositionRead=[];

%%%VI101008A%%%%%%%%%%%%
state.motor.absXPosition = [];
state.motor.absYPosition = [];
state.motor.absZPosition = [];
updateRelativeMotorPosition;
%%%%%%%%%%%%%%%%%%%%%%%%

if nargin >=1 && ~isempty(errorMsg) && ~state.motor.robustAction %VI110109A
    fprintf(2,'********MP-285 ERROR***************\n');
    fprintf(2,'Error Description: %s\n',errorMsg);
    fprintf(2,'Must reset MP-285 to use again! \n');
    if state.motor.verboseError
        fprintf(2,'Error Stack:\n');
        dbstack(1);
    end
    fprintf(2,'***********************************\n');

    setStatusString('MP-285 Error');
end

turnOffMotorButtons;










