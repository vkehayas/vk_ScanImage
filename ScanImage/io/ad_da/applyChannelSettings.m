function applyChannelSettings
global state
% This fucntion is called after the Channel GUI is changed....

% Define logic for the rest of the softwarre to follow.

state.acq.acquiringChannel=[];
state.acq.savingChannel=[];
state.acq.imagingChannel=[];
state.acq.maxImage=[];
for i = 1:state.init.maximumNumberOfInputChannels
	state.acq.acquiringChannel = [state.acq.acquiringChannel eval(['state.acq.acquiringChannel' num2str(i)])];
	state.acq.savingChannel	= [state.acq.savingChannel eval(['state.acq.savingChannel' num2str(i)])];
	state.acq.imagingChannel	= [state.acq.imagingChannel eval(['state.acq.imagingChannel' num2str(i)])];
	state.acq.maxImage = [state.acq.maxImage eval(['state.acq.maxImage' num2str(i)])];
end

deleteAIObjects;
setupAIObjects_Common;					% creates AI Objects
addChannelsToAIObjects;					% adds the appropriate channels to the AI Object
updateClim;
applyConfigurationSettings;
updateImageGUI;		% update LUT window

state.internal.channelChanged=0;
updateHeaderString('state.acq.numberOfChannelsAcquire')
updateHeaderString('state.acq.numberOfChannelsSave')
