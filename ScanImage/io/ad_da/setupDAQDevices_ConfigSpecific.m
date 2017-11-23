function setupDAQDevices_ConfigSpecific
%% function setupDAQDevices_ConfigSpecific
% sets the configuration specific properties of AI and AO objects
% Written by: Thomas Pologruto & Bernardo Sabatini
% Cold Spring Harbor Labs
% 8-11-03
%
%% MODIFICATIONS
% Modified 11/24/03 Tim O'Connor - Start using the daqmanager object.
% Modified 02/15/08 Vijay Iyer - Use continous, rather than finite, acquisition in focus mode
%                                 since the AI object will be explicitly stopped anyway. This 
%                                 solves problem where moderately long finite acqs are disallowed in DAQmx. (VI021508A)
% Modified 02/21/08 Vijay Iyer - Don't set 'RepeatOutput' property for focus mode AO object here -- leave this to startFocus()
% Modified 03/08/08 Vijay Iyer - Use continuous, rather than finite, acquisition in grab mode as well (VI030808A)
%
%% *************************************************************************

global state gh

%Set number of focus frames to ensure proper time regardless of image size...
state.internal.numberOfFocusFrames=ceil(state.internal.focusTime/(state.acq.linesPerFrame*state.acq.msPerLine));

% GRAB output: set number of frames in GRAB output object to drive mirrors
set(state.init.ao2, 'RepeatOutput', (state.acq.numberOfFrames -1));

% FOCUS output: set number of frames in FOCUS output object to drive mirrors
%set(state.init.ao2F, 'RepeatOutput', (state.internal.numberOfFocusFrames -1)); %VI022108A

% 	if state.init.pockelsOn == 1			% and pockel cell, if on
% 		set(getfield(state.init,['ao'  num2str(state.init.eom.scanLaserBeam) 'F']), 'RepeatOutput', (state.internal.numberOfFocusFrames -1));
% 	end

selectNumberOfStripes;	% select number of stripes based on # channels and resolution

% GRAB acquisition: set up total acquisition duration
actualInputRate = get(state.init.ai, 'SampleRate');
state.internal.samplesPerLine = round(actualInputRate*state.acq.msPerLine);
state.internal.samplesPerFrame = state.internal.samplesPerLine*state.acq.linesPerFrame;

% GRAB acquisition: set up action function trigger (1 per stripe)
%set(state.init.ai, 'SamplesPerTrigger', state.internal.samplesPerFrame*state.acq.numberOfFrames); %VI030808A
set(state.init.ai,'SamplesPerTrigger',inf); %VI030808A
set(state.init.ai, 'SamplesAcquiredFcnCount', state.internal.samplesPerFrame/state.internal.numberOfStripes);

% FOCUS acquisition: set up total acquisition duration
actualInputRate = get(state.init.aiF, 'SampleRate');
state.internal.samplesPerLineF = round(actualInputRate*state.acq.msPerLine);
state.internal.samplesPerStripe = state.internal.samplesPerLineF*state.acq.linesPerFrame/state.internal.numberOfStripes;
set(state.init.aiF,'SamplesPerTrigger',inf); %VI02152008A
% 	set(state.init.aiF, 'SamplesPerTrigger', ...
% 		state.internal.samplesPerStripe*state.internal.numberOfStripes*state.internal.numberOfFocusFrames);

% FOCUS acquisition: set up action function trigger (1 per stripe)
set(state.init.aiF, 'SamplesAcquiredFcnCount', state.internal.samplesPerStripe);

% PMT Offset: set up total acquisition duration
actualInputRate = get(state.init.aiPMTOffsets, 'SampleRate');
totalSamplesInputOffsets = 50*state.acq.samplesAcquiredPerLine;		% acquire 50 lines of Data
set(state.init.aiPMTOffsets, 'SamplesPerTrigger', totalSamplesInputOffsets);
set(state.init.aiPMTOffsets, 'SamplesPerTrigger', totalSamplesInputOffsets);

% PMT Offset: set up trigger for end of PMT offset acquisition
set(state.init.aiPMTOffsets, 'SamplesAcquiredFcnCount', totalSamplesInputOffsets);