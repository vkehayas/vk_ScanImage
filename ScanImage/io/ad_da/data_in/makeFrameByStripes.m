function makeFrameByStripes(ai, SamplesAcquired)
%% function makeFrameByStripes(ai, SamplesAcquired)
% Data Acquisition (SamplesAcquired) Action Function
% Used with the contMode.m script to update frames on the screen after each frame.
% Takes data from data acquisition engine and formats it into a proper intensity image.
%
% This function will take the datainput from the DAQ engine and remove the data for the
% lines that are acquired.  It will then bin the matrix along the columns to produce a final image
% 
% The image will update every frame on the screen as data is recorded.
% The data is stored in the cell array state.acq.acquiredData{X}(:,:,frames)(X = 1,2,3...) 
% , where X is the channel Acquired the frames are indexed in the third dimension.
% 
% This action function also handles averaging over frames.

%% MODIFICATIONS
%   VI022808A Vijay Iyer 2/28/08 - Add in merge channel handling
%   VI022908A Vijay Iyer 2/29/08 - Handle the DAQmx case where doubles, rather than int16 values, are obtained by getdata()
%   VI030408A Vijay Iyer 3/04/08 - Handle bidirectional scanning case
%   VI030708A Vijay Iyer 3/07/08 - Handle in-acquisition data saving
%   VI041308A Vijay Iyer 4/13/08 - Stop trigger timer upon entering, if needed
%   VI041308B Vijay Iyer 4/13/08 - Use entrance into this callback as 'sign' that data is being acquired
%   VI042108A Vijay Iyer 4/21/08 - Made various mlint changes to improve performance
%   VI042208A Vijay Iyer 4/22/08 - Get and convert data in one step...slight performance improvement
%   VI042208B Vijay Iyer 4/22/08 - Handle several things only on first frame...
%   VI042208C Vijay Iyer 4/22/08 - Directly update uicontrols, rather than going through updateGUIByGlobal
%   VI043008A Vijay Iyer 4/30/08 - Turn off merge update if merge specified for Focus-only
%   VI071108A Vijay Iyer 7/11/08 - Implement VI043008A in case of averaging
%   VI071108B Vijay Iyer 7/11/08 - Correct type issue that had caused incorrect merge calculation
%   VI101008A Vijay Iyer 10/10/08 - Attempt intra-stack MP285 reset to allow graceful recovery during stack collection
%   VI101508A Vijay Iyer 10/15/08 - Use new MP285RobustAction for startMoveStackFocus action
%   VI110308A Vijay Iyer 11/03/08 - Set the dioTriggerTime on first encounter of this callback, for case of external trigger
%   VI110308B Vijay Iyer 11/03/08 - Constrain loop timer to only positive values, and use rounding for 'smoother' countdown 
%   VI110408A Vijay Iyer 11/04/08 - Only use count-down timer (vs. count-up timer) for looped acquisitions which do not employ external trigger
%   VI110808A Vijay Iyer 11/08/08 - Don't try to save data during acquisition if snapping
%   VI111108A Vijay Iyer 11/11/08 - Base merge data matrix on channel data that is actually being acquired
%   VI111708A Vijay Iyer 11/17/08 - Handle case where blue should be remapped to gray for merge image
%   VI070109A Vijay Iyer 7/15/09 - Move logic specific to first stripe to acquisitionStartedFcn
%   VI102709A Vijay Iyer 10/27/09 - Use state.internal.repeatPeriod for determining countdown time in midst of acquisition 
%   VI102909A Vijay Iyer 10/29/09 - Use the stack trigger time, rather than the individual acquisition trigger time, for countdown/countup timer display
%% ******************************************************************************************
global state gh

%drawTime = 0; mergeTime = 0; writeTime =0; getTime = 0;

%%%VI070109A: Moved to acquisitionStartedFcn()%%%%%
%Stop trigger timer, if running (VI041308A)
%if ~isempty(state.internal.triggerTimer) && strcmpi(get(state.internal.triggerTimer,'Running'),'on')
%    stop(state.internal.triggerTimer);
%    state.internal.dioTriggerTime = clock; %VI110308A
%end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Write complete header string  for only the first frame
if state.internal.abortActionFunctions
    abortInActionFunction;
    return
end

if state.internal.forceFirst
    state.internal.stripeCounter=0;
    state.internal.forceFirst=0;
end
if state.shutter.shutterOpen==0
    if all(state.shutter.shutterDelayVector==[state.internal.frameCounter state.internal.stripeCounter])
        openShutter;
    end
end
if state.internal.stripeCounter==0
    %%%VI070109A: Moved to acquisitionStartedFcn() %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %if state.internal.frameCounter==1 && state.internal.zSliceCounter == 0 
    %    getTriggerTime;
    %    updateHeaderString('state.internal.triggerTimeString');
    %    updateHeaderString('state.internal.triggerTimeInSeconds');
    %    
    %    %Do the following /only/ the first time through (VI042208B)
    %    setStatusString('Acquiring...'); %VI041308B   
    %end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


    if state.internal.looping==1 && ~state.acq.externallyTriggered %VI110408A %count-down timer
        state.internal.secondsCounter=max(round(state.internal.repeatPeriod-etime(clock,state.internal.stackTriggerTime)),0); %VI102909A %VI102709A %VI110308B
    else %count-up timer
        state.internal.secondsCounter=floor(etime(clock,state.internal.stackTriggerTime)); %VI102909A
    end
    %updateGUIByGlobal('state.internal.secondsCounter');
    set(gh.mainControls.secondsCounter,'String',num2str(state.internal.secondsCounter));        
    
end

try
    if state.internal.frameCounter == state.acq.numberOfFrames && state.internal.stripeCounter==state.internal.numberOfStripes-1 %This should be the last time through this callback
        closeShutter;
        stopGrab;
        if state.acq.numberOfZSlices > 1
            if MP285RobustAction(@startMoveStackFocus, 'move to next slice in stack', mfilename) %VI101508A
                abortCurrent;
                return;
            end
        end
    end

    if state.internal.abortActionFunctions
        abortInActionFunction;
        return
    end

    lps=state.acq.linesPerFrame/state.internal.numberOfStripes;
    startLine =1 + state.internal.stripeCounter*lps ;
    stopLine= startLine+lps-1;

    if state.acq.averaging == 0 || state.acq.numberOfFrames == 1 % If not averaging....
        if state.acq.saveDuringAcquisition %VI030708A
            position=1; %keep only one frame at a time..
        else
            if state.internal.keepAllSlicesInMemory
                position =(state.internal.frameCounter + state.internal.zSliceCounter*state.acq.numberOfFrames);
            else
                position = state.internal.frameCounter;
            end
        end
        phaseShift=round(state.acq.cuspDelay*state.internal.samplesPerLine);    %TPMOD
        
        if state.acq.bidirectionalScan %VI030408A
            startColumnForFrameData = round((state.internal.samplesPerLineF-state.acq.samplesAcquiredPerLine)/2)+phaseShift; %Align the collected data with the middle of each ramp
        else
            startColumnForFrameData = round((state.internal.lineDelay*state.internal.samplesPerLineF))+phaseShift;
        end
        endColumnForFrameData = startColumnForFrameData + (state.acq.samplesAcquiredPerLine-1);
        %frameFinalData = getdata(state.init.ai, state.internal.samplesPerFrame/state.internal.numberOfStripes, 'native'); % Gets enoogh data for one frame from the DAQ engine for all channels present
        if strcmpi(state.internal.niDriver,'DAQmx') %Convert to a 16-bit unsigned integer value that had been returned in Trad NI-DAQ (VI022908A) 
            %tic;
            frameFinalData = uint16((getdata(state.init.ai, state.internal.samplesPerFrame/state.internal.numberOfStripes, 'native')/state.acq.inputVoltageRange)*(2^state.acq.inputBitDepth-1)); %VI042208A
            %getTime = toc;
            %frameFinalData = uint16((frameFinalData/state.acq.inputVoltageRange)*(2^state.acq.inputBitDepth-1));
        else
            frameFinalData = getdata(state.init.ai, state.internal.samplesPerFrame/state.internal.numberOfStripes, 'native'); % Gets enoogh data for one frame from the DAQ engine for all channels present
        end
        inputChannelCounter = 0;
        if state.internal.abortActionFunctions
            abortInActionFunction;
            return
        end

        for channelCounter = 1:state.init.maximumNumberOfInputChannels
            if state.acq.acquiringChannel(channelCounter) % if statemetnt only gets executed when there is a channel to acquire.
                inputChannelCounter = inputChannelCounter + 1;
                if getfield(state.acq, ['pmtOffsetAutoSubtractChannel' num2str(channelCounter)])
                    offset=eval(['state.acq.pmtOffsetChannel' num2str(channelCounter) ...
                        '-5*state.acq.pmtOffsetStdDevChannel' num2str(channelCounter)]); % get PMT offset for channel
                else
                    offset=0;
                end

                if state.acq.bidirectionalScan %VI030408A
                    temp = reshape(frameFinalData(:,inputChannelCounter),2*state.internal.samplesPerLineF,lps/2);
                    temp_top = temp((startColumnForFrameData):(endColumnForFrameData),:);
                    temp_bottom = flipud(temp((startColumnForFrameData+state.internal.samplesPerLineF):(endColumnForFrameData+state.internal.samplesPerLineF),:));
                    tempImage{channelCounter} = reshape([temp_top; temp_bottom],state.acq.samplesAcquiredPerLine,lps)';
                    
                    state.acq.acquiredData{channelCounter}(startLine:stopLine,:,position) = add2d(tempImage{channelCounter},state.acq.binFactor)-offset;                    
                else                
                    tempImage = reshape(frameFinalData(:,inputChannelCounter), state.internal.samplesPerLine, lps)'; 	% Converts data into proper shape for frame
                    state.acq.acquiredData{channelCounter}(startLine:stopLine,:,position) ...
                        = add2d(tempImage(:, startColumnForFrameData:endColumnForFrameData), state.acq.binFactor) ...
                        -offset; 	% Removes unwanted Data
                end

                % Displays the current images on the screen as they are acquired.
                channelImageOn = eval(['state.acq.imagingChannel' num2str(channelCounter)]);
                if channelImageOn
                    %tic;
                    set(state.internal.imagehandle(channelCounter), 'EraseMode', 'none', 'CData', ...
                        state.acq.acquiredData{channelCounter}(startLine:stopLine,:,position), 'YData', [startLine stopLine]);
                    %drawTime = toc;
                end
            end
        end

        if state.acq.channelMerge && ~state.acq.mergeFocusOnly %VI022808A, VI043008A
            %tic;
            makeMergeStripe(state.acq.acquiredData,[startLine stopLine],position);
            %mergeTime = toc;
        end

        drawnow;
        state.internal.stripeCounter = state.internal.stripeCounter + 1;

        if state.internal.stripeCounter == state.internal.numberOfStripes %finished a frame!
            
            %VI030708A -- Write data 
            if state.acq.saveDuringAcquisition && ~state.internal.snapping %VI110808A 
                %tic;
                writeData;
                %writeTime = toc;
            end                             
                
            if state.internal.frameCounter == state.acq.numberOfFrames
                %updateGUIByGlobal('state.internal.frameCounter'); 
                set(gh.mainControls.framesDone,'String',num2str(state.internal.frameCounter)); %VI042208C
                state.internal.stripeCounter = 0;
                endAcquisition; 	% ResumeLoop, parkLaser, Close Shutter, appendData, reset counters,...
            else
                state.internal.stripeCounter = 0;
                state.internal.frameCounter = state.internal.frameCounter + 1;	% Increments the frameCounter to ensure proper image storage and display
                %updateGUIByGlobal('state.internal.frameCounter');	% Updates the frame Counter on the main controls GUI.
                set(gh.mainControls.framesDone,'String',num2str(state.internal.frameCounter)); %VI042208C
            end
        end

    else % If averaging....

        if state.internal.frameCounter == 1 && state.internal.stripeCounter==0
            state.internal.tempImage = cell(1, state.init.maximumNumberOfInputChannels);
            currenttempImage = []; %cell(1, state.init.maximumNumberOfInputChannels);
        end

        if state.internal.keepAllSlicesInMemory
            position = state.internal.zSliceCounter + 1;
        else
            position = 1;
        end
        phaseShift=round(state.acq.cuspDelay*state.internal.samplesPerLine);    %TPMOD
        
        if state.acq.bidirectionalScan %VI030408A
            startColumnForFrameData = round((state.internal.samplesPerLineF-state.acq.samplesAcquiredPerLine)/2)+phaseShift; %Align the collected data with the middle of each ramp
        else
            startColumnForFrameData = round((state.internal.lineDelay*state.internal.samplesPerLineF))+phaseShift;
        end
        endColumnForFrameData = startColumnForFrameData + (state.acq.samplesAcquiredPerLine-1);
        frameFinalData = getdata(state.init.ai, state.internal.samplesPerFrame/state.internal.numberOfStripes, 'native'); % Gets enoogh data for one frame from the DAQ engine for all channels present
        if strcmpi(state.internal.niDriver,'DAQmx') %Convert to a 16-bit signed integer value that had been returned in Trad NI-DAQ (VI022908A) 
            frameFinalData = uint16((frameFinalData/state.acq.inputVoltageRange)*(2^state.acq.inputBitDepth-1));
        end
        if state.internal.abortActionFunctions
            abortInActionFunction;
            return
        end

        inputChannelCounter = 0;

        for channelCounter = 1:state.init.maximumNumberOfInputChannels
            if state.acq.acquiringChannel(channelCounter) % if statemetnt only gets executed when there is a channel to acquire.

                inputChannelCounter = inputChannelCounter + 1;
                if getfield(state.acq, ['pmtOffsetAutoSubtractChannel' num2str(channelCounter)])
                    offset=eval(['state.acq.pmtOffsetChannel' num2str(channelCounter) ...
                        '-5*state.acq.pmtOffsetStdDevChannel' num2str(channelCounter)]); % get PMT offset for channel
                else
                    offset=0;
                end
                
                if state.acq.bidirectionalScan %VI030408A
                    temp = reshape(frameFinalData(:,inputChannelCounter),2*state.internal.samplesPerLineF,lps/2);
                    temp_top = temp((startColumnForFrameData):(endColumnForFrameData),:);
                    temp_bottom = flipud(temp((startColumnForFrameData+state.internal.samplesPerLineF):(endColumnForFrameData+state.internal.samplesPerLineF),:));
                    currenttempImage = reshape([temp_top; temp_bottom],state.acq.samplesAcquiredPerLine,lps)';
                    
                    currenttempImage = add2d(currenttempImage,state.acq.binFactor)-offset;                       
                    
                else
                    currenttempImage = reshape(frameFinalData(:,inputChannelCounter), state.internal.samplesPerLine, lps)'; 	% Converts data into proper shape for frame
                    currenttempImage = add2d(currenttempImage(:, startColumnForFrameData:endColumnForFrameData), state.acq.binFactor) ...
                        -offset; 	% Removes unwanted Data
                end

                % Displays the current images on the screen as they are acquired.

                if state.internal.frameCounter == 1
                    state.internal.tempImage{channelCounter}(startLine:stopLine,:) = double(currenttempImage);
                elseif state.internal.frameCounter > 1 % & state.internal.frameCounter <= state.acq.numberOfFrames
                    state.internal.tempImage{channelCounter}(startLine:stopLine,:) ...
                        = ((state.internal.frameCounter - 1)*state.internal.tempImage{channelCounter}(startLine:stopLine,:) ...
                        + double(currenttempImage))/(state.internal.frameCounter);
                end

                % Displays the current images on the screen as they are acquired.
                channelImageOn = eval(['state.acq.imagingChannel' num2str(channelCounter)]);
                if channelImageOn
                     set(state.internal.imagehandle(channelCounter), 'EraseMode', 'none', 'CData', ...
                         state.internal.tempImage{channelCounter}(startLine:stopLine,:), 'YData', [startLine stopLine]);
                end
            end
        end

       % if state.acq.channelMerge %VI022808A
        if state.acq.channelMerge && ~state.acq.mergeFocusOnly %VI071108A
            makeMergeStripe(state.internal.tempImage,[startLine stopLine],1);
        end

        drawnow;
        state.internal.stripeCounter = state.internal.stripeCounter+1;

        if state.internal.frameCounter == state.acq.numberOfFrames && state.internal.stripeCounter == state.internal.numberOfStripes
            for channelCounter = 1:state.init.maximumNumberOfInputChannels
                state.acq.acquiredData{channelCounter}(:,:,position) = uint16(state.internal.tempImage{channelCounter});
            end
            state.internal.stripeCounter = 0;
            %updateGUIByGlobal('state.internal.frameCounter');
            set(gh.mainControls.framesDone,'String',num2str(state.internal.frameCounter)); %VI042208C
            endAcquisition;% ResumeLoop, parkLaser, Close Shutter, appendData, reset counters,...
        elseif state.internal.stripeCounter == state.internal.numberOfStripes;
            state.internal.stripeCounter = 0;
            state.internal.frameCounter = state.internal.frameCounter + 1;	% Increments the frameCounter to ensure proper image storage and display
            %updateGUIByGlobal('state.internal.frameCounter');	% Updates the frame Counter on the main controls GUI.
            set(gh.mainControls.framesDone,'String',num2str(state.internal.frameCounter)); %VI042208C
        end
    end
    
    %toc
    %disp(['Get Time=' num2str(getTime) '; DrawTime=' num2str(drawTime) ';MergeTime=' num2str(mergeTime) '; WriteTime=' num2str(writeTime)]);
    %fprintf(1,'GetTime=%05.2f \t DrawTime=%05.2f \t MergeTime=%05.2f \t WriteTime=%05.2f \n',1000*getTime,1000*drawTime,1000*mergeTime, 1000*writeTime);
catch
    if state.internal.abortActionFunctions
        abortInActionFunction;
        return
    else
        setStatusString('Error in frame by stripes');
        disp('makeFrameByStripes: Error in action function');
        %disp(lasterr);
        disp(getLastErrorStack);
    end
end
    
%Paints a stripe of color-merged data based on the imageData at
function makeMergeStripe(imageData,yData,posn)

global state

yMask = yData(1):yData(2);

if state.internal.stripeCounter == 0 && state.internal.frameCounter == 1 %VI042208B
    state.internal.mergeStripe = uint8(zeros([length(yMask) size(imageData{find(state.acq.acquiringChannel,1)},2) 3])); %VI111108A
end

for i=1:state.init.maximumNumberOfInputChannels
    if state.acq.acquiringChannel(i)
        switch i
            case 1 %Green
                ch = 2;
            case 2 %Red
                ch = 1;
            case 3 %Blue
                ch = 3;
            otherwise
                error('Unexpected input channel found when creating multicolor overlay: %s', num2str(i));
        end
%         if ~isfloat(imageData{i})
%             imageData{i} = double(imageData{i});
%         end
        
        state.internal.mergeStripe(:,:,ch) = uint8((double(imageData{i}(yMask,:,posn))-state.internal.lowPixelValue(i))/(state.internal.highPixelValue(i)-state.internal.lowPixelValue(i)) * 255); %VI071108B
    end
end

%%%VI111708A%%%%%%%
if state.acq.acquiringChannel(3) && state.acq.mergeBlueAsGray
    state.internal.mergeStripe(:,:,1) = state.internal.mergeStripe(:,:,1) + state.internal.mergeStripe(:,:,3);
    state.internal.mergeStripe(:,:,2) = state.internal.mergeStripe(:,:,2) + state.internal.mergeStripe(:,:,3);
end
%%%%%%%%%%%%%%%%%%%%

set(state.internal.mergeimage,'EraseMode','none','CData',state.internal.mergeStripe,'YData',yData);




	
