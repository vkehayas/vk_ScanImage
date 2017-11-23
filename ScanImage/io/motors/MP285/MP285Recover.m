%% function MP285Recover()
%Function to allow MP-285 to recover following an error
%
%% NOTES
%   The 'r' command did not appear to do anything of use with respect to recovering from serial port communication errors. 
%   The interrupt command seems to be the one that can actually re-start a stalled MP-285.
%
%% CHANGES
%   VI101008A: Provisionally clear error flag while attempting to read MP-285 position.  -- Vijay Iyer 10/10/08
%   VI101408A: Actually send an 'r' (dec val 114) for the reset command! -- Vijay Iyer 10/14/08
%   VI101408B: Add interrupt command (which attempts to interrupt multiple times). This is found to help with stalled MP-285. -- Vijay Iyer 10/14/08
%   VI101508A: Rename to MP285Recover and eliminate the 'r' command..there's no need to reset the display during recovery. -- Vijay Iyer 10/15/08
%
%% CREDITS
%   Created 10/06/08 by Vijay Iyer
%% ****************************************************

function MP285Recover
global state gh

resetErrMsg = '';
MP285Flush;
turnOffMotorButtons;

%%VI101508A%%%%%%%%
%Nominally reset the MP-285
% try
%     setStatusString('Resetting MP285...');
%     fwrite(state.motor.serialPortHandle,[114 13]); %VI101408A
% catch
%     resetErrMsg = 'Failure sending reset signal';
%     finishReset;
%     return;
% end
%%%%%%%%%%%%%%%%%%%%

state.motor.errorCond = 0; %VI101008A: Provisionally clear error flag to allow MP285Interrupt and updateMotorPosition to proceed

%%VI101408B: Interrupt the MP-285
if MP285Interrupt
    resetErrMsg = 'Unable to interrupt pending move and/or wake up stalled communication as needed in order to reset MP-285';
    finishReset;
    return;
end

%Get position 
if ~isempty(updateMotorPosition)
    finishReset; %success! (no error message)
    return;
    %     if isempty(MP285Talk('n')) %refresh display
    %         resetErrMsg = 'Unable to reset controller display following reset';
    %     end
else

    resetErrMsg = 'Unable to read motor position following reset';
    finishReset;
    return;
end

    function finishReset()
        if isempty(resetErrMsg)
            setStatusString('');
            state.motor.movePending = 0;
            state.motor.errorCond = 0;
            turnOnMotorButtons;
        else
            %state.motor.errorCond = 1; %VI101008A
            setStatusString('MP285 Reset Failure');
            if state.motor.verboseError && ~isempty(state.motor.logFile) %VI120208A              
                fprintf(state.motor.logFile,'%s (%s) MP-285 Reset Failure -- %s\n',datestr(clock),mfilename,resetErrMsg);
            end
            MP285Error;
            %             resp = questdlg(['MP-285 software reset failed!' sprintf('\n') 'Reason: ' resetErrMsg sprintf('\n') 'It is suggested to press reset on the MP-285, and then to try again.'], 'MP-285 Reset Error', 'Try Again', 'Later', 'Try Again');
            %             switch lower(resp)
            %                 case 'try again'
            %                     MP285Reset;
            %                 case 'later'
            %                     MP285Error;
            %             end
        end
    end

end















