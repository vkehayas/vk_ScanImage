function deleteAIObjects
% deletets old AI devices 
global state

% Written by:  Thomas Pologruto & Bernardo Sabatini
% Cold Spring Harbor Labs
% February 8, 2001

setStatusString('Resetting AI Devices....');
delete([state.init.ai state.init.aiF  state.init.aiPMTOffsets]); % Removes the old AI devices.

% Erase the previous channels in the state variable.
for channelCounter = 1:state.init.maximumNumberOfInputChannels
	eval(['state.init.inputChannel' num2str(channelCounter) ' = [];']);
	eval(['state.init.inputChannel' num2str(channelCounter) 'F = [];']);
	eval(['state.init.inputChannel' num2str(channelCounter) 'PMTOffsets = [];']);
end
setStatusString('');

