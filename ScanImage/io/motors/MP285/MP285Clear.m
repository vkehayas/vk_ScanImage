%% function MP285Clear()
%Function to clear MP-285 flags and prepare for subsequent commands
%% NOTES
%   This does what MP285Flush() used to do. MP285Flush() no longer updates the MP285 state vars. 
%% CHANGES
%   VI100608A: Set velocity here, as part of 'clearing' MP285 to its 'default' state -- Vijay Iyer 10/06/08
%   VI101308A: Add output argument for error checking purposes -- Vijay Iyer 10/08/08
%% CREDITS
%   Created 10/06/08 by Vijay Iyer
%% ****************************************************

function out = MP285Clear
global state 

%Clear MP-285 flags
state.motor.positionPending=0; 
state.motor.movePending=0; 
state.motor.requestedPosition=[];

%Set MP-285 to the slow velocity (VI100608A, VI101308A)
% out = MP285SetVelocity(state.motor.velocitySlow,1); %This flushes MP285 at its start  
% out = 0;

%Clear input message 'queue'
MP285Flush; 












