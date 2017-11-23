function setupAIObjects_Common
%% function setupAIObjects_Common
%  Setup the global analog-input objects.
%

%%  MODFIFICATIONS
%   12/16/03 Tim O'Connor - Add names to channels.
%   2/07/08 Vijay Iyer - Use setAITriggerType utility func, which allows both Trad NI-DAQ and DAQmx to be supported  %VI020708A
%   2/15/08 Vijay Iyer (VI021508A) - For DAQmx/Trad NI-DAQ compatibility, explicitly set default voltage ranges for AO channels (incosnsistency between drivers) %VI021508A
%   2/16/08 Vijay Iyer (VI021608A) - For DAQmx mode, set trigger source to that indicated in standard.ini
%   2/28/08 Vijay Iyer (VI022808A) - Add bit depth extraction from acquisition board
%   2/28/08 Vijay Iyer (VI022808B) - Add voltage-range handling (very limited for now)
%   7/1/09 Vijay Iyer (VI070109A) - Bind a StartFcn callback to the GRAB/LOOP AI object
%
%%
%  Copyright - Howard Hughes Medical Institute/Cold Spring Harbor Laboratories 2002

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global state gh
% setups components of AI Objects that are config independent

	%***********************************************************************************************************************
	% Data Acquisition
	% Uses the PCI 6110E Board
	% Acquiring Data from PMT for GRAB Mode.
	%**********************************************************************************************************************

	state.init.ai = analoginput('nidaq',state.init.acquisitionBoardIndex);
%	set(state.init.ai, 'TriggerType', 'HwDigital');										% 6110E NI Board Set to Trigger PFI0
    setAITriggerType(state.init.ai, 'HWDigital'); %VI020708A
	set(state.init.ai, 'SampleRate', state.acq.inputRate);
	set(state.init.ai, 'SamplesAcquiredFcn', @makeFrameByStripes, 'TriggerFcn',@acquisitionStartedFcn); %VI070109A
    if strcmpi(whichNIDriver,'DAQmx') %VI021608A
        set(state.init.ai,'HWDigitalTriggerSource',state.init.triggerInputTerminal);
    end
    
	%***********************************************************************************************************************
	% Data Acquisition (FOCUS)
	% Uses the PCI 6110E Board
	% Acquiring Data from PMT for Focus Mode.
	%**********************************************************************************************************************

	state.init.aiF = analoginput('nidaq',state.init.acquisitionBoardIndex);
%	set(state.init.aiF, 'TriggerType', 'HwDigital');										% 6110E NI Board Set to Trigger PFI0
    setAITriggerType(state.init.aiF,'HWDigital'); %VI020708A
	set(state.init.aiF, 'SampleRate', state.acq.inputRate);
    if strcmpi(whichNIDriver,'DAQmx') %VI021608A
        set(state.init.aiF,'HWDigitalTriggerSource',state.init.triggerInputTerminal);
    end

	% Action function Definitions
	set(state.init.aiF, 'SamplesAcquiredFcn', {'makeStripe'});


	%***********************************************************************************************************************
	% PMT Offsets
	% Uses the PCI 6110E Board
	% Acquiring Data from PMT such that state.acq.pmtOffsetChannel(X) are updated as 
	% the average shutterclosed signal on the acquisition lines.
	%**********************************************************************************************************************

	state.init.aiPMTOffsets = analoginput('nidaq', state.init.acquisitionBoardIndex);
	set(state.init.aiPMTOffsets, 'TriggerType', 'Immediate');										% 6110E NI Board Set to Trigger PFI0
	set(state.init.aiPMTOffsets, 'SampleRate', state.acq.inputRate);

	% Action function Definitions
	set(state.init.aiPMTOffsets, 'SamplesAcquiredFcn', {'calculatePMTOffsets'});
    
    %***********************************************************************************************************************
	% Bit Depth/Voltage Range Handling (VI022808A, VI022808B)
    % Extract bit depth for input channels on acquisition board
    % Ensure that voltage range is properly set
	%**********************************************************************************************************************
    info = daqhwinfo(state.init.aiF);
    state.acq.inputBitDepth = info.Bits;    
    state.acq.inputVoltageRange = 10; %Hard-code for now, overriding what's found in standard.ini. In future, the standard.ini value could be applied to the acq board settings here, and verified.

	%***********************************************************************************************************************
	% Zoom setting
	% Uses the MIO16E Board
	% Acquiring Data from PMT such that state.acq.pmtOffsetChannel(X) are updated as 
	% the average shutterclosed signal on the acquisition lines.
	%**********************************************************************************************************************

	if state.init.autoReadZoom
		state.init.aiZoom = analoginput('nidaq', state.init.zoomBoardIndex);
		set(state.init.aiZoom, 'TriggerType', 'Immediate');										% 6110E NI Board Set to Trigger PFI0
		set(state.init.aiZoom, 'SampleRate', 10000);				% 10 kHz sampling
		state.init.zoomChannel  = addchannel(state.init.aiZoom, state.init.zoomChannelIndex, 'Zoom');
        set(state.init.zoomChannel,'InputRange',[-10 10],'SensorRange',[-10 10],'UnitsRange',[-10 10]); %VI021508A
		
		% Action function Definitions
		set(state.init.aiZoom, 'SamplesAcquiredFcn', {'calculateZoom'});
		set(state.init.aiZoom, 'SamplesAcquiredFcnCount', 100); 
		set(state.init.aiZoom, 'SamplesPerTrigger', 100);		% 10 samples = 1 ms
	end

