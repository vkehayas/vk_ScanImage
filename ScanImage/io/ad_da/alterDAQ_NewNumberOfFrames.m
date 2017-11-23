function alterDAQ_NewNumberOfFrames
%% function alterDAQ_NewNumberOfFrames
% Function that handles chang in the number of frames
%
%% MODIFICATIONS
% VI031108A Vijay Iyer 3/11/08 -- Use infinite acquisition in GRAB mode now...
%
%% *******************************************************

global state

stopGrab;
% GRAB output: set number of frames in GRAB output object to drive mirrors
set(state.init.ao2, 'RepeatOutput', (state.acq.numberOfFrames -1));
%TPMODPockels
if state.init.eom.pockelsOn == 1			% and pockel cell, if on
    state.init.eom.changed(:) = 1;
end

% GRAB acquisition: set up total acquisition duration
%set(state.init.ai, 'SamplesPerTrigger', state.internal.samplesPerFrame*state.acq.numberOfFrames); %VI031108A
set(state.init.ai,'SamplesPerTrigger',inf); %VI031108A
