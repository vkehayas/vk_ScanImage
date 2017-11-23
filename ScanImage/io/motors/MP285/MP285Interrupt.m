%% function MP285Interrupt()
%Interrupts any pending MP285 motion
%
%% NOTES
%   Interrupting the MP-285 is also found to be the right way to wake it up when non-responsive. The reset command('r') strangely doesn't do the trick.
%% CHANGES
%   VI101508A: Attempt interrupt multiple times
%
%% ****************************

function err = MP285Interrupt()
global state

errMsg = 'Failure trying to interrupt any pending MP-285 move';

err = 1;
try
    %Don't do anything if already in error condition
    if state.motor.errorCond 
        return;
    end    
    
    MP285Flush;
    interrupted = 0;
    for i=1:state.motor.maxNumInterrupts %VI101508A
        fwrite(state.motor.serialPortHandle,3);
        if isempty(MP285ReadAnswer(.1))
            continue;
        else
            interrupted = 1;
            break;
        end
        pause(.1);
    end
    
    if interrupted
        state.motor.movePending=0;
        err = 0;
    else
        MP285Error(errMsg);
    end
catch
    MP285Error(errMsg);
end








