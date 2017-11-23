
%% function fig = startEomGui(varargin);
% Setup the environment for using Pockels cell(s).


%%  MODIFICATIONS
%    10/17/03 Tim O'Connor - Initialize some stuff in the PowerTransitions GUI, 
%                            for handling multiple sets of transitions.
%    11/24/03 Tim O'Connor - Start using the daqmanager object.
%    1/9/04 Tim O'Connor (TO1904a) - Initialize the powerBoxStepper GUI.
%    2/16/08 Vijay Iyer (VI021608A) - DAQmx compatibility change
%    2/16/08 Vijay Iyer (VI021608B) - Support DAQmx feature of allowing trigger input terminal to be set via standard.ini setting
%    2/18/08 Vijay Iyer (VI021808A) - When initial calibration is disabled, use a naive linear scale 
%    2/19/08 Vijay Iyer (VI021908A) - Handle Pockels Cell board clock synchronization per board, and using new version of syncNIDAQBoards() function (for DAQmx compatibility)
%    3/05/08 Vijay Iyer (VI030508A) - Pass named @daqmanager channel, rather than AO object, to syncNIDAQBoards(), which will then set its property(s) with the appropriate method
%    5/23/08 Vijay Iyer (VI052308A) - Allow Pockels Cell boardID to be specified in standard.ini using the DAQmx naming convention (i.e. 'Dev#')
%    8/14/08 Vijay Iyer (VI081408A) - Ensure that Photodiode input channels are DC coupled
%    8/15/08 Vijay Iyer (VI081508A) - Ensure voltage range is properly set for Photodiode input channels
%    10/17/08 Vijay Iyer (VI101708A) - Determine the number of 'beams' from the INI file, rather than having it separately specified
%    10/20/08 Vijay Iyer (VI102008A) - Eliminate use of scanLaserBeam state variable
%    10/30/08 Vijay Iyer (VI103008A) - Push Pockels calibration to scanimage.m (startup)
%    10/31/08 Vijay Iyer (VI103108A) - Make state.init.eom.ai a cell array
%    11/02/08 Vijay Iyer (vI110208A) - Don't set state.init.eom.started flag here anymore. This is now done in scanimage.m, after first calibration.
%    2/10/09 Vijay Iyer (VI021009A) - Allow beams to be named from the INI file
%
%%  Copyright - Howard Hughes Medical Institute/Cold Spring Harbor Laboratories 2003
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
function fig = startEomGui(varargin);
global state;
global gh;

%Setup the initial variables (these were originally in the standard.ini
%state.init.eom.changed(state.init.eom.scanLaserBeam) = 0; (%VI102008A: This is now set below)
state.init.eom.started = 0;
state.init.eom.lut = [];
state.init.eom.min = 1; % This will change once calibrated.

%Compute # of beams from other defined vars in standard.ini (VI101708A)
numPossiblePockels = 3;
validPockels = [];
for i=1:numPossiblePockels
    if isfield(state.init.eom,['pockelsBoardIndex' num2str(i)]);
        validPockels = [validPockels i];
    end
end     
if isempty(validPockels)
    error('Pockels cell is turned on in the INI file, but no Pockels Cell information is found there. Correct the INI file and restart ScanImage.');
elseif isempty(find(validPockels==1)) || ~isempty(find(diff(validPockels)~=1))
    error('Pockels cells must be enumerated from 1 upwards in the INI file, without skipping any numbers. Correct the INI file and restart ScanImage.');
else
    state.init.eom.numberOfBeams = max(validPockels);
end

state.init.eom.changed = zeros(1,state.init.eom.numberOfBeams); %VI102008A

%Set up the PowerTransitions GUI.
if state.init.eom.powerTransitions.syncToPhysiology
    children = get(gh.powerTransitions.Options, 'Children');
    index = getPullDownMenuIndex(gh.powerTransitions.Options, 'SyncToPhysiology');
    set(children(index), 'Checked', 'On');%Mark it as checked.
end
%This error condition shouldn't really occur, except in my testing.
if size(state.init.eom.powerTransitions.protocols, 1) < state.init.eom.powerTransitions.currentProtocol
    set(gh.powerTransitions.protocol, 'Value', 1);
end
%Hmm, I'm not sure if this is really necessary. It should initalize stuff...
updateGUIByGlobal('state.init.eom.powerTransitions.currentProtocol');

beams = cell(state.init.eom.numberOfBeams, 1);
[state.init.eom.maxPower, state.init.eom.maxLimit] = deal(zeros(1, state.init.eom.numberOfBeams));

% beamBoardIds = [];

for i = 1:state.init.eom.numberOfBeams
    % new stuff for making multiple beams...
    % ****************************************************************************
    % Configure analog output objects for pockels cell.
    % Pockels Cell Function Creation Acquisition (GRAB)
    % Uses the PCI MIO 16E 4 Board
    %***********************************************************************
    state.init.eom.pockelsCellNames{i} = strcat('PockelsCell-', num2str(i));
    %%%VI102008A: no longer needed
    %     if i == state.init.eom.scanLaserBeam
    %         state.init.eom.scanLaserName = state.init.eom.pockelsCellNames{i};
    %     end
    %%%%%%%%%%%%%%%%%%%%%%%%
    
    %Determine pockelsBoardID to pass to daqmanager channel-creation function (VI052308A)
    pockelsBoardID = getfield(state.init.eom, ['pockelsBoardIndex' num2str(i)]);
    if strcmpi(whichNIDriver,'DAQmx') 
        if ischar(pockelsBoardID) %convert 'Dev#' specified board ID into integer
           pockelsBoardID = regexpi(pockelsBoardID,'Dev(\d+)','tokens','once');
           
           if isempty(pockelsBoardID)
               error(['Board ID specified in state.init.eom.pockelsBoardIndex' num2str(i) ' is not of a recognized format (i.e ''Dev##''']);
           else
               pockelsBoardID = str2num(pockelsBoardID{1});
           end           
        end            
    end      
        
    nameOutputChannel(state.acq.dm, pockelsBoardID, ... %, getfield(state.init.eom, ['pockelsBoardIndex' num2str(i)]), ... (VI052308A)
        getfield(state.init.eom, ['pockelsChannelIndex'  num2str(i)]), ...
        state.init.eom.pockelsCellNames{i});

    enableChannel(state.acq.dm, state.init.eom.pockelsCellNames{i});

    setAOProperty(state.acq.dm, state.init.eom.pockelsCellNames{i}, 'TriggerType', 'HWDigital');
    setAOProperty(state.acq.dm, state.init.eom.pockelsCellNames{i}, 'SampleRate', state.acq.outputRate);
    if strcmpi(whichNIDriver,'NI-DAQ') %VI021608A
        setAOProperty(state.acq.dm, state.init.eom.pockelsCellNames{i}, 'TransferMode', state.init.transferMode);
    else %VI021608B
        setAOProperty(state.acq.dm, state.init.eom.pockelsCellNames{i},'HwDigitalTriggerSource',state.init.triggerInputTerminal);
    end
%     ao = analogoutput('nidaq', getfield(state.init.eom, ['pockelsBoardIndex' num2str(i)])); 
%     eval(sprintf('state.init.ao%s = ao;', num2str(outputId)));
%     
%     addchannel(getfield(state.init,['ao'  num2str(outputId)]), ...
%         getfield(state.init.eom, ['pockelsChannelIndex'  num2str(i)]), strcat('PockelsCell_', num2str(i)));
%     
%     set(getfield(state.init, ['ao'  num2str(outputId)]), 'SampleRate', state.acq.outputRate, 'TriggerType', 'HWDigital');
    
%     if isempty(beamBoardIds) | ~find(beamBoardIds == getfield(state.init,['ao'  num2str(i)]))
%         beamBoardIds(i) = getfield(state.init.eom, [''  num2str(i)]);
%     end
    %****************************************************************************
    % Pockels Cell Function Creation (FOCUS)
    % Uses the PCI MIO 16E 4 Board
    %****************************************************************************
%     if i == state.init.eom.scanLaserBeam
%         
%         ao = analogoutput('nidaq', getfield(state.init.eom, ['pockelsBoardIndex' num2str(i)]));
%         eval(sprintf('state.init.ao%sF = ao;', num2str(outputId)));
% 
%         eval(sprintf('addchannel(state.init.ao%sF, %s, ''PockelsCell_%s_Focus'');', num2str(outputId), ...
%             num2str(getfield(state.init.eom, ['pockelsChannelIndex'  num2str(i)])), num2str(i)) );
%         
%         set(getfield(state.init, ['ao'  num2str(i) 'F']), 'SampleRate', state.acq.outputRate,'TriggerType', 'HWDigital');
%     end
    
    %beams(i) = cellstr(sprintf('Beam%s', num2str(i))); %VI021009A
    beams{i} = state.init.eom.(['beamName' num2str(i)]); %VI021009A
    state.init.eom.maxPower(i) = getfield(state.init.eom, ['maxPower' num2str(i)]);
    state.init.eom.maxLimit(i) = getfield(state.init.eom, ['maxLimit' num2str(i)]);
    
    %Create photodiode 
    pdiodeBoard = getfield(state.init.eom, ['photodiodeInputBoardId', num2str(i)]);
    if ~isempty(pdiodeBoard)
        state.init.eom.ai{i} = analoginput('nidaq', getfield(state.init.eom, ['photodiodeInputBoardId' num2str(i)])); %VI103108a
        chanobj = addchannel(state.init.eom.ai{i}, getfield(state.init.eom, ['photodiodeInputChannel' num2str(i)]), strcat('PockelsCell-', num2str(i))); %VI081408A, VI103108A
        setAICoupling(chanobj,'DC'); %VI081408A
        set(chanobj,'InputRange',[-10 10], 'UnitsRange', [-10 10], 'SensorRange', [-10 10]); %VI081508A
    else %VI103108A
        state.init.eom.ai{i} = [];
    end
    
    %%%VI103008A: Push to scanimage.m%%%%%%%%%
    %     % Setup AI channels for pockels cell.....
    %     if isempty(state.init.eom.lut) | size(state.init.eom.lut, 1) < i
    %         if state.internal.eom.calibrateOnStartup
    %             %Do the initial calibration
    % %             try
    %                 calibrateEom(i);
    % %             catch
    % %                 beep;
    % %                 fprintf(2, 'Can not calibrate pockels cell #%s: %s\n', num2str(i), lasterr);
    % %                 fprintf(2, '  Try checking:\n   1) Power to cell.\n   2) Connections.\n   3) The ini file settings.\n\n');
    % %                 state.init.eom.lut(i, :) = zeros(100, 1);
    % %
    % %                 %Put in some dummy values. Is this a bad idea?
    % %                 state.init.eom.changed(i) = 0;
    % %                 state.init.eom.maxPhotodiodeVoltage(i) = 5;
    % %                 state.init.eom.min(i) = 1;
    % %             end
    %         else
    %             %state.init.eom.lut(i, :) = zeros(100, 1);
    %             naiveEOMCalibrate(i)%VI021808A
    %         end
    %     end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    state.init.eom.powerTransitions.transitionCount(i) = 0;
    state.init.eom.constrainBoxToLine(i) = 0;
    
    %Sync Pockels Cell board(s) to the master clock    
    %syncNIDAQBoards(state.init.ao2, getAO(state.acq.dm,state.init.eom.pockelsCellNames{i})); %VI021908A VI022608A 
    syncNIDAQBoards(state.init.ao2, state.init.eom.pockelsCellNames{i}); %VI030508A
end


%REMOVED - VI021908A
% pockelsAO = getAO(state.acq.dm, 'PockelsCell-1');
% if ~isempty(pockelsAO)
%     syncNIDAQBoards(state.init.ao2, pockelsAO);
% end
%END VI021908A

% for i = 1:length(beamBoardIds)
%     syncNIDAQBoards(state.init.ao2, getfield(state.init,['ao'  beamBoardIds(i)]);
% end

%state.init.eom.started = 1; %VI110208A

set(gh.powerControl.beamMenu, 'String', beams);
set(gh.powerTransitions.beamMenu, 'String', beams);
set(gh.powerControl.beamMenuSlider, 'Min', 1);
set(gh.powerControl.beamMenuSlider, 'Max', state.init.eom.numberOfBeams + 1);
step = 1 / state.init.eom.numberOfBeams;
set(gh.powerControl.beamMenuSlider, 'SliderStep', [step step]);
set(gh.powerControl.beamMenuSlider, 'Val', 1);

%TO1904a - This is very similar to setting up the beamMenu and beamMenuSlider (above).
set(gh.powerControl.beamMenu, 'String', beams);
set(gh.powerBoxStepper.beamMenu, 'String', beams);
set(gh.powerBoxStepper.beamSlider, 'Min', 1);
set(gh.powerBoxStepper.beamSlider, 'Max', state.init.eom.numberOfBeams + 1);
set(gh.powerBoxStepper.beamSlider, 'SliderStep', [step step]);%Step is cached, from above.
set(gh.powerBoxStepper.beamSlider, 'Val', 1);
state.init.eom.powerBoxStepper.pbsArray = zeros(state.init.eom.numberOfBeams, 4);%0's to start.

%TO22704a - New tool.
set(gh.uncagingMapper.beamMenu, 'String', beams);
set(gh.uncagingMapper.orientationMenu, 'String', {'Top-Left', 'Top-Right', 'Center', 'Bottom-Left', 'Bottom-Right'});
%%%VI102008A%%%%%%%%%%%%%%%%
updateGUIByGlobal('gh.uncagingMapper.beam','Value',min(1,state.init.eom.numberOfBeams-1),'Callback',1);
% for i = 1 : state.init.eom.numberOfBeams
%     if i ~= state.init.eom.scanLaserBeam
%         updateGUIByGlobal('gh.uncagingMapper.beam', 'Value', i, 'Callback', 1);
%         break;
%     end
% end
%%%%%%%%%%%%%%%%%%
state.init.eom.uncagingMapper.enabled = zeros(state.init.eom.numberOfBeams, 1);
if isempty(state.init.eom.uncagingMapper.pixels)
    state.init.eom.uncagingMapper.pixels = -1 * ones(state.init.eom.numberOfBeams, 1, 4);
elseif size(state.init.eom.uncagingMapper.pixels, 1) < state.init.eom.numberOfBeams
    state.init.eom.uncagingMapper.pixels(state.init.eom.numberOfBeams, :, 4) = -1;
end

updateGUIByGlobal('state.init.eom.uncagingMapper.orientation', 'Value', 3, 'Callback', 1);%Center.
updateGUIByGlobal('state.init.eom.uncagingMapper.beam', 'Value', 2, 'Callback', 1);%Center.

%VI101908A: Initialize ROI Cycle Editor, as done with PowerStepper and other tools above 
set(gh.roiCycleGUI.pmBeamMenu, 'String', beams);


%Initialize Laser Function Panel
try
    feval(state.init.eom.laserFunctionPanel.updateDisplay);
catch
    warning('Failed to execute: %s\n  %s', func2str(state.init.eom.laserFunctionPanel.updateDisplay), lasterr);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%55
%Initialize arrays of all kinds...
% TPMODBox
for beamCounter=1:state.init.eom.numberOfBeams
    state.init.eom.showBoxArray=[state.init.eom.showBoxArray state.init.eom.showBox];
    state.init.eom.boxPowerArray=[state.init.eom.boxPowerArray state.init.eom.boxPower];
    state.init.eom.startFrameArray=[state.init.eom.startFrameArray state.init.eom.startFrame];
    state.init.eom.endFrameArray=[state.init.eom.endFrameArray state.init.eom.endFrame]; 
end
powerControl('beamMenu_Callback',gh.powerControl.beamMenu);
state.init.eom.boxcolors=hsv(state.init.eom.numberOfBeams);

if length(state.init.eom.showBoxArray) < state.init.eom.numberOfBeams
    state.init.eom.showBoxArray(state.init.eom.numberOfBeams) = 0;
end
if length(state.init.eom.boxPowerArray) < state.init.eom.numberOfBeams
    state.init.eom.boxPowerArray(state.init.eom.numberOfBeams) = 0;
end
if length(state.init.eom.startFrameArray) < state.init.eom.numberOfBeams
    state.init.eom.startFrameArray(state.init.eom.numberOfBeams) = 0;
end
if length(state.init.eom.endFrameArray) < state.init.eom.numberOfBeams
    state.init.eom.endFrameArray(state.init.eom.numberOfBeams) = 0;
end

%Make sure everything plays nice.
ensureEomGuiStates;