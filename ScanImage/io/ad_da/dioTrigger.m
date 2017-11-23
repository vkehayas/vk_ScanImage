function dioTrigger
%% function dioTrigger
% Function that ouputs a single 1,0 to the dio device, acting as the falling edge trigger for the DAQ devices.
%
%% NOTES
% This function is used to "start" the DAQ session. 
%
% This function also opens the shutter prior to acquisition.
%
%% CHANGES
%   VI022708A Vijay Iyer 2/27/2008 - Modifications to make triggering more reliable. This solves the problem where the first focus following a configuration update would fail.
%   VI070109A Vijay Iyer 7/1/2009 - Rename dioTriggerTime to softTriggerTime. Store softTriggerTimeString value as well -- Vijay Iyer
%
%% CREDITS
% Written By: Thomas Pologruto
% Cold Spring Harbor Labs
% February 7, 2001
%% ************************************************************

global state

state.internal.softTriggerTime = clock; %VI0710109A %NOTE: This should probably be done after the putvalue() calls -- Vijay Iyer 7/1/09
%%%VI070109A%%%%%%%%
state.internal.softTriggerTimeString = clockToString(state.internal.softTriggerTime);
updateHeaderString('state.internal.softTriggerTimeString');
%%%%%%%%%%%%%%%%%%%%

%TPMODPockels
% if state.init.pockelsOn == 1
% 	% Pockels Board Trigger
% 	putvalue(state.init.pockelsLine, 1);
% 	putvalue(state.init.pockelsLine, 0);
% end

% Acquisition Board Trigger
putvalue(state.init.triggerLine, 0);			% VI022708A (for good measure)
pause(.01);                                      % VI022708A
putvalue(state.init.triggerLine, 1);			% Places an 'on' signal on the line initially
pause(.01);                                      % VI022708A
putvalue(state.init.triggerLine, 0); 			% Digital Trigger: Places a go signal (1 to 0 transition; FallingEdge) to 
												% the line to trigger the ao1, ao2, & ai.

