function endAcquisition
%% function endAcquisition
%%
% Function called at the end of the acquistion that will park the laser, close the shutter,
% write the data to disk, reset the counters (internal), reset the currentMode, and make the 
% Grab One and Loop buttons visible.
%
% Written By: Thomas Pologruto and Bernardo Sabatini
% Cold Spring Harbor Labs
% March 2, 2001
% 
%% MODIFICATIONS
% VI031108A Vijay Iyer 3/11/08 - Don't auto-save if data's been saved during acquisition
% VI082208A Vijay Ieyr 8/22/08 - Close tifstream for saveDuringAcquisition mode
% VI093008A Vijay Iyer 9/30/08 - Abort stack collection if movement failed
% VI100608A Vijay Iyer 10/06/08 - Handle MP-285 error conditions smartly 
% VI101008A Vijay Iyer 10/10/08 - Handle MP-285 failure to return home
% VI101508A Vijay Iyer 10/15/08 - Use new MP285RobustAction for executeGoHome and MP285FinishMove actions
% VI103009A Vijay Iyer 10/30/09 - If looping in Cycle mode, don't return to stack home here -- leave this to mainLoop()
%
%% ******************************************************************
global state gh

% if user has aborted, then return
if state.internal.abortActionFunctions
    abortInActionFunction;
    return
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Calculate MAx projections if necessary%%%%%%%%%%%%%%%%%%
%%TPMOD for roiCycles....7/21/03 % Code for displaying Max Projections
calculateMaxProjections;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Now setup for another pass if possible....
if state.internal.zSliceCounter + 1 == state.acq.numberOfZSlices    
    % Done Acquisition since there are no more stacks....
    stopGrab;
    
    %TPMOD for SnapShot Mode....6/2/03
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if state.internal.snapping
        doSnapShot;
        return
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %Save the data to disk....
    if state.files.autoSave && ~state.acq.saveDuringAcquisition	% BSMOD - Check status of autoSave option  % VI031108A
        status=state.internal.statusString;
        setStatusString('Writing data...');
        writeData;
        writeMaxData;
        setStatusString(status);
        state.files.fileCounter=state.files.fileCounter+1;
        updateGUIByGlobal('state.files.fileCounter');
        updateFullFileName(0);
    elseif state.acq.saveDuringAcquisition && ~isempty(state.files.tifStream) %VI031108A, VI082208A
        try
            close(state.files.tifStream);
            state.files.tifStream = [];
            state.files.fileCounter=state.files.fileCounter+1;
            updateGUIByGlobal('state.files.fileCounter');
            updateFullFileName(0);
        catch
            delete(state.files.tifStream,'leaveFile');
            errordlg('Failed to close an open TIF stream. A file may be corrupted.');
            state.files.tifStream = [];
        end
    end
    
    %TO051804a
    callUserFunction;
    
    %TPMOD for roiCycles....7/10/03
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if state.internal.roiCycleExecuting % Doing user defined cycle... 
        loopROICycle;
        return
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
    
    scim_parkLaser;
    putDataGrab;
    
    state.internal.zSliceCounter = state.internal.zSliceCounter + 1;
    updateGUIByGlobal('state.internal.zSliceCounter');
    if state.acq.numberOfZSlices > 1   
        if MP285FinishMove(1)
            MP285Recover; %Interrupt the move..and get the position
            if state.motor.errorCond
                fprintf(2,'ERROR (%s): Unable to verify correct completion of stack motion', mfilename);
            else
                MP285FinishMove(1); %check the position and flag if it's not as expected
            end
        end

        if ~state.internal.looping || state.standardMode.standardModeOn %VI103009A
            if MP285RobustAction(@executeGoHome, 'return home upon stack completion', mfilename) %VI101508A
                abortCurrent; %VI101008A
                return;
            end
        end
    end				
    
    if state.internal.looping==1
        setStatusString('Resuming Loop....');
        resumeLoop;
    else
        setStatusString('Ending Grab...');
        set(gh.mainControls.focusButton, 'Visible', 'On');
        set(gh.mainControls.startLoopButton, 'Visible', 'On');
        set(gh.mainControls.grabOneButton, 'String', 'GRAB');
        set(gh.mainControls.grabOneButton, 'Visible', 'On');
        turnOnMenus;
        setStatusString('');
    end
elseif state.internal.zSliceCounter < state.acq.numberOfZSlices - 1
    % Between Acquisitions or ZSlices
    setStatusString('Next Slice...');
    if state.files.autoSave		% BSMOD - Check status of autoSave option
        setStatusString('Writing data...');
        writeData;
    end
    
    %TO051804a
    callUserFunction;
    
    state.internal.zSliceCounter = state.internal.zSliceCounter + 1;
    updateGUIByGlobal('state.internal.zSliceCounter');
    
    state.internal.frameCounter = 1;
    updateGUIByGlobal('state.internal.frameCounter');
    
    setStatusString('Acquiring...');
    
    putDataGrab;
    
    if MP285FinishMove(0)	% check that movement completed (e.g. a CR was sent back), but don't verify position. This proved too unreliable so far -- Vijay Iyer 10/06/08
        abortCurrent;  %VI093008A   
        return;
    end
        
    if (strcmp(get(gh.mainControls.grabOneButton, 'String'), 'GRAB') ...
            & strcmp(get(gh.mainControls.grabOneButton, 'Visible'),'on'))
        set(gh.mainControls.grabOneButton, 'enable', 'off');
        set(gh.mainControls.grabOneButton, 'enable', 'on');
    elseif (strcmp(get(gh.mainControls.startLoopButton, 'String'), 'LOOP') ...
            & strcmp(get(gh.mainControls.startLoopButton, 'Visible'),'on'))
        set(gh.mainControls.startLoopButton, 'enable', 'off');
        state.internal.abort=1;
        set(gh.mainControls.startLoopButton, 'enable', 'on');
    else
        try; startGrab; catch; end
        openShutter;
        dioTrigger;
    end
end

%TO051804a - Call user function after saving data to a file.
%            Also, wrap with a try/catch.
function callUserFunction
global state;
%%%%%%%%%%%%%%%%%%User Function Call%%%%%%%%%%%%%%%%% TPMOD
try
    if state.userFcnGUI.UserFcnOn
        if (state.internal.snapping & state.acq.execUserFcnOnSnap) | ~state.internal.snapping
            executeUserFcn;
        end        
    end
catch
    warning('Error executing UserFunction: %s', lasterr);
end
