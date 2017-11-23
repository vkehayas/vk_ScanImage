%% function MP285RobustAction(actionFunc, actionErrorMsg, callerName)
% Attempt an MP-285 action. If it fails, auto-reset MP-285 and attempt action again.
%
%% SYNTAX
%   err = MP285RobustAction(actionFunc, actionErrorMsg, callerName)
%   err = MP285RobustAction(actionFunc, actionErrorMsg)
%       err: 1 if the 'robust action' failed (twice); 0 if successful
%       actionFunc: a function handle of an MP285-related function to attempt, reset if it fails, and then attempt again
%       actionDescription: string describes the purpose of actionFunc; string should be written with the preceding phrase 'attempt to' in mind; string should not supply ending period
%       callerName: the name of the calling function, i.e. as determined by mfilename(). if omitted, it will be determined, at some expense of performance
%
%% NOTES
%   This function was created to ensure the reliability of each of the 4 actions involved in stack acquistion: 1) setting velocity, 2) starting stack moves, 3) finishing stack moves, and 4) returning home upon stack completion
%   
%   Practically, the user should always supply 'mfilename' as the third argument.
%
%   The function was modified to handle all the MP-285 functions in the mainLoop(), including functions which return vectors (and are empty when erroneous).
%
%% CHANGES
%   VI101608A: Deal with two types of action function return behaviors. First is scalar outputs, which are non-zero when erroneous. Second is vector outputs, which are empty when erroneous.
%   VI103009A: Fix displayed/logged error messages -- Vijay Iyer 10/30/09
%   VI110109A: Set/reset newly created state.motor.robustAction flag which signals when in first attempt of a robust action. This allows suppressing of excessive error messaging.
%
%% CREDITS
%   Created 10/15/08 by Vijay Iyer
%% ****************************************************

function err = MP285RobustAction(actionFunc, actionDescription, callerName)

global state 

err = 1;

%Determine caller name, if it's not supplied
if nargin < 3
    stack = dbstack(1);
    callerName = stack.name;
end

try %VI110109A
    state.motor.robustAction=1; %VI110109A
    retVal = feval(actionFunc); %try the first time
    state.motor.robustAction=0; %VI110109A
    
    if isempty(retVal) || (isscalar(retVal) && retVal~=0) %VI101608A
        fprintf(2,'WARNING (%s): First attempt to %s failed. Attempting auto-reset of MP-285...\n', callerName, actionDescription);
        if state.motor.verboseError
            fprintf(state.motor.logFile, '%s -- WARNING (%s): Attempt to %s failed. Attempting auto-reset of MP-285...\n', datestr(clock), callerName, actionDescription);
        end
        MP285Recover; %VI101508A: Attempt auto-reset
        if state.motor.errorCond
            fprintf(2,'ERROR (%s): Failed to reset the MP-285. Unable to %s.\n', callerName, actionDescription);
            if state.motor.verboseError
                fprintf(state.motor.logFile,'%s -- Auto re-start failed.\n', datestr(clock));
            end
            return;
        else
            retVal = feval(actionFunc); %Try again!
            if isempty(retVal) || (isscalar(retVal) && retVal~=0)
                fprintf(2,'ERROR (%s): Second attempt to %s also failed.\n', mfilename, actionDescription); %VI103009A
                if state.motor.verboseError
                    fprintf(state.motor.logFile,'%s -- ERROR (%s): Second attempt to %s failed.\n', datestr(clock), callerName, actionDescription); %VI103009A
                end
                return;
            else
                if state.motor.verboseError
                    fprintf(state.motor.logFile,'%s -- Successful auto-restart!\n', datestr(clock));
                end
            end
        end
    end

    err=0;
    return;
catch
    state.motor.robustAction=0; %VI110109A
    rethrow(lasterror);       
end








