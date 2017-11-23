function selectAIChannels
%% function selectAIChannels
% Function that will evaluate the number of channels to be added to the anaolog input device based onm the number of channels set 
% acquire.
% Does this for the Focus and Acquisition Objects.
%
% Written by:  Thomas Pologruto and Bernardo Sabatini
% Cold Spring Harbor Labs
% January 30, 2001
%
%% NOTES
%   It seems that this function would lead to an error if a channel is specified to acquire, later de-specified, and then later yet added again. Check this. (Vijay Iyer, 2/15/08)
%%
%  Copyright - Howard Hughes Medical Institute/Cold Spring Harbor Laboratories 200
%
%% MODIFICATIONS
%   12/16/03 Tim O'Connor - Add names to the channels.
%   2/15/08 Vijay Iyer (VI021508A) - Set default voltage range (0-10V) for all added input channels. This is needed for DAQmx compatibility 
%   3/12/08 Vijay Iyer (VI031208A) - Set 'Coupling' property to DC explicitly, for DAQmx/NI-DAQ compatibility (defaults are DC in NI-DAQ and AC in DAQmx).
%   3/12/08 Vijay Iyer (VI031208B) - Fixed strange indexing error with PMT Offset channel state var names
%   8/14/08 Vijay Iyer (VI081408A) - Use common setAICoupling fucntion to implement VI031208A
%
%% ****************************************************
global state


	inputChannelCounter = 0;
	for channelCounter = 1:state.init.maximumNumberOfInputChannels
		channelOn = eval(['state.acq.acquiringChannel' num2str(channelCounter)]);
		if channelOn % if statemetnt only gets executed when there is a channel to acquire.
			inputChannelCounter = inputChannelCounter + 1;
			eval(strcat('state.init.inputChannel', num2str(channelCounter), ' = addchannel(state.init.ai, ', ...
                num2str(channelCounter - 1), ', ''Imaging-', num2str(channelCounter - 1), ''');'));            
			eval(strcat('state.init.inputChannel', num2str(channelCounter), 'F = addchannel(state.init.aiF, ', ...
                num2str(channelCounter - 1), ', ''Focusing-', num2str(channelCounter - 1), ''');'));
			eval(strcat('state.init.inputChannel', num2str(channelCounter), 'PMTOffsets = addchannel(state.init.aiPMTOffsets, ', ... %changed (channelCounter-1) to (channelCounter) -- VI031208B
                num2str(channelCounter - 1), ', ''PMTOffsets-', num2str(channelCounter - 1), ''');'));
		end
    end	
    
    %VI021508A -- Set default voltage range for all added input channels. This is needed for DAQmx compatibility
    AIObjects = {'state.init.ai' 'state.init.aiF' 'state.init.aiPMTOffsets'};
    ChanVarSuffixes = {'' 'F' 'PMTOffsets'};
    
    for i=1:length(AIObjects)
        chans = get(eval(AIObjects{i}),'Channel');
        if ~isempty(chans)
            hwchans = chans.HWChannel; 
            if ~iscell(hwchans) %deal with singleton case
                hwchans = {hwchans};
            end
            for j=1:length(hwchans)
                if (hwchans{j}+1)<1 || (hwchans{j}+1)>3 %This should never happen, but hey...
                    error('Unsupported channel index has been added to ScanImage AI object--only channels 1-3 supported');
                end                             

                chanobj = eval(['state.init.inputChannel' num2str(hwchans{j}+1) ChanVarSuffixes{i}]);
                chanprops = propinfo(chanobj);
                
                set(chanobj,'InputRange',[-10 10],'UnitsRange',[-10 10],'SensorRange',[-10 10]);
                
                %VI031208A -- Handle 'Coupling' property, dealing conservatively with stupid mis-casing by the DAQ toolbox
                setAICoupling(chanobj,'DC'); %VI081408A
            end
        end
    end
    
    