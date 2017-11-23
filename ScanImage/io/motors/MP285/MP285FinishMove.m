function out=MP285FinishMove(checkPosn)
% MP285FinishMove Checks for the completion of a started move and/or that the final position is as intended
%
%% SYNTAX
%   out = MP285FinishMove()
%   out = MP285FinsihMove(checkPosn)
%       out: 1 if there's an error; 0 if successful
%       checkPosn: boolean value (0 or 1) indicating whether or not to check that the final position matches the desired position. If omitted, value of 1 (true) is assumed.
%		
%% CREDITS
%   Karel Svoboda 8/28/00 Matlab 6.0R
%	svoboda@cshl.org
%
%% CHANGES
% 	Modified 2/5/1 by Bernardo Sabatini to support global state and preset serialPortHandle
%   VI050508A: Use MP285ReadAnswer() for more robust performance --  Vijay Iyer 5/5/2008 
%   VI093008A: Improve robustness/checking code -- Vijay Iyer 9/30/08
%   VI100608A: Employ MP285Interrupt() and updateMotorPosition() when respective error conditions are encountered-- Vijay Iyer 10/06/08
%   VI100808A: Attempt to refresh screen at end of move -- Vijay Iyer 10/08/08
%   VI101508A: Allow this function to be used when move has been interrupted, only to check the position -- Vijay Iyer 10/15/08
%   VI101508B: Revert VI100608A
%% **************************

	out=0;
	global state
	if state.motor.motorOn==0
		return
    end

    checkMove=1;
    
	if nargin<1
		checkPosn=1;
    end
    
	if ~state.motor.movePending %VI101508A
        checkMove=0;
        if ~checkPosn
            fprintf(2,'WARNING (%s): Called with no move pending and nothing to check.\n',mfilename);
            out=1;
            return;
        end            
    end
    
    %status=state.internal.statusString;
    if isempty(state.motor.serialPortHandle)
        %disp(['MP285SetPos: MP285 not configured']);
        fprintf(2,'ERROR (%s): MP285 not configured',mfilename);
        state.motor.lastPositionRead=[];
        out=1;
        return;
    end

    if checkMove
        %	try  %VI093008A
        %		n=get(state.motor.serialPortHandle,'BytesAvailable');
        %setStatusString('Waiting for move...');
        if isempty(MP285ReadAnswer) %VI093008A
            fprintf(2,'ERROR (%s): Motion did not complete within timeout period. Consider increasing value in INI file.\n', mfilename);
            setStatusString('Move incomplete');
            %MP285Interrupt; %VI100608A, VI101508B
            state.motor.lastPositionRead=[];
            out=1;
            return;
        end        
    end
        % 		while n==0
        % 			n=get(state.motor.serialPortHandle,'BytesAvailable');
        % 		end
        % 		temp=fread(state.motor.serialPortHandle,n);
        % 		if temp(1)~=13
        % 			disp('MP285FinishMove: Error: CR not returned by MP285');
        % 			out=1;
        % 			return
        % 		end

        %%VI093008A
        % 	catch
        % 		disp('MP285FinishMove: Error in MP285 communication');
        % 		out=1;
        % 		return
        % 	end
			
	% check if position was attained
	if checkPosn
		%setStatusString('Checking move...');
        xyzN=MP285GetPos;
		%state.motor.lastPositionRead=xyzN; 
        %if fix(state.motor.requestedPosition*10) ~= fix(xyzN*10);
        if isempty(xyzN) %In error condition
            out=1;            
            return;
        %elseif any(fix(state.motor.requestedPosition) ~= fix(xyzN)) %VI093008A
        elseif any(abs(state.motor.requestedPosition - xyzN) > state.motor.posnResolution) %VI100608A
            %setStatusString('Bad move.');
            %disp(['MP285SetPos: Requested position not attained; check hardware']);
            fprintf(2,'WARNING (%s): Requested position not attained. Note actual position.\n',mfilename);
            setStatusString('Unexpected Position');
			%state.motor.lastPositionRead=[];
			out=1;
			return
        end
        %MP285Talk('n'); %VI100808A: Attempts to refresh screen 
	end
	
	state.motor.requestedPosition=[];
	state.motor.movePending=0;
	%setStatusString(status);
	out=0;
