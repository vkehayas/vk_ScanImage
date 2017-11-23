function acquisitionStartedFcn(obj, eventdata)
%ACQUISITIONTRIGGEREDFCN Callback function invoked upon triggering of GRAB/LOOP acquisition
%
%% NOTES
%   Code here mostly copied/pasted out of makeFrameByStripes() -- Vijay Iyer 7/1/09
%
%   The tasks in this functions are best not done in the SamplesAcquiredFcn(), because they can potentially be done before the first batch of samples comes available. Also helps to balance workload for SamplesAcquiredFcn calls.
%
%% CHANGES
%   VI102809A: Determine trigger time from the SamplesAvailable property from DAQ toolbox, rather than using the 'InitialTriggerTime' property, which seems unreliable -- Vijay Iyer 10/28/09 
%   VI102809B: Display loop iteration command line info here now, instead of in mainLoop() -- Vijay Iyer 10/28/09
%   VI102809C: Move clock() and get(obj,'SamplesAvailable') to top of function for most accurate recordings -- Vijay Iyer 10/28/09
%   VI102909A: Store state.internal.stackTriggerTime value on first slice within a stack; only display to command line on first slice; use state.internal.stackTriggerTime as lastTriggerTime  -- Vijay Iyer 10/29/09
%   VI110109A: Set status string 'Acquiring...' here, so that it gets displayed during Cycle mode operation. -- Vijay Iyer 11/01/09
%   VI111609A: Don't open @tifstream object if snapping -- Vijay Iyer 11/16/09
%
%% CREDITS
%   Created 7/1/09, by Vijay Iyer
%% ************************************************

global state

%%%VI102809A/C: Record trigger time up front %%%%%
timeVec = clock(); 
sampsAvail = get(obj,'SamplesAvailable'); 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Stop trigger timer, if running 
if ~isempty(state.internal.triggerTimer) && strcmpi(get(state.internal.triggerTimer,'Running'),'on')
    stop(state.internal.triggerTimer);
end

%Record soft trigger time for case of external triggering
if state.acq.externallyTriggered
    state.internal.softTriggerTime = timeVec; %VI102809C
    state.internal.softTriggerTimeString = clockToString(state.internal.softTriggerTime);
    updateHeaderString('state.internal.softTriggerTimeString');
end

%VI102809B: Cache last trigger time
lastTriggerTime = state.internal.stackTriggerTime; %VI102909A

%%%VI102809A%%%%%%%%%%%%%%%%%%%%%%%%%
timeAdjustMs = -round(1000*sampsAvail/state.acq.inputRate);
if verLessThan('matlab','7.7') %Handle adjustment manually -- note this is not robust to all cases (> 1 minute, day/month/year boundaries, etc)
    timeVec(6) = timeVec(6) + timeAdjustMs/1000;
    if timeVec(6) < 0 %crossed minute boundary
        timeVec(5) = timeVec(5) - 1;
        timeVec(6) = 60 + timeVec(6);
        
        if timeVec(5) < 0 %crossed hour boundary
            timeVec(4) = timeVec(4) - 1;
            timeVec(5) = 60 + timeVec(5);
        
            if timeVec(4) < 0 %crossed day boundary
                timeVec(3) = timeVec(3) - 1;
                timeVec(4) = 24 + timeVec(4); 
            end
        end
    end      
    state.internal.triggerTime = timeVec;
else
    %Use built-in addtodate() function, converting to/from serial date number format
    state.internal.triggerTime = datevec(addtodate(datenum(timeVec),timeAdjustMs,'millisecond')); 
end
%%%%%%%%%%%%%%%%%%%%%%%%
if isempty(state.internal.triggerTime) %|| any(state.internal.triggerTime == 0) %VI102809D
    state.internal.triggerTimeString = '';
    fprintf(2, 'Warning: state.internal.triggerTime is not valid, hardware triggering may not have occurred.\n'); %Should arguably throw error and abort acquisition -- Vijay Iyer 10/28/09
else
    state.internal.triggerTimeString = clockToString(state.internal.triggerTime); %clockToString is faster than datestr()
end
updateHeaderString('state.internal.triggerTimeString');

%VI102909A: Handle things applicable to first slice (or only slice) in stack
if state.internal.zSliceCounter == 0
    %%%VI102809B%%%%%%%%
    if state.internal.looping && ~isempty(state.internal.triggerTime) %Should arguably have ensured that state.internal.triggerTime is not empty above -- Vijay Iyer 10/28/09
        disp(['Starting ''' state.configName ''' at ' clockToString(state.internal.triggerTime)]);
        if ~isempty(lastTriggerTime)
            disp(['   Seconds since last acquisition: ' num2str(etime(state.internal.triggerTime,lastTriggerTime))]);
        end
    end
    %%%%%%%%%%%%%%%%%%%%%
    
    state.internal.stackTriggerTime = state.internal.triggerTime;
    state.internal.stackTriggerTimeString = state.internal.triggerTimeString;
end
%%%%%%%%%%%%%%%%%%%%%
       
%%%Initialize tifStream, if needed
if state.acq.saveDuringAcquisition && state.acq.framesPerFile && ~state.internal.snapping %VI111609A: Ensure not snapping %Checks to ensure not in 'pseudo-focus' mode
    try
        state.files.tifStream = scim_tifStream(state.files.tifStreamFileName,state.acq.pixelsPerLine, state.acq.linesPerFrame, state.headerString);
    catch 
        abortCurrent;
        msgbox('Unable to initialize file for acquisition. Most likely, the file already existed. Acquisition aborted.','Failed to Create File','error','modal');
        disp(lasterr);
        return;
    end
end

setStatusString('Acquiring...'); %VI110109A

end

