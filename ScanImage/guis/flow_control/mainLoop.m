%% CHANGES
%   VI021908A - Vijay Iyer 2/19/08: Handle externally triggered case
%   VI041308A - Vijay Iyer 4/13/08: Wait till data is actually collected before declaring 'acquiring'
%   VI100608A - Vijay Iyer 10/06/08: Defer motor velocity setting to setMotorPosition()
%   VI101008A - Vijay Iyer 10/10/08: Defer updateRelativeMotorPosition() and setting of absX/Y/ZPosition to setMotorPosition()
%   VI101208A - Vijay Iyer 10/12/08: Deal with MP285 error in midst of loop
%   VI101308A - Vijay Iyer 10/13/08: Prepare motor velocity at start of loop cycles that are using the motor
%   VI101508A - Vijay Iyer 10/15/08: Move MP285SetVelocity() action to startGrab()
%   VI101608A - Vijay Iyer 10/16/08: Make all in-the-loop motor actions(i.e. all motor actions in this function) 'robust' using MP285RobustAction()
%   VI110308A - Vijay Iyer 11/03/08: Constrain loop timer to only positive values, and use rounding for 'smoother' countdown
%   VI110308B - Vijay Iyer 11/03/08: Fix logic for setting 'lastTimeDelay' on first time through loop
%   VI110408A - Vijay Iyer 11/05/08: Employ a count-up timer during acquisition when externally triggered
%   VI120208A - Vijay Iyer 12/02/08: If startGrab() self-aborts, then exit this function
%   VI102009A - Vijay Iyer 10/20/09: Use MP285RobustAction on a motor action (this was inadvertently left out with VI101608A). This resolves cycle LOOP error. 
%   VI102709A - Vijay Iyer 10/27/09: state.internal.lastTimeDelay renamed to state.internal.lastRepeatPeriod
%   VI102709B - Vijay Iyer 10/27/09: Determine and store state.internal.repeatPeriod, rather than state.internal.lastRepeatPeriod, to use for countdown timer during each cycle position. Leave determination of state.internal.lastRepeatPeriod to resumeLoop()
%   VI102809A - Vijay Iyer 10/28/09: Remove ellipsis, so that message appears correctly
%   VI102809B - Vijay Iyer 10/28/09: Improve countdown timer handling: 1) Allow countdown all the way to zero, 2) Avoid display of '-0'
%   VI102809C - Vijay Iyer 10/28/09: Relocate command-line status display code to acquisitionStartedFcn() 
%   VI102909A - Vijay Iyer 10/29/09: Refactor all countdown timer updates to updateCountdownTimer(); use state.internal.stackTriggerTime, instead of state.internal.triggerTime, for countdown timer updates
%   VI102909B - Vijay Iyer 10/29/09: Handle pause for any remaining countdown time here, instead of in dioTrigger()
%   VI102909C - Vijay Iyer 10/29/09: Allow finite looping in Cycle mode (via new state.cycle.numCycles variable)
%   VI102909D - Vijay Iyer 10/29/09: Consolidate all tasks occurring on first pass through loop
%   VI102909E - Vijay Iyer 10/29/09: Return to cycle home upon completion of cycle iterations; consolidate all instances of reurning to cycle home into returnToCycleHome()
%   VI102909F - Vijay Iyer 10/29/09: Read the initial position without calling updateMotorPosition() twice; if initial position is still somehow not defined, throw an error
%   VI103009A - Vijay Iyer 10/30/09: Use executeGoHome() for both cycle and stack moves home. Eliminates returnToCycleHome().
%   VI103009B - Vijay Iyer 10/30/09: Avoid moves to cycle home when loop iteration ends if the loop continues and cycle position 1 will require a stage move anyway
%   VI103009C - Vijay Iyer 10/30/09: Initialize countdown timer to currRepeatDelay on the first time through loop.
%   VI103009D - Vijay Iyer 10/30/09: Only reset state.internal.firstTimeThroughLoop just before trigger. This avoids bug where timer displays a 0 momentarily.
%   VI103009E - Vijay Iyer 10/30/09: For Cycle mode, handle return to stack home here now, skipping if about to move to a new stage position.
%   VI110109A - Vijay Iyer 11/01/09: Do not use the Cycle Controls position as the upcoming position to execute
%   VI110109B - Vijay Iyer 11/01/09: When externally triggered, always set seconds counter to 0 -- both first and successive times through loop
%   VI110109C - Vijay Iyer 11/01/09: Reset the positionsToExecute value when it wraps, regardless of whether LOOP execution about to end or not
%%
function out=mainLoop
out=1;
global state gh

setStatusString('Looping...');

if state.internal.abort
    state.internal.abort=0;
    out=0;
    state.internal.firstTimeThroughLoop=1;
    return
end

%%VI092909D%%%%%%
if state.internal.firstTimeThroughLoop  %VI102709A %VI110308B
    state.internal.lastRepeatPeriod = 0;
    %state.internal.lastTimeDelay=state.cycle.cycleTimeDelay(state.internal.positionToExecute); %VI102709B
    state.cycle.cycleCount = 0; %VI092909C
    state.internal.repeatsDone = 0; 
    %state.internal.positionToExecute = state.internal.position; %VI110109A %Ensures that displayed position is the actual starting position
    state.internal.initialMotorPosition = []; %VI103009E: Initialize this, just in case
end
%%%%%%%%%%%%%%%%

change=0;
if ~state.internal.cyclePaused
    if ~state.standardMode.standardModeOn
        if state.internal.repeatsDone>=state.internal.repeatsTotal
            state.internal.repeatsDone=0;
            state.internal.positionToExecute=state.internal.positionToExecute+1;
            change=1;
        end

        if state.internal.positionToExecute>state.cycle.length
            state.internal.positionToExecute=1; %VI110109C
            updateGUIByGlobal('state.internal.positionToExecute'); %VI110109C
            %%%VI102909C%%%%
            state.cycle.cycleCount = state.cycle.cycleCount+1;
            setStatusString(['Cycle # ' num2str(state.cycle.cycleCount) ' Done']);
            if state.cycle.cycleCount == state.cycle.numCycles
                pause(0.6); %Allow final 'Cycle #' status string to linger a bit
                executeGoHome(true); %VI103009A %VI102909E %Returns to cycle home position                
                abortCurrent(false); %End LOOP silently
                return;
            else
            %%%%%%%%%%%%%%%%%%                
                %state.internal.positionToExecute=1; %VI110109C: Relocated
                state.internal.repeatsDone=0;
                change=1;
                %%%VI103009A%%%%              
                if ~state.internal.firstTimeThroughLoop && state.cycle.cycleStartingPosition(state.internal.positionToExecute)==0 %VI103009B
                    if executeGoHome(true)
                        abortCurrent(); 
                        return;
                    end
                end
                %%%%%%%%%%%%%%%%%
            end
        end
        
        %%%VI103009E%%%%%%%
        if ~change || state.cycle.cycleStartingPosition(state.internal.positionToExecute)==0 
            %Go to stack home (if it exists) if there's been no change in cycle position, or if the new cycle position has no stage position
            
            %However don't go if the new cycle position = 1, as this is either the first time through, or 
            if ~state.internal.firstTimeThroughLoop && (state.internal.positionToExecute ~= 1 || ~state.cycle.returnHomeAtCycleEnd)
                if ~isempty(state.internal.initialMotorPosition)
                    if executeGoHome()
                        abortCurrent();
                        return;
                    end
                end
            end
        end
        %%%%%%%%%%%%%%%%%%%%
        
        if change
            if state.cycle.length > 1
                setStatusString('Loading new config...');
                changePositionToExecute;
            end
        end

        if state.internal.repeatsDone==0 && state.cycle.cycleStartingPosition(state.internal.positionToExecute)>0
            if MP285RobustAction(@()gotoPosition(state.cycle.cycleStartingPosition(state.internal.positionToExecute)), 'move to next cycle position', mfilename) %VI101608A
                abortCurrent;
                return;
            end
        end
    else
        state.internal.lastRepeatPeriod=state.standardMode.repeatPeriod; %VI102709A
        state.internal.repeatPeriod = state.standardMode.repeatPeriod; %VI110109A
        if state.internal.firstTimeThroughLoop
            state.internal.repeatsDone=0;
            updateGUIByGlobal('state.internal.repeatsDone');
        end
    end

    if state.acq.numberOfZSlices > 1 & state.motor.motorOn	% & state.acq.returnHome
        %state.internal.initialMotorPosition=updateMotorPosition;
        %if isempty(state.internal.initialMotorPosition) %VI101208A
        if MP285RobustAction(@updateMotorPosition, 'determine motor position prior to starting loop iteration', mfilename) %VI101608A
            abortCurrent;
            return;
        else
            state.internal.initialMotorPosition = state.motor.lastPositionRead;
        end
    else
        state.internal.initialMotorPosition=[];
    end

    %%%VI092909D: Relocated%%%%%%
    %     if (state.internal.firstTimeThroughLoop || state.internal.lastRepeatPeriod<=0 ) && ~state.standardMode.standardModeOn %VI102709A %VI110308B
    %         state.internal.lastRepeatPeriod = 0;
    %         %state.internal.lastTimeDelay=state.cycle.cycleTimeDelay(state.internal.positionToExecute); %VI102709B
    %     end
    %%%%%%%%%%%%%%%%%%%%%%%%
    
    %%%VI102709B: Record countdown time to use for current execution
    if ~state.standardMode.standardModeOn %VI110109A
        state.internal.repeatPeriod=state.cycle.cycleTimeDelay(state.internal.positionToExecute);
    end
    
    state.internal.looping=1;

    updateGUIByGlobal('state.internal.repeatsDone');
    updateGUIByGlobal('state.internal.positionToExecute');
    updateGUIByGlobal('state.internal.frameCounter');
    updateGUIByGlobal('state.internal.zSliceCounter');

    if state.acq.externallyTriggered %VI110109B %VI110508A
        state.internal.secondsCounter = 0;
        updateGUIByGlobal('state.internal.secondsCounter'); 
    else
        if state.internal.firstTimeThroughLoop==0
            updateCountdownTimer(); %VI102909A
        else
            state.internal.secondsCounter=state.internal.repeatPeriod; %VI103009C %VI102709A
            updateGUIByGlobal('state.internal.secondsCounter'); %VI102909A: Moved from outside loop
        end
    end

    %Move the powerbox.
    if state.init.eom.pockelsOn & state.init.eom.powerBoxStepper.enabled
        for i = 1 : state.init.eom.numberOfBeams
            if state.init.eom.showBoxArray(i)
                %x
                state.init.eom.powerBoxNormCoords(i, 1) = state.init.eom.powerBoxNormCoords(i, 1) + state.init.eom.powerBoxStepper.xStep;

                %y
                state.init.eom.powerBoxNormCoords(i, 2) = state.init.eom.powerBoxNormCoords(i, 1) + state.init.eom.powerBoxStepper.yStep;

                %width
                state.init.eom.powerBoxNormCoords(i, 3) = state.init.eom.powerBoxNormCoords(i, 1) + state.init.eom.powerBoxStepper.widthStep;

                %height
                state.init.eom.powerBoxNormCoords(i, 4) = state.init.eom.powerBoxNormCoords(i, 1) + state.init.eom.powerBoxStepper.heightStep;
            end
        end
    end
else
    state.internal.cyclePaused=0;
    state.internal.looping=1;
    if ~state.standardMode.standardModeOn
        setStatusString('Loading config...');
        changePositionToExecute;
    end

    if state.acq.numberOfZSlices > 1 & state.motor.motorOn	% & state.acq.returnHome
        %         state.internal.initialMotorPosition=updateMotorPosition;
        %         if isempty(state.internal.initialMotorPosition) %VI101208A
        %             abortCurrent;
        %             return;
        %         end
        if MP285RobustAction(@updateMotorPosition, 'determine motor''s initial position', mfilename) %VI101608A
            abortCurrent;
            return;
        end
    else
        state.internal.initialMotorPosition=[];
    end
end

% 	startZoom;
if state.init.autoReadPMTOffsets
    startPMTOffsets;
end
% load daq engine % here get dacq ready for trigger
if state.internal.firstTimeThroughLoop==0
    if ~state.acq.externallyTriggered %VI110408A
        setStatusString('Counting down...');
        if etime(clock,state.internal.stackTriggerTime)> state.internal.lastRepeatPeriod %VI102909A %VI102809B %VI102709A 
            setStatusString('DELAY TOO SHORT!');
            beep;
        end
        %Loop to allow for abort operations and to avoid updating countdown timer string more than once per second
        while etime(clock,state.internal.stackTriggerTime) < state.internal.lastRepeatPeriod -1 %VI102909A %VI102809D %VI102809B %VI102709A %Starts housekeeping stuff 1s early
            if state.internal.cyclePaused
                return
            end
            if state.internal.abort==1
                state.internal.abort=0;
                state.internal.firstTimeThroughLoop=1;
                state.internal.looping=0;
                out=0;
                return
            end
            old=etime(clock,state.internal.stackTriggerTime); %VI102909A
            %			updateMotorPosition;
            while floor(etime(clock,state.internal.stackTriggerTime))<old %VI102909A
                pause(0.01);
                if state.internal.cyclePaused
                    return
                end
                if state.internal.abort==1
                    state.internal.abort=0;
                    state.internal.firstTimeThroughLoop=1;
                    out=0;
                    return
                end
            end

            updateCountdownTimer(); %VI102909A
            pause(0.01);
        end
        
        state.internal.secondsCounter=0; 
        %updateGUIByGlobal('state.internal.secondsCounter'); %VI102809D %VI102809B
        
        %%%VI102809D: Removed %%%%%%
        %         if state.internal.lastRepeatPeriod-etime(clock,state.internal.triggerTime)-state.internal.timingDelay>0 %VI102709A
        %             pause(state.internal.lastRepeatPeriod-etime(clock,state.internal.triggerTime)-state.internal.timingDelay) %VI102709A % 0.05 is
        %         end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    end
    
    if strcmp(get(gh.mainControls.focusButton, 'String'), 'FOCUS')
        set(gh.mainControls.focusButton, 'Visible', 'Off');
    else
        setStatusString('STOP FOCUS!');
        disp('mainLooop:  Interrupting loop because focus was running at trigger time');
        state.internal.looping=0;
        return
    end

else

    if state.internal.abort==1
        state.internal.abort=0;
        state.internal.firstTimeThroughLoop=1;
        out=0;
        set(gh.mainControls.focusButton, 'Visible', 'On');
        return
    end
    set(gh.mainControls.focusButton, 'Visible', 'Off');
    if state.cycle.returnHomeAtCycleEnd & state.internal.positionToExecute==1 ... %Only re-define cycleInitialMotorPosition on first position. It can be retained if loop is acquired in several steps (i.e. aborted and re-started at a new position). Ideally would make some user prefernce to capture various possible behaviors -- Vijay Iyer 11/1/09
            & state.internal.repeatsDone==0 & ~state.standardMode.standardModeOn & state.motor.motorOn
        setStatusString('Defining cycle home'); %VI102809A
       
        %state.internal.cycleInitialMotorPosition=updateMotorPosition; %VI102909F
        if MP285RobustAction(@updateMotorPosition, 'determine motor''s initial position', mfilename)  %VI101208A %VI102009A
            abortCurrent;
            return;
        end
        state.internal.cycleInitialMotorPosition = state.motor.lastPositionRead; %VI102909F
    end

    %state.internal.firstTimeThroughLoop=0;  %VI103009D: Do this later

end

%state.internal.stopAcq = 0; Updated to match berbnardo's code
if state.internal.abort	% Updaeted via BS on 1/16/02
    state.internal.abort=0;
    state.internal.firstTimeThroughLoop=1;
    out=0;
    set(gh.mainControls.focusButton, 'Visible','On');
    return
end

try
    if state.init.eom.pockelsOn
        for i = 1 : state.init.eom.numberOfBeams
            if length(state.init.eom.showBoxArray < i)
                continue;
            end
            if state.init.eom.showBoxArray(i)
                state.init.eom.powerBoxWidthsInMs(i) = round(100 * state.init.eom.powerBoxNormCoords(i, 3) ...
                    * (1000 * state.acq.msPerLine) / state.acq.pixelsPerLine) / 100;
            else
                state.init.eom.powerBoxWidthsInMs(i) = 0;
            end
        end
        if length(state.init.eom.showBoxArray) < state.init.eom.numberOfBeams
            state.init.eom.showBoxArray(state.init.eom.numberOfBeams) = 0;
        end
        %         if length(state.init.eom.uncagingPulseImporter.enabled) < state.init.eom.numberOfBeams
        %             state.init.eom.uncagingPulseImporter.enabled(state.init.eom.numberOfBeams) = 0;
        %         end
        updateHeaderForAcquisition;

        try
            if size(state.init.eom.uncagingMapper.pixels, 1) >= state.init.eom.numberOfBeams & ...
                    size(state.init.eom.uncagingMapper.pixels, 2) >= state.init.eom.uncagingMapper.position & ...
                    size(state.init.eom.uncagingMapper.pixels, 3) >= 4
                if any(state.init.eom.uncagingMapper.enabled)
                    if state.init.eom.uncagingMapper.perGrab
                        state.init.eom.uncagingMapper.currentPixels = state.init.eom.uncagingMapper.pixels(:, ...
                            state.init.eom.uncagingMapper.position, :);
                        state.init.eom.uncagingMapper.currentPosition = state.init.eom.uncagingMapper.position;
                    elseif state.init.eom.uncagingMapper.perFrame
                        lastPixel = state.init.eom.uncagingMapper.position + state.acq.numberOfFrames - 1;

                        state.init.eom.uncagingMapper.currentPosition = state.init.eom.uncagingMapper.position : ...
                            state.init.eom.uncagingMapper.position + state.init.eom.uncagingMapper.pixelCount - 1;
                        %                                 if lastPixel > size(state.init.eom.uncagingMapper.pixels, 2)
                        %                                     lastPixel = size(state.init.eom.uncagingMapper.pixels, 2);
                        %                                 end
                        %
                        %                                 state.init.eom.uncagingMapper.currentPixels = state.init.eom.uncagingMapper.pixels(:, ...
                        %                                     state.init.eom.uncagingMapper.position : lastPixel, :);
                        state.init.eom.uncagingMapper.currentPixels = state.init.eom.uncagingMapper.pixels;
                    end
                end
            end
        catch
            warning(sprintf('Error in saving Pockels Cell uncaging map data to header (mainLoop): %s\n', lasterr));
        end
        updateHeaderString('state.init.eom.uncagingMapper.currentPixels');
        updateHeaderString('state.init.eom.uncagingMapper.currentPosition');
        updateHeaderString('state.init.eom.uncagingMapper.position');
    end
catch
    warning(sprintf('Error in saving Pockels Cell data to header (mainLoop): %s\n', lasterr));
end

%setStatusString('Acquiring...'); %VI041308A

state.internal.stripeCounter=0;
state.internal.forceFirst=1;
resetCounters;

%%VI101308A%%%%
if state.motor.motorOn && (state.acq.numberOfZSlices > 1 || ~state.standardMode.standardModeOn)
    if MP285RobustAction(@()MP285SetVelocity(state.motor.velocitySlow,1), 'set motor velocity at start of stack', mfilename) %VI101508A
        abortCurrent;
        return;
    end
end
%%%%%%%%%%%%%%%%%
startGrab;

%%%VI120208A%%%%
if state.internal.abort
    return;
end
%%%%%%%%%%%%%%%%

if state.shutter.shutterDelay==0
    openShutter;
else
    state.shutter.shutterOpen=0;
end
% daqdata = getDaqData(state.acq.dm, 'PockelsCell-2');
% domain = 1000 .* (1:length(daqdata)) ./ getAOProperty(state.acq.dm, 'PockelsCell-2', 'SampleRate');
% figure;plot(domain, daqdata);
% xlabel('Time [ms]');
% ylabel('Voltage [V]');

%%%VI102909B%%%%%%
if ~state.internal.firstTimeThroughLoop 
    if ~state.acq.externallyTriggered 
        if ~isempty(state.internal.stackTriggerTime)
            %Wait for  countdown to reach 0 (should be <1s at this point), leaving small amount of time for code leading up to actual trigger
            pause(getCountdownTime()-state.internal.timingDelay);
        end

        state.internal.secondsCounter=0; %Ensure that 0 is displayed at end of countdown
        updateGUIByGlobal('state.internal.secondsCounter');
    end    
else
   state.internal.firstTimeThroughLoop = 0; %VI103009D 
end
%%%%%%%%%%%%%%%%%%

dioTriggerConditional; %VI021908A

%%%VI102809C: Relocated %%%%
% disp(['Executed ''' state.configName ''' at ' clockToString(clock)]);
% if state.internal.triggerTime
%     disp(['   Seconds since last acquisition: ' num2str(etime(clock,state.internal.triggerTime))]);
% end
%%%%%%%%%%%%%%%%%%%%%%%%%%%

%TO3104a - Do uncaging-based mapping.
if state.init.eom.pockelsOn
    if any(state.init.eom.uncagingMapper.enabled) & ~strcmpi(get(gh.mainControls.grabOneButton, 'String'), 'Abort')
        if state.init.eom.uncagingMapper.perGrab
            state.init.eom.uncagingMapper.position = state.init.eom.uncagingMapper.position + 1;

            fprintf(1, '   UncagingMapper Position: %s\n', num2str(state.init.eom.uncagingMapper.position - 1));
            if state.init.eom.uncagingMapper.position <= size(state.init.eom.uncagingMapper.pixels, 2)
                for i = 1 : state.init.eom.numberOfBeams
                    if state.init.eom.uncagingMapper.enabled(i)
                        state.init.eom.changed(i) = 1;
                        putDaqData(state.acq.dm, state.init.eom.pockelsCellNames{i}, ...
                            makePockelsCellDataOutput(i));
                    end
                end
            end

            updateHeaderString('state.init.eom.uncagingMapper.position');
            updateHeaderString('state.init.eom.uncagingMapper.pixels');
            updateGUIByGlobal('state.init.eom.uncagingMapper.pixel', 'Value', state.init.eom.uncagingMapper.position);

            if state.init.eom.uncagingMapper.position > size(state.init.eom.uncagingMapper.pixels, 2)
                state.init.eom.uncagingMapper.position = 1;
                updateGUIByGlobal('state.init.eom.uncagingMapper.pixel', 'Value', ...
                    state.init.eom.uncagingMapper.position, 'Callback', 1);
            end
        elseif state.init.eom.uncagingMapper.perFrame

            %Allow resume.
            state.init.eom.uncagingMapper.position = state.init.eom.uncagingMapper.pixelCount + state.init.eom.uncagingMapper.position;
            if state.init.eom.uncagingMapper.position > size(state.init.eom.uncagingMapper.pixels, 2)
                state.init.eom.uncagingMapper.position = 1;%size(state.init.eom.uncagingMapper.pixels, 2);
            end
            updateGUIByGlobal('state.init.eom.uncagingMapper.pixel', 'Value', state.init.eom.uncagingMapper.position, ...
                'Callback', 1);
            for i = 1 : state.init.eom.numberOfBeams
                if state.init.eom.uncagingMapper.enabled(i)
                    state.init.eom.changed(i) = 1;
                    putDaqData(state.acq.dm, state.init.eom.pockelsCellNames{i}, ...
                        makePockelsCellDataOutput(i));
                end
            end
        end
    end

    if state.init.eom.uncagingPulseImporter.enabled & ~state.init.eom.uncagingPulseImporter.syncToPhysiology & ...
            any(state.init.eom.showBoxArray(:)) & size(state.init.eom.powerBoxNormCoords, 2) == 4

        if state.init.eom.uncagingPulseImporter.position < size(state.init.eom.uncagingPulseImporter.cycleArray, 2)
            updateGUIByGlobal('state.init.eom.uncagingPulseImporter.position', 'Value', ...
                state.init.eom.uncagingPulseImporter.position + 1, 'Callback', 1);
        else
            updateGUIByGlobal('state.init.eom.uncagingPulseImporter.position', 'Value', 1, 'Callback', 1);
        end

        state.init.eom.changed(find(state.init.eom.showBoxArray > 0)) = 1;

        %Update the display.
        updateGUIByGlobal('state.init.eom.uncagingPulseImporter.position');
        uncagingPulseImporter('positionText_Callback', gh.uncagingPulseImporter.positionText);
    elseif state.init.eom.uncagingPulseImporter.syncToPhysiology & ...
            any(state.init.eom.showBoxArray(:)) & size(state.init.eom.powerBoxNormCoords, 2) == 4
    end

    if state.init.eom.uncagingPulseImporter.enabled & ~state.init.eom.uncagingPulseImporter.syncToPhysiology & ...
            any(state.init.eom.showBoxArray(:)) & size(state.init.eom.powerBoxNormCoords, 2) == 4
        if state.init.eom.uncagingPulseImporter.position < size(state.init.eom.uncagingPulseImporter.cycleArray, 2)
            state.init.eom.uncagingPulseImporter.position = state.init.eom.uncagingPulseImporter.position + 1;
        else
            state.init.eom.uncagingPulseImporter.position = 1;
        end

        %Update the display.
        updateGUIByGlobal('state.init.eom.uncagingPulseImporter.position');
        uncagingPulseImporter('positionText_Callback', gh.uncagingPulseImporter.positionText);
    elseif state.init.eom.uncagingPulseImporter.enabled & state.init.eom.uncagingPulseImporter.syncToPhysiology
        state.init.eom.changed(:) = 1;
    end
end

    %%%VI102909A%%%%%%%%%
    function updateCountdownTimer()
        state.internal.secondsCounter=max(round(getCountdownTime()),0.0); %VI110308A
        %%%VI102809B%%%
        %This strangeness is necessary because setGUIValue() does not use num2str() when setting a 'String' property - and so will sometimes display '-0' for zero values. Decided against changing (fixing) setGUIValue() because it's a very core function -- Vijay Iyer 10/28/09
        if state.internal.secondsCounter == 0
            state.internal.secondsCounter = 0;
        end
        %%%%%%%%%%%%%%%
        updateGUIByGlobal('state.internal.secondsCounter');
    end
    %%%%%%%%%%%%%%%%%%%%%%%
    
    %%%VI102909B%%%%
    function countdownTime = getCountdownTime()
        countdownTime = state.internal.lastRepeatPeriod-etime(clock,state.internal.stackTriggerTime); %VI102709A
    end
    %%%%%%%%%%%%%%%%
    
    %%%VI103009A: Removed%%%%%%%%%
    %%%VI102909E%%%%%%%%%%
    %     function ok = returnToCycleHome()
    %         ok = true;
    %         if state.cycle.returnHomeAtCycleEnd && state.motor.motorOn
    %             %MP285SetVelocity(state.motor.velocityFast); %VI100608A
    %             if length(state.internal.cycleInitialMotorPosition)~=3
    %                 setStatusString('Cycle home error!');
    %                 error('Cannot return to cycle home.  Cycle home not defined!'); %VI102909F: Treat this as an error -- it shouldn't happen (Loop should have been aborted)
    %             else
    %                 %state.motor.absXPosition=state.internal.cycleInitialMotorPosition(1);
    %                 %state.motor.absYPosition=state.internal.cycleInitialMotorPosition(2);
    %                 %state.motor.absZPosition=state.internal.cycleInitialMotorPosition(3);
    %                 setStatusString('Moving to cycle home'); %VI102909F: Moved from above
    %                 if MP285RobustAction(@()setMotorPosition(state.internal.cycleInitialMotorPosition),'move to initial position in cycle', mfilename) %VI101008A, VI101608A
    %                     abortCurrent;
    %                     ok=false;
    %                 end
    %
    %                 %MP285SetVelocity(state.motor.velocitySlow); %VI100608A
    %                 %updateRelativeMotorPosition; %VI101008A
    %             end
    %         end
    %     end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end