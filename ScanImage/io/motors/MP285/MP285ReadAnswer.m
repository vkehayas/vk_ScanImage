function out=MP285ReadAnswer(timeout)
%% function out=MP285ReadAnswer(varargin)
%General function for reading reply from MP285, one byte at a time
%
%% SYNTAX
%   out = MP285ReadAnswer()
%   out = MP285ReadAnswer(timeout)
%       out: The bytes that are read. If empty, the timeout elapsed before any data was received.
%       timeout: The time to wait before data arrives. If omitted, the state.motor.timeout value will be used.
%
%% NOTES
%   To check if this function was successful, the calling function should use isempty(MP285ReadAnswer), which is true if the read failed.
%   
%   If calling function supplies a timeout value, it is up to that function to provide error handling/messaging.
%
%% CHANGES
%   VI050508A Vijay Iyer 05/05/08 -- Use vertical concatenation to match format returned by fread
%   VI093008A Vijay Iyer 09/30/08 -- Use state.motor.timeout to determine the timeout period
%   VI100708A Vijay Iyer 10/07/08 -- Use tic/toc to measure elapsed time, as this is more robust.
%   VI101008A Vijay Iyer 10/10/08 -- Impose all-or-none rule. If terminating CR is not received, don't return any of the returned bytes.
%   VI101408A Vijay Iyer 10/14/08 -- Allow timeout to be overridden by an input argument. Don't display timeout condition in this case.
%
%% **************

out=[];
global state
if length(state.motor.serialPortHandle) == 0
    fprintf(2,'ERROR (%s): MP285 not configured\n',mfilename);
    return;
end
% out = fgets(state.motor.serialPortHandle);

%%%VI101408A
if nargin == 0 
    timeout = state.motor.timeout;
end
%%%%%%%%%%%%%

secondTry = false;
tic;
while true
    n=get(state.motor.serialPortHandle,'BytesAvailable');
    if  n > 0
        temp=fread(state.motor.serialPortHandle,n);
        out=[out; temp]; %VI050508A
        if temp(end)==13;
            break;
        end
    end
    if toc > timeout %VI093008A, VI100708A, VI101408A
        if ~isempty(out) && ~secondTry %transmission started -- let's give it a wee bit more time to finish
            pause(1);
            secondTry = true;
            continue;
        else
            %Don't throw error here...calling function will deal with this
            out = []; %VI101008A: Don't return partial reply
            if nargin == 0 %VI101408A: only display message if no timeout was specified by claler
                fprintf(2,'WARNING (%s): Timed out after %d seconds. \n',mfilename,timeout); %VI093008A, VI101408A
            end
            break;
        end
    end
    pause(.1); %don't poll too hard
end