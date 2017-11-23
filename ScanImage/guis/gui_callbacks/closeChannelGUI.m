function closeChannelGUI
global state

% closeChannelGUI.m****
% Function that executes if the X is hit on the channelGUI window.
% Will reload the configurationa dn reconfigure the AI devices.
%
% Written By: Thomas Pologruto
% Cold Spring Harbor Labs
% January 31, 2001

if state.internal.channelChanged == 1;
	hideGUI('gh.channelGUI.figure1');
	applyChannelSettings;
else
	hideGUI('gh.channelGUI.figure1');
	state.internal.channelChanged=0;
end
	