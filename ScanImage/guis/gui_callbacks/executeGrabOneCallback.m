%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% executeGrabOneCallback(h).m******
%% In Main Controls, This function is executed when the Grab One or Abort button is pressed.
%% It will on abort requeu the data appropriate for the configuration.
%% 
%% Written by: Thomas Pologruto and Bernardo Sabatini
%% Cold Spring Harbor Labs
%% January 26, 2001
%%
%% MODIFICATIONS
%   Tim O'Connor 12/16/03 :: Update the Pockels cell data, for multiple beams.
%   Tim O'Connor 2/9/04 TO2904a :: Don't access Pockels cell stuff when there's no Pockels cell.
%   Vijay Iyer 2/19/08 VI021908A :: Handle externally triggered case
%   Vijay Iyer 5/6/08 VI050608A :: Eliminate timeout error on reading position at start of stack by pausing. Remove redundant MP285Flush().
%   Vijay Iyer 5/6/08 VI050608B :: Eliminate superfluous overwrite warning message that's based on incorrect idea of checkFileBeforeSave() return value
%   Vijay Iyer 10/6/08 VI100608B :: MP285Clear() instead of MP285Flush(), after restoring its use at all.
%   Vijay Iyer 10/10/08 VI101008A :: Handle case where there's an error going home during an abort
%   Vijay Iyer 10/12/08 VI101208A :: Abort GRAB if error occurs during pre-GRAB motor operations 
%   Vijay Iyer 10/13/08 VI101308A :: Handle motor velocity setting here
%   Vijay Iyer 11/01/09 VI110109A :: Set state.internal.repeatPeriod to empty when used for GRAB acquisitions. It should only contain a value for LOOP acquisitions. 
%%
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
%%
function executeGrabOneCallback(h)
global state gh
% warning('Position (before): %s', num2str(state.init.eom.uncagingMapper.position));
	state.internal.looping = 0;
    state.internal.repeatPeriod = []; %VI110109A

	val = get(h, 'String');

		if strcmp(val, 'GRAB')            
           
            if state.init.eom.pockelsOn
                state.init.eom.uncagingMapper.pixelCount = 0;
            end
            
            %Synch to Physiology software if applicable...
			if state.init.syncToPhysiology
                if isfield(state,'physiology') & isfield(state.physiology,'mainPhysControls') & isfield(state.physiology.mainPhysControls, 'acqNumber')
                    maxVal = max(state.physiology.mainPhysControls.acqNumber, ...
                        state.files.fileCounter);
                    state.physiology.mainPhysControls.acqNumber = maxVal;
                    state.files.fileCounter = maxVal;
                    updateGUIByGlobal('state.physiology.mainPhysControls.acqNumber');
                    updateGUIByGlobal('state.files.fileCounter');
                end
            end
			if strcmp(get(gh.basicConfigurationGUI.figure1, 'Visible'), 'on') == 1
				beep;
				setStatusString('Close Configuration GUI');
				return
			end
            ok = savingInfoIsOK;
			if ok == 0
                return;
			end
			if state.internal.updatedZoomOrRot % need to reput the data with the approprite rotation and zoom.
				state.acq.mirrorDataOutput = rotateAndShiftMirrorData(1 / state.acq.zoomFactor * state.acq.mirrorDataOutputOrg);
				flushAOData;
				state.internal.updatedZoomOrRot = 0;
			end
            %Update the Pockels cell signal(s) if necessary. 12/16/03
            %Only do this if the pockels cell code is active. - TO2904a
            if state.init.eom.pockelsOn
                for beamCounter = 1 : state.init.eom.numberOfBeams
                    if state.init.eom.changed(beamCounter)
                        %                     putDaqData(state.acq.dm, state.init.eom.pockelsCellNames{beamCounter}, ...
                        %                         repmat(makePockelsCellDataOutput(beamCounter), [state.acq.numberOfFrames 1]) ...
                        %                         );
                        %The data is already replicated out to the correct number of frames.
                        putDaqData(state.acq.dm, state.init.eom.pockelsCellNames{beamCounter}, ...
                            makePockelsCellDataOutput(beamCounter));
                    end
                end
            end
			% Check if file exisits
			overwrite = checkFileBeforeSave([state.files.fullFileName '.tif']);
			if isempty(overwrite)
				return;
            %%%%%% VI050608B%%%%%%%%%%
 			%elseif ~overwrite
            %      %TPMOD 2/6/02
            %      if state.files.autoSave || state.acq.saveDuringAcquisition                    
 			%	    disp('Overwriting Data!!');
            %      end
            %%%%%%%%%%%%%%%%%%%%%%%%%%
            end
			
% 			startZoom;
			if state.init.autoReadPMTOffsets
				startPMTOffsets;
            end

            %%%%Motor preparations
            if state.motor.motorOn && state.acq.numberOfZSlices > 1                
                MP285Clear; %VI050608A, VI100608A
                pause(.5); %VI050608A
                
                if MP285RobustAction(@updateMotorPosition,'record position at start of stack', mfilename) %VI101508A
                    abortCurrent;
                    return;
                end                       
                state.internal.initialMotorPosition = state.motor.lastPositionRead;
     
                               
                if MP285RobustAction(@()MP285SetVelocity(state.motor.velocitySlow,1), 'set motor velocity at start of stack', mfilename) %VI101508A
                    abortCurrent;
                    return;
                end                
            else
                state.internal.initialMotorPosition = [];
            end 
            %%%%%%%%%%%           
                
            set(h, 'String', 'ABORT'); 
            
            setStatusString('Acquiring Grab...');
			set([gh.mainControls.focusButton gh.mainControls.startLoopButton], 'Visible', 'Off');
			turnOffMenus;
			
			resetCounters;
			state.internal.abortActionFunctions = 0;
			
			updateGUIByGlobal('state.internal.frameCounter');
			updateGUIByGlobal('state.internal.zSliceCounter');
			
            updateCurrentROI;   %TPMOD 6/18/03
            
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
%                     if length(state.init.eom.uncagingPulseImporter.enabled) < state.init.eom.numberOfBeams
%                         state.init.eom.uncagingPulseImporter.enabled(state.init.eom.numberOfBeams) = 0;
%                     end
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
                        warning(sprintf('Error in saving Pockels Cell uncaging map data to header (executeGrabOneCallback): %s\n', lasterr));
                    end
                end
            catch
                warning(sprintf('Error in saving Pockels Cell data to header (executeGrabOneCallback): %s\n', lasterr));
            end

            startGrab;
            if state.shutter.shutterDelay == 0
			    openShutter;
            else
                state.shutter.shutterOpen = 0;
            end
            
% NOTE: For now, just set a global variable called "debugFlag" to 1, to
% enable plotting, don't comment/uncomment this stuff anymore.
% daqdata = getDaqData(state.acq.dm, 'PockelsCell-2');
% domain = 1000 .* (1:length(daqdata)) ./ getAOProperty(state.acq.dm, 'PockelsCell-2', 'SampleRate');
% figure;plot(domain, daqdata);
% title('Actual Pockels Cell Signal at time of Grab');
% xlabel('Time [ms]');
% ylabel('Voltage [V]');
            dioTriggerConditional; %VI021908A
                
		elseif strcmp(val, 'ABORT')
            %TPMOD 7/7/03....
            if state.internal.roiCycleExecuting
                abortROICycle;
                return
            end
            
			state.internal.abortActionFunctions = 1;

			closeShutter;
			stopGrab;
			
			setStatusString('Aborting...');
			set(h, 'Enable', 'off');
			
			scim_parkLaser;
			flushAOData;
			
            if ~executeGoHome  %VI101008A: Only restore Grab button if no MP285 error caused (or pre-existing)
                set(h, 'Enable', 'on');
            end
            setStatusString('Aborted Grab');
            set(h, 'String', 'GRAB');
            set([gh.mainControls.focusButton gh.mainControls.startLoopButton], 'Visible', 'On');
            turnOnMenus;
		else
			disp('executeGrabOneCallback: Grab One button is in unknown state'); 	% BSMOD - error checking
		end

        %TO3104a - Do uncaging-based mapping.
        if state.init.eom.pockelsOn
            if any(state.init.eom.uncagingMapper.enabled) & ~strcmpi(get(gh.mainControls.startLoopButton, 'String'), 'Abort')
                if state.init.eom.uncagingMapper.perGrab
                    state.init.eom.uncagingMapper.position = state.init.eom.uncagingMapper.position + 1;
                    
                    %                 fprintf(1, '   UncagingMapper Position: %s\n', num2str(state.init.eom.uncagingMapper.position - 1));
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
                    
                    if state.init.eom.uncagingMapper.position > findLastValidUncagingMapperPixel
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
                     state.init.eom.uncagingPulseImporter.position = state.init.eom.uncagingPulseImporter.position + 1;
                else
                    state.init.eom.uncagingPulseImporter.position = 1;
                end

                %Update the display.
                updateGUIByGlobal('state.init.eom.uncagingPulseImporter.position');
                uncagingPulseImporter('positionText_Callback', gh.uncagingPulseImporter.positionText);
            end
        end
 
%-------------------------------------------------------------------------
function pixel = findLastValidUncagingMapperPixel
global state;

[beam, pixel, field] = ind2sub(size(state.init.eom.uncagingMapper.pixels), find(state.init.eom.uncagingMapper.pixels(:, :, :) == -1));
pixel = min(pixel(find(beam == state.init.eom.uncagingMapper.beam)));

if ~any(find(state.init.eom.uncagingMapper.pixels(state.init.eom.uncagingMapper.beam, :, :) == -1))
    pixel = size(state.init.eom.uncagingMapper.pixels, 2);
end

if isempty(pixel)
    pixel = size(state.init.eom.uncagingMapper.pixels, 2) + 1;
end

return;
