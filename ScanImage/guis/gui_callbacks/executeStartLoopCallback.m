%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% MODIFICATIONS
%   Tim O'Connor 12/16/03 :: Update the Pockels cell data, for multiple beams.
%   TO12204b - Tim O'Connor 1/22/04: Mark beams as changed so the data is properly regenerated.
%   TO12204c - Tim O'Connor 1/22/04: Remove extra call to repmat.
%   TO2904a - Tim O'Connor 2/9/04: Don't access Pockels cell stuff when there's no Pockels cell.
%   VI082208A - Vijay Iyer 8/22/08: Eliminate superfluous overwrite warning message that's based on incorrect idea of checkFileBeforeSave() return value
%   VI100608A - Vijay Iyer 10/06/08: Use MP285Clear() instead of MP285Flush()
%   VI101008A - Vijay Iyer 10/10/08: Handle case where there's an error going home during an abort
%   VI101208A - Vijay Iyer 10/12/08: Abort LOOP start if motor error occurs in process
%   VI101208B - Vijay Iyer 10/12/08: Abort GRAB if error occurs during pre-GRAB motor operations 
%   VI102909A - Vijay Iyer 10/29/09: Removed reference to otherwise unused state variable.
%
%% CREDITS 
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute
%% *****************************************************************************
function executeStartLoopCallback(h)
global state gh;

state.internal.whatToDo = 3;

val = get(h, 'String');
state.internal.cyclePaused = 0;

if strcmp(val, 'LOOP')
    % start TPMOD 12/31/03
    if state.init.syncToPhysiology 
        if isfield(gh,'mainPhysControls') & isfield(state,'physiology') & ...
                isfield(state.physiology,'mainPhysControls') 
            
            physstring=get(gh.mainPhysControls.startPhysiology,'String');
            if state.internal.stoppedPhysiology==1
                startPhysiologyCallback(gh.mainPhysControls.startPhysiology);
                state.internal.stoppedPhysiology=0;
            end
        end
    end

    % end TPMOD 12/31/03
	if strcmp(get(gh.basicConfigurationGUI.figure1, 'Visible'), 'on')
		beep;
		setStatusString('Close ConfigurationGUI');
		return
	end
    if state.init.syncToPhysiology
        if isfield(state,'physiology') & isfield(state.physiology,'mainPhysControls') & isfield(state.physiology.mainPhysControls,'acqNumber')
            maxVal=max(state.physiology.mainPhysControls.acqNumber, state.files.fileCounter);
            state.physiology.mainPhysControls.acqNumber = maxVal;
            state.files.fileCounter = maxVal;
            updateGUIByGlobal('state.physiology.mainPhysControls.acqNumber');
            updateGUIByGlobal('state.files.fileCounter');
        end
    end
	if ~savingInfoIsOK;
		return
	end

	% Check if file exisits
	overwrite = checkFileBeforeSave([state.files.fullFileName '.tif']);
	if isempty(overwrite)
		return;
    %%%%%% VI082208B%%%%%%%%%%
    %elseif ~overwrite
    %      %TPMOD 2/6/02
    %      if state.files.autoSave || state.acq.saveDuringAcquisition
    %	    disp('Overwriting Data!!');
    %      end
    %%%%%%%%%%%%%%%%%%%%%%%%%%
	end

    %Update the Pockels cell signal(s) if necessary. 12/16/03
    %Only do this if the pockels cell code is active. - TO2904a
    if state.init.eom.pockelsOn
        for beamCounter = 1 : state.init.eom.numberOfBeams
            if state.init.eom.changed(beamCounter)
                putDaqData(state.acq.dm, state.init.eom.pockelsCellNames{beamCounter}, ...
                    makePockelsCellDataOutput(beamCounter) ...
                    );%TO12204c
                %                 repmat(makePockelsCellDataOutput(beamCounter), [state.acq.numberOfFrames 1]) ...
                state.init.eom.changed(beamCounter) = 0;
            end
        end
    end

    set(h, 'String', 'ABORT'); %VI101208A: Do this just before motor ops...so abortCurrent() will work properly if needed

	MP285Clear %VI100608A
    
	set(gh.mainControls.grabOneButton, 'Visible', 'Off');
	turnOffMenus;

	if state.internal.configurationChanged == 1
		closeConfigurationGUI;
	end

	resetCounters;
	state.internal.abortActionFunctions = 0;

	setStatusString('Starting cycle...');
	
	stopFocus;
	
	updateGUIByGlobal('state.internal.frameCounter');
	updateGUIByGlobal('state.internal.zSliceCounter');

	state.internal.firstTimeThroughLoop = 1;
	%state.acqParams.triggerTime = clock; %VI102909A
	state.internal.abort = 0;
	state.internal.currentMode = 3;
    
    %Save the original powerbox positions, to be reset later.
    if state.init.eom.pockelsOn & state.init.eom.powerBoxStepper.enabled
        set(gh.powerBoxStepper.enableCheckbox, 'Enable', 'Off');
        state.init.eom.originCacheMatrix = state.init.eom.powerBoxNormCoords;
    end
    
	mainLoop;
    
    %Reset the boxes back to their original, user selected, positions.
    if state.init.eom.powerBoxStepper.enabled
        set(gh.powerBoxStepper.enableCheckbox, 'Enable', 'On');
        state.init.eom.powerBoxNormCoords = state.init.eom.originCacheMatrix;
    end
    
else
	state.internal.looping = 0;
	state.internal.abortActionFunctions = 1;
	state.internal.abort = 1;
	closeShutter;
	setStatusString('Stopping Loop...');
	set(h, 'Enable', 'off');
	
	stopGrab;
	scim_parkLaser;
	flushAOData;
	

    if ~executeGoHome(true) %VI103009A: Return to cycle home, if it makes sense %VI101008A: Only restore Grab button if no MP285 error caused (or pre-existing)
        set(h, 'Enable', 'on');
    end

    setStatusString(''); %Don't report aborted loop...loops are /always/ aborted
    set([gh.mainControls.focusButton gh.mainControls.grabOneButton], 'Visible', 'On');
    turnOnMenus;
    set(h, 'String', 'LOOP');
    
    %Reset the boxes back to their original, user selected, positions.
    if state.init.eom.powerBoxStepper.enabled
        set(gh.powerBoxStepper.enableCheckbox, 'Enable', 'On');
        state.init.eom.powerBoxNormCoords = state.init.eom.originCacheMatrix;
    end
    
    %TO12204b - Tim O'Connor: Mark the beams as 'changed', so the data gets
    %reput, in the event of using different acquisition
    %methods/types/parameters.
    state.init.eom.changed(:) = 1;
end