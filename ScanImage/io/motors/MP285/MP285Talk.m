%% function out=MP285Talk(in, verbose)
% Send a command to the MP285
%% SYNTAX
%   out=MP285Talk(in, verbose)
%       in: One or more characters to send to MP285 
%       verbose: Optional boolean value specifying whether function should display information
%       out: Reply, if any, from MP-285
%% NOTES
%   If 'out' is empty...then no reply was received. 
%% CHANGES
%   VI100708A: Defer to other MP85 functions for common functions (flushing/reading) -- Vijay Iyer 10/07/08
%   VI100708B: Account for case where no reply is received -- Vijay Iyer 10/08/08
%% ***********************************************

function out=MP285Talk(in, verbose)
	out=[];
	global state
	if state.motor.motorOn==0
		disp('mp285Talk: state.motor.motorOn is set to off.');
		return
	end

	if nargin < 1
 	    disp(['MP285Talk: expect string argument to send to MP285 via serial port']);
		return	
	end 

	if length(state.motor.serialPortHandle) == 0
		disp(['MP285Talk: MP285 not configured']);
		return;
	end
 
	if nargin < 2
		verbose=0;
    end 

    temp = MP285Flush; %VI100708A
    if verbose
        temp=char(reshape(temp,1,length(temp)));
        disp(['MP285Talk: [' num2str(double(temp)) '] = ' temp(1:end-1) ...
            ' flushed from MP285 serial port buffer']);
    end
    % 	n=get(state.motor.serialPortHandle,'BytesAvailable');
    % 	if n > 0
    % 		temp=fread(state.motor.serialPortHandle,n); 
    % 	end

	fwrite(state.motor.serialPortHandle, [in 13]);
	if verbose 
		disp(['MP285Talk: [' num2str(double(in)) ' CR] sent to MP285. ']);	
	end
	
	temp=MP285ReadAnswer;
    if ~isempty(temp) %VI100708B        
        temp=reshape(temp,1,length(temp));
        %%%VI100708A: This error messaging now occurs in MP285ReadAnswer
        % 	if length(temp)==0
        % 		disp('MP285Talk: MP285 Timed out without returning anything');
        % 	else
        %     if length(temp)>1 | temp(1)~=13
        %         disp(['MP285Talk: MP285 did not return 13']);
        %     end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if verbose
            disp(['MP285Talk: MP285 returned [' num2str(double(temp)) '] = ' char(temp(1:end-1))]);
        end

        out=temp;
    end

