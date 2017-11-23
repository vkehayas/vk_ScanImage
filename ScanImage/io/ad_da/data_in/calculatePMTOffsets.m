function calculatePMTOffsets(aiPMTOffsets, SamplesAcquired)
global state

% This function is the action function called for the aiPMTOffsets DAQ object;
% It will calcualte the average signal on all the channels present after
% a 10 lines of data and will bin it like in the acquisition modes.
%
% Written By: Thomas Pologruto, Bernardo Sabatini
% Cold Spring Harbor Labs
% February 9, 2001. 

try
	tempData = getdata(state.init.aiPMTOffsets, 'native');
	tempData = addForPmtOffsets(tempData, state.acq.binFactor); % Adds just like acquisition
	inputChannelCounter = 0;
	for channelCounter = 1:state.init.maximumNumberOfInputChannels
		if getfield(state.acq, ['acquiringChannel' num2str(channelCounter)]) % if statement only gets executed when there is a channel to acquire.
			inputChannelCounter = inputChannelCounter + 1;

			eval(['state.acq.pmtOffsetChannel' num2str(channelCounter) ' = mean(tempData(:,inputChannelCounter));']);
			eval(['state.acq.pmtOffsetStdDevChannel' num2str(channelCounter) ' = std(tempData(:,inputChannelCounter));']);
%			eval(['state.acq.pmtOffsetMeanVarChannel' num2str(channelCounter) ...
%					' = state.acq.pmtOffsetChannel' num2str(channelCounter) '/state.acq.pmtOffsetStdDevChannel' num2str(channelCounter) ';']);
			updateHeaderString(['state.acq.pmtOffsetChannel' num2str(channelCounter)]);
			updateHeaderString(['state.acq.pmtOffsetStdDevChannel' num2str(channelCounter)]);
		end
	end
catch
	setStatusString('Error in pmt offsets');
	disp('calculatePMTOffsets: caught error');
end
