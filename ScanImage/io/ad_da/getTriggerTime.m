function getTriggerTime
%% function getTriggerTime
% saves trigger time and calculates seconds since program startup
%
%% NOTES
%   DEPRECATED - This functionality occurs now in acquisitionStartedFcn(), as that's only place it's needed -- Vijay Iyer 07/01/09
%
%% MODIFICATIONS
%   VI042808A Vijay Iyer 4/28/08 -- Handle case where dioTriggerTime field has not been created--create trigger time info here
%   VI110308A Vijay Iyer 11/03/08 -- Revert VI04208A. This is now handled in makeFrameByStripes().
%
%% *****************************************

	global state
%	state.internal.triggerTime = get(state.init.ai,'InitialTriggerTime');

%VI110308A
% 	if ~isfield(state.internal,'dioTriggerTime') %VI042808A
%         state.internal.dioTriggerTime = clock;
%     end
%%%%%%%
    state.internal.triggerTime = state.internal.dioTriggerTime;    
        
	state.internal.triggerTimeString = clockToString(state.internal.triggerTime);
    %TO032304a - etime chokes when one value is 0. -- Tim O'Connor 3/23/04
    if isempty(state.internal.triggerTime) | state.internal.triggerTime == 0
    	state.internal.triggerTimeInSeconds = 0;
        fprintf(2, 'Warning: state.internal.triggerTime is not valid, hardware triggering may not have occurred.\n');
        warning('state.internal.triggerTime is not valid, hardware triggering may not have occurred.');
    else
        state.internal.triggerTimeInSeconds = etime(state.internal.triggerTime, state.internal.startupTime);
    end