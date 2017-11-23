function out=executeGoHome(cycleHome)
%% function out=executeGoHome
%   Returns motor to cached initial position, e.g. following a stack or cycle acquisition
%% SYNTAX
%   out = executeGoHome()
%   out = executeGoHome(cycleHome)
%       cycleHome: Logical value indicating, if true, to return preferably to cycle home, if it makes sense (i.e. in cycle mode). Otherwise, return to stack home. If empty/omitted, cycleHome=false is assumed.
%       out: 0 if successful, 1 if failed

%% NOTES
%   Function was rewritten from scratch. To see earlier version, see MOLD file. -- Vijay Iyer 10/30/09
%
%   Function avoids doing anything if move is not required.
%
%% CREDITS
%   Created 10/30/09, by Vijay Iyer
%   Based on version from ScanImage 3.0
%% ************************************************************

global state

if nargin < 1 || isempty(cycleHome)
    cycleHome = false;
end

out = 1; 
errMsg = '';

if ~state.motor.motorOn
    out=0;
    return 
end

if state.motor.errorCond 
    fprintf(2,'WARNING (%s): Existing MP-285 error prevented attempt to return home\n',mfilename);
    return;
end

try
    if cycleHome && ~state.standardMode.standardModeOn && state.cycle.returnHomeAtCycleEnd
        if length(state.internal.cycleInitialMotorPosition)~=3
            error('Cannot return to cycle home.  Cycle home not defined!');
        else
            if MP285RobustAction(@()updateMotorPosition,'determine motor position prior to returning to cycle home', mfilename)
                error('Failed to verify motor position');
            end
            
            %Only move if necessary
            if any(abs(state.motor.lastPositionRead - state.internal.cycleInitialMotorPosition) > state.motor.posnResolution)                
                setStatusString('Moving to cycle home');
                if MP285RobustAction(@()setMotorPosition(state.internal.cycleInitialMotorPosition),'move to initial position in cycle', mfilename)
                    error('Failed to move to cycle home.');
                end
            end
        end  

    elseif state.acq.numberOfZSlices > 1 && state.acq.returnHome
        if length(state.internal.initialMotorPosition) ~= 3
            error('Cannot return to stack home. Stack home not defined!');
        else
            if MP285RobustAction(@()updateMotorPosition,'determine motor position prior to returning to cycle home', mfilename)
                error('Failed to verify motor position');
            end

            %Only move if necessary
            if any(abs(state.motor.lastPositionRead - state.internal.initialMotorPosition) > state.motor.posnResolution)
                setStatusString('Moving to stack home');
                newPos = state.internal.initialMotorPosition; %VI101008A
                if MP285RobustAction(@()setMotorPosition(state.internal.initialMotorPosition), 'move to initial position in stack', mfilename)
                    error('Failed to move to stack home.');
                end
            end
        end
                
    end
    
    %Success!
    out = 0;   

catch
    s = lasterror;
    MP285Error(sprintf('Error in %s: %s',mfilename,s.message));
end



