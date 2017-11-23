%% function temp=MP285Flush
%Flush any bytes returned from the MP-285.
%% NOTES
%   MP285Clear() is now the appropriate function to call to prepare the MP285 for an acquisition -- Vijay Iyer 10/06/08
%% CHANGES
%   VI100608A: Don't update flags here. The function now does only what it says, namely flush the MP285 message queue. -- Vijay Iyer 10/6/08
%% *************************************************
function temp=MP285Flush
temp=[];
try
	global state
	%state.motor.positionPending=0; %VI100608A
	%state.motor.movePending=0; %VI100608A
	
	if state.motor.motorOn==0
		return
	end

	if length(state.motor.serialPortHandle) == 0
        fprintf(2,'ERROR (%s): MP285 not configured\n',mfilename);
		return;
	end
	n=get(state.motor.serialPortHandle,'BytesAvailable');
	if  n > 0
		temp=fread(state.motor.serialPortHandle,n); 
	end
catch
end
