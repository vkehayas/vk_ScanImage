%% MODIFICATIONS
%   2/15/08 Vijay Iyer (VI021508A) - For DAQmx/Trad NI-DAQ compatibility, explicitly set default voltage ranges for AO channels (inconsistency beteween versions) %VI021508A
%   2/16/08 Vijay Iyer (VI021608A) - For DAQmx mode, set trigger source to that indicated in standard.ini
%   4/29/08 Vijay Iyer (VI042908A) - Increase the buffer size for the mirror AO object
%   7/07/08 Vijay Ieyr (VI070708A) - Allow shutter line board index to be specified in standard.ini, rather than assuming it is the same as trigger board index
%   7/08/08 Vijay Iyer (VI070808A) - Create new DIO object for shutter control only if a different board is used
%   8/12/08 Vijay Iyer (VI081208A) - Don't use manual BufferingConfig
%   3/11/09 Vijay Iyer (VI031109A) - Use new state.shutter.shutterOn flag
%
%% ****************************************
function setupAOObjects_Common
global state gh

% setups components of AO Objects that are config independent


%******************************************************************************
% Mirror Data Output Acquisition (GRAB)
% Uses the PCI 6110E Board
% Setting up analog output for the NI Board and adding 2 channels to it.  
% Setting up Mirror controls.
% Constructing appropriate output data.
%*******************************************************************************

state.init.ao2 = analogoutput('nidaq',state.init.mirrorOutputBoardIndex);			% 2 is the ID for the 6110E Board
state.init.XMirrorChannel = addchannel(state.init.ao2, state.init.XMirrorChannelIndex, 'X-Mirror');
state.init.YMirrorChannel = addchannel(state.init.ao2, state.init.YMirrorChannelIndex, 'Y-Mirror');
set(state.init.ao2, 'SampleRate', state.acq.outputRate);
set(state.init.ao2, 'TriggerType', 'HwDigital');					% 6110E NI Board Set to Trigger PFI6
set(state.init.XMirrorChannel,'OutputRange',[-10 10],'UnitsRange',[-10 10]); %VI021508A
set(state.init.YMirrorChannel,'OutputRange',[-10 10],'UnitsRange',[-10 10]); %VI021508A
if strcmpi(whichNIDriver,'DAQmx') %VI021608A
    set(state.init.ao2,'HWDigitalTriggerSource',state.init.triggerInputTerminal);
end
%set(state.init.ao2,'BufferingConfig',[2^18 round(2*state.init.outputChanBufferTime*state.acq.outputRate/2^18)]); %VI042908A

%******************************************************************************
% Mirror Data Output Acquisition (FOCUS)
% Uses the PCI 6110E Board
% Setting up analog output for the NI Board and adding 2 channels to it.  
% Setting up Mirror controls.
% Constructing appropriate output data.
%*******************************************************************************

state.init.ao2F = analogoutput('nidaq',state.init.mirrorOutputBoardIndex);			% 2 is the ID for the 6110E Board
state.init.XMirrorChannelF = addchannel(state.init.ao2F, state.init.XMirrorChannelIndex, 'X-Mirror-F');
state.init.YMirrorChannelF = addchannel(state.init.ao2F, state.init.YMirrorChannelIndex, 'Y-Mirror-F');
set(state.init.ao2F, 'SampleRate', state.acq.outputRate);
set(state.init.ao2F, 'TriggerType', 'HwDigital');					% 6110E NI Board Set to Trigger PFI6
set(state.init.XMirrorChannelF,'OutputRange',[-10 10],'UnitsRange',[-10 10]); %VI021508A
set(state.init.YMirrorChannelF,'OutputRange',[-10 10],'UnitsRange',[-10 10]); %VI021508A
if strcmpi(whichNIDriver,'DAQmx') %VI021608A
    set(state.init.ao2F,'HWDigitalTriggerSource',state.init.triggerInputTerminal);
end

%******************************************************************************
% Laser Parking Mirror Data Output Acquisition (GRAB and FOCUS)
% Uses the PCI 6110E Board
% Setting up analog output for the NI Board and adding 2 channels to it.  
% Setting up Mirror controls.
% Constructing appropriate output data.
%*******************************************************************************

state.init.aoPark = analogoutput('nidaq', state.init.mirrorOutputBoardIndex);			% 2 is the ID for the 6110E Board
state.init.XMirrorChannelPark = addchannel(state.init.aoPark, state.init.XMirrorChannelIndex, 'X-Mirror-Park');
state.init.YMirrorChannelPark = addchannel(state.init.aoPark, state.init.YMirrorChannelIndex, 'Y-Mirror-Park');
%%%%%%%%(VI052008) I don't think the following is necessary, but left in anyway*********************
set(state.init.aoPark, 'SampleRate', state.acq.outputRate);
set(state.init.aoPark, 'TriggerType', 'Immediate');					% 6110E NI Board Set to Trigger PFI6
set(state.init.XMirrorChannelPark,'OutputRange',[-10 10],'UnitsRange',[-10 10]); %VI021508A
set(state.init.YMirrorChannelPark,'OutputRange',[-10 10],'UnitsRange',[-10 10]); %VI021508A
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%***********************************************************************************************************************
% Simultaneous DIO Triggering of the AI and AO
% Digital Triggering on the 6110E Board using DIO1 into PFI0/Trigger (Input) and PFI6 (Output).
% Falling Edge Trigger (Go from 1 to 0) to trigger
%***********************************************************************************************************************

state.init.dio = digitalio('nidaq', state.init.triggerBoardIndex);
state.init.triggerLine = addline(state.init.dio, state.init.triggerLineIndex, 'out', 'TriggerOutput');

%***********************************************************************************************************************
% DIO Control of Shutter Opening and Closing adn Pockels cell firing.
%***********************************************************************************************************************
if state.shutter.shutterOn %VI031109A
    %%%Create new dio object for shutter only if a separate board is used (VI070808A)
    if ischar(state.shutter.shutterBoardIndex) && strcmpi(state.shutter.shutterBoardIndex,state.init.triggerBoardIndex)
        state.shutter.shutterDIO = state.init.dio;
    elseif isnumeric(state.shutter.shutterBoardIndex) && state.shutter.shutterBoardInces == state.init.triggerBoardIndex
        state.shutter.shutterDIO = state.init.dio;
    else
        state.shutter.shutterDIO = digitalio('nidaq',state.shutter.shutterBoardIndex); %VI070708A
    end
    %%%%%%%%
    state.shutter.shutterLine = addline(state.shutter.shutterDIO, state.shutter.shutterLineIndex, 'out', 'ShutterOutput'); %VI070708A
    closeShutter;
end

if state.shutter.epiShutterLineIndex >= 0 %This is never true at the moment -- Vijay Iyer 3/11/09
    state.shutter.epiShutterLine = addline(state.init.dio, state.shutter.epiShutterLineIndex, 'out', 'epiShutterOutput');
    closeEpiShutter;
else
    state.shutter.epiShutterLine = [];
end	
%TPMODPockels
% 	if state.init.pockelsOn == 1
% 		state.init.pockelsLine = addline(state.init.dio, state.init.pockelsLineIndex, 'out');
% 	end

start(state.init.dio);