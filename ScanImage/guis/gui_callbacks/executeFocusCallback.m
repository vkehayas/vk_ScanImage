function executeFocusCallback(h)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% executeFocusCallback(h).m******
% In Main Controls, This function is executed when the Focus or Abort button is pressed.
% It will on abort requeu the data appropriate for the configuration.
%
%% MODIFICATIONS
% 	TPMOD_1: Modified 12/31/03 Tom Pologruto - Turns off Physiology if desired before
% 	focusing so it does not trigeer an acquisition.
% 	TPMOD_2: Modified 1/5/04 Tom Pologruto - Checks flag to see if Focus
% 	shoul dbe forced to be in Frame Scan Mode
%   TPMOD_3: Modified 1/5/04 Tom Pologruto - Checks flag to see if Focus
% 	was channged to Frame Scan and should be changed back.
%   TO1904c Tim O'Connor 1/9/04 - Focus mode gets stuck in linescan when
%   toggling linescan while forceFocusFrameScan is enabled.
%   VI021908A Vijay Iyer 2/19/08 - Issue DIO trigger conditionally
%   VI041308A Vijay Iyer 4/13/08 - Don't issue DIO trigger conditionally for Focus acqs--only for Grab acqs
%   VI100608A - Vijay Iyer 10/06/08: Use MP285Clear() instead of MP285Flush()
%   VI101208A - Vijay Iyer 10/12/08: Abort FOCUS start if motor error occurs in process
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global state gh
val=get(h, 'String');

if strcmp(val, 'FOCUS')
	
	if strcmp(get(gh.basicConfigurationGUI.figure1, 'Visible'), 'on')
		beep;
		setStatusString('Close ConfigurationGUI');
		return
	end
	
	% start TPMOD_1 12/31/03
	if state.init.syncToPhysiology 
		if isfield(gh,'mainPhysControls') & isfield(state,'physiology') & ...
				isfield(state.physiology,'mainPhysControls') 
			physstring=get(gh.mainPhysControls.startPhysiology,'String');
			if strcmpi(physstring,'Stop')
				startPhysiologyCallback(gh.mainPhysControls.startPhysiology);
				state.internal.stoppedPhysiology=1; 
			end
		end
	end
	% end TPMOD_1 12/31/03
	
	% start TPMOD_2 1/5/04
	if state.internal.forceFocusFrameScan
        %TO1904c
        set(gh.mainControls.linescan, 'Enable', 'Off');
        
        if state.acq.linescan
            state.acq.linescan=0;
            updateGUIByGlobal('state.acq.linescan');
            state.acq.scanAmplitudeY= state.internal.oldAmplitude;
            updateGUIByGlobal('state.acq.scanAmplitudeY');
            setupAOData;
            flushAOData;
            state.internal.forceFocusFrameScanDone=1;
        end
	end
	% end TPMOD_2 1/5/04
	
	state.internal.forceFirst=1;
	
	setStatusString('Focusing...');
	set(h, 'String', 'ABORT');
	
	set(gh.mainControls.grabOneButton, 'Visible', 'Off');
	set(gh.mainControls.startLoopButton, 'Visible', 'Off');
	if state.internal.looping
		state.internal.cyclePaused=1;
	end
	turnOffMenusFocus;
	if state.init.autoReadPMTOffsets
		done=startPMTOffsets;
	end
	%TPMODPockels
	if state.internal.updatedZoomOrRot | any(state.init.eom.changed) % need to reput the data with the approprite rotation and zoom.
		state.acq.mirrorDataOutput = rotateAndShiftMirrorData(1/state.acq.zoomFactor*state.acq.mirrorDataOutputOrg);
		flushAOData;
		state.internal.updatedZoomOrRot=0;
	end
	
	MP285Clear; 
	resetCounters;
	
	state.internal.abortActionFunctions=0;
	startFocus;
	updateCurrentROI;   %TPMOD 6/18/03
	openShutter;
	state.internal.forceFirst=1;

% NOTE: For now, just set a global variable called "debugFlag" to 1, to
% enable plotting, don't comment/uncomment this stuff anymore.
% % daqdata = getDaqData(state.acq.dm, 'PockelsCell-2');
% % domain = 1000 .* (1:length(daqdata)) ./ getAOProperty(state.acq.dm, 'PockelsCell-2', 'SampleRate');
% % figure;plot(domain, daqdata);
% % title('Actual Pockels Cell Signal at time of FOCUS');
% % xlabel('Time [ms]');
% % ylabel('Voltage [V]');

	%dioTriggerConditional; %VI021908A
    dioTrigger; %VI041308A

	%*****************************************************
	%  Uncomment for benchmarking.....
	%     state.time=[];
	%     state.testtime=clock;
	%*******************************************************
	
elseif strcmp(val, 'ABORT')

	state.internal.abortActionFunctions=1;
	setStatusString('Aborting Focus...');
	closeShutter;
	set(h, 'Enable', 'off');
	stopFocus;
	MP285Clear;
	
	scim_parkLaser;
	flushAOData;
	
	set(h, 'String', 'FOCUS');
	set(h, 'Enable', 'on');
	set(gh.mainControls.startLoopButton, 'Visible', 'On');
    
    % start TPMOD_3 1/5/04
	if state.internal.forceFocusFrameScan 
        %TO1904c
        set(gh.mainControls.linescan, 'Enable', 'On');
        
        if state.internal.forceFocusFrameScanDone
            state.internal.forceFocusFrameScanDone=0;
            state.acq.linescan=1;
            updateGUIByGlobal('state.acq.linescan');
            state.acq.scanAmplitudeY = 0;
            updateGUIByGlobal('state.acq.scanAmplitudeY');
            setupAOData;
            flushAOData;
        end
	end
	% end TPMOD_3 1/5/04
    
	if ~state.internal.looping
		set(gh.mainControls.grabOneButton, 'Visible', 'On');
		turnOnMenusFocus;
	else
		MP285Clear; %VI100608A
		turnOffMenusFocus;
		
		resetCounters;
		state.internal.abortActionFunctions=0;
		setStatusString('Resuming cycle...');
		
		stopFocus;
		updateGUIByGlobal('state.internal.frameCounter');
		updateGUIByGlobal('state.internal.zSliceCounter');
		
		state.internal.abort=0;
		state.internal.currentMode=3;
		
		mainLoop;
	end
	setStatusString('');
end


