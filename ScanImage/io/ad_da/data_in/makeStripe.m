function makeStripe(aiF, SamplesAcquired)
%% function makeStripe(aiF, SamplesAcquired)
%
% Action Function
% Called during the focusMode.m script execution.
% Takes data from data acquisition engine and formats it into a proper intensity image.
%
% This function will take the datainput from the DAQ engine and remove the data for the
% lines that are acquired.  It will then bin the matrix along the columns to produce a final 1024 x 1024 image
%
% Written by: Thomas Pologruto
% Cold Spring Harbor Labs
% January 10, 2002
%
%% MODIFICATIONS
%   VI022108A Vijay Iyer 2/21/08 - Support infinite focus mode case
%   VI022108B Vijay Iyer 2/21/08 - Add merge window handling
%   VI022708A Vijay Iyer 2/27/08 - Handle bidirectional scanning case
%   VI022708B Vijay Iyer 2/27/08 - Removed redundant lps calculation for performance
%   VI110808A Vijay Iyer 11/11/08 - Base merge data matrix on channel data that is actually being acquired
%   VI111708A Vijay Iyer 11/17/08 - Handle case where blue should be remapped to gray for merge image
%
%% 
global state
if state.internal.abortActionFunctions 
    return
end
% state.internal.stripeCounter
if state.internal.forceFirst
    state.internal.stripeCounter=0;
    state.internal.forceFirst=0;
end

inputChannelCounter = 0;

try    
%computeTime = 0; mergeTime = 0; getTime = 0;

    if state.internal.looping==1 & state.internal.stripeCounter==0;
        state.internal.secondsCounter=floor(state.internal.lastTimeDelay-etime(clock,state.internal.triggerTime));
        updateGUIByGlobal('state.internal.secondsCounter');
    end
    phaseShift=round(state.acq.cuspDelay*state.internal.samplesPerLineF);    %TPMOD
    
    if state.acq.bidirectionalScan %VI022708A
        startColumnForStripeData = round((state.internal.samplesPerLineF-state.acq.samplesAcquiredPerLine)/2)+phaseShift; %Align the collected data with the middle of each ramp      
    else
        startColumnForStripeData = round((state.internal.lineDelay*state.internal.samplesPerLineF))+phaseShift;
    end
    endColumnForStripeData = startColumnForStripeData + (state.acq.samplesAcquiredPerLine-1);
   
%tic;
    stripeFinalData = getdata(state.init.aiF, state.internal.samplesPerStripe, 'native'); % Gets enoogh data for one stripe from the DAQ engine for all channels present
    if strcmpi(whichNIDriver,'DAQmx') %Convert to a 16-bit signed integer value that had been returned in Trad NI-DAQ (VI022708A)
        stripeFinalData = uint16((stripeFinalData/state.acq.inputVoltageRange)*(2^state.acq.inputBitDepth-1)); 
    end             
%getTime = toc;
    
    if length(stripeFinalData) < state.internal.samplesPerLineF * state.acq.linesPerFrame / state.internal.numberOfStripes
        warning(sprintf('Error, data acquisition underrun. Expected to acquire %s samples, only found %s samples in the buffer.', ...
            num2str(state.internal.samplesPerLineF * state.acq.linesPerFrame / state.internal.numberOfStripes), ...
            num2str(length(stripeFinalData))));
        if state.internal.compensateForBufferUnderruns
            stripeFinalData(state.internal.samplesPerLineF * state.acq.linesPerFrame / state.internal.numberOfStripes) = 0;
            fprintf(2, 'WARNING: Padding stripe data from %s to %s with NULL values. Image should be considered corrupted.\n         To disable this behavior, set state.internal.compensateForBufferUnderruns equal to 0.\n', ...
            num2str(length(stripeFinalData) + 1), num2str(state.internal.samplesPerLineF * state.acq.linesPerFrame / state.internal.numberOfStripes));
        end
%         f = fopen('makeStripe_error.log', 'a');
%         fprintf(f, 'Error, data acquisition underrun. Expected to acquire %s samples, only found %s samples in the buffer.\r\n', ...
%             num2str(state.internal.samplesPerLineF * state.acq.linesPerFrame / state.internal.numberOfStripes), ...
%             num2str(length(stripeFinalData)));
%         fclose(f);
    end
    channelCounter = 1;
    inputChannelCounter = 0;
    
%tic;    
    for channelCounter = 1:state.init.maximumNumberOfInputChannels
        if state.internal.abortActionFunctions
            abortFocus;	
            return;
        end
        if state.internal.pauseAndRotate
            stopAndRestartFocus;
            return;
        end
        if state.acq.acquiringChannel(channelCounter)  % if statement only gets executed when there is a channel to focus.
            if getfield(state.acq, ['pmtOffsetAutoSubtractChannel' num2str(channelCounter)])
                offset=eval(['state.acq.pmtOffsetChannel' num2str(channelCounter) ...
                        '-5*state.acq.pmtOffsetStdDevChannel' num2str(channelCounter)]); % get PMT offset for channel
            else
                offset=0;
            end
            lps=state.acq.linesPerFrame/state.internal.numberOfStripes;
            ydata=[(1 + (lps*state.internal.stripeCounter)) (lps*(1 + state.internal.stripeCounter))];
            inputChannelCounter = inputChannelCounter + 1;
            
            if state.acq.bidirectionalScan  %VI022708A

                temp = reshape(stripeFinalData(:,inputChannelCounter),2*state.internal.samplesPerLineF,lps/2);                                                     
                
                if endColumnForStripeData+state.internal.samplesPerLineF > size(temp,1)
                    fprintf(2,'WARNING: Cusp (Servo) Delay value too large. Displaying blank data. (ScanImage)\n');
                    tempStripe{channelCounter} = uint16(zeros(lps,state.acq.pixelsPerLine));
                else                   
                    temp_top = temp((startColumnForStripeData):(endColumnForStripeData),:);
                    temp_bottom = flipud(temp((startColumnForStripeData+state.internal.samplesPerLineF):(endColumnForStripeData+state.internal.samplesPerLineF),:));
                    tempStripe{channelCounter} = reshape([temp_top; temp_bottom],state.acq.samplesAcquiredPerLine,lps)';

                    tempStripe{channelCounter} = add2d(tempStripe{channelCounter},state.acq.binFactor)-offset;
                end

            else
                tempStripe{channelCounter} = reshape(stripeFinalData(:, inputChannelCounter), ...
                    state.internal.samplesPerLineF,lps)';% Extracts only Channel 1 Data  %VI022708B
                
                if endColumnForStripeData > size(tempStripe{channelCounter},2)
                    beep;
                    abortFocus;
                    setstatusString('Cusp/Phase too big.');
                    return
                end
                
                %Bin samples into pixels...
                tempStripe{channelCounter} = add2d(tempStripe{channelCounter}(:, startColumnForStripeData:endColumnForStripeData), state.acq.binFactor)-offset; %add2d converts tempStripe to double format

            end            
           
     
            % Displays the current images on the screen as they are acquired.
            
            set(state.internal.imagehandle(channelCounter), 'EraseMode', 'none', 'CData', tempStripe{channelCounter}, ...
                'YData',ydata);
            state.acq.acquiredData{channelCounter}(ydata(1):ydata(2),:,1)=tempStripe{channelCounter};
        end
    end
%computeTime = toc;

    %Merge window update (VI022108B)   
    if state.acq.channelMerge
%tic;
        mergeStripe = uint8(zeros([size(tempStripe{find(state.acq.acquiringChannel,1)}) 3])); %VI111108A
        for i=1:state.init.maximumNumberOfInputChannels
            if state.acq.acquiringChannel(i)
                switch i
                    case 1
                        %Green
                        ch = 2;
                    case 2
                        %Red
                        ch = 1;
                    case 3
                        %Blue
                        ch = 3;
                    otherwise
                        error('Unexpected input channel found when creating multicolor overlay: %s', num2str(i));
                end

                mergeStripe(:,:,ch) = uint8((tempStripe{i}-state.internal.lowPixelValue(i))/(state.internal.highPixelValue(i)-state.internal.lowPixelValue(i)) * 255);
            end
        end
        
        %%%VI111708A%%%%%%%
        if state.acq.acquiringChannel(3) && state.acq.mergeBlueAsGray
            mergeStripe(:,:,1) = mergeStripe(:,:,1) + mergeStripe(:,:,3);
            mergeStripe(:,:,2) = mergeStripe(:,:,2) + mergeStripe(:,:,3);
        end
        %%%%%%%%%%%%%%%%%%%%
        
        set(state.internal.mergeimage,'EraseMode','none','CData',mergeStripe,'YData',ydata);
%mergeTime = toc;
    end

   
    drawnow;    
%*****************************************************
%  Uncomment for benchmarking.....
%     state.time=[state.time etime(clock,state.testtime)];
%     state.testtime=clock;
%******************************************************* 
    if ~state.internal.abortActionFunctions
        state.internal.stripeCounter = state.internal.stripeCounter + 1; % increments the stripecounter to ensure proper image displays    
    end
    if state.internal.abortActionFunctions
        state.internal.stripeCounter=0;
        abortFocus;	
        return;
    end
    if state.internal.pauseAndRotate
        state.internal.stripeCounter=0;
        stopAndRestartFocus;
        return;
    end
    if  state.internal.stripeCounter == state.internal.numberOfStripes	
        state.internal.stripeCounter = 0;
        state.internal.focusFrameCounter = state.internal.focusFrameCounter + 1;
    end
    
    if state.internal.focusFrameCounter + 1 == state.internal.numberOfFocusFrames && ~state.acq.infiniteFocus %VI022108A
        state.internal.stripeCounter=0;
        endFocus; 
    end
    if state.internal.abortActionFunctions
        state.internal.stripeCounter=0;
        abortFocus;	
        return;
    end
    if state.internal.pauseAndRotate
        state.internal.stripeCounter=0;
        stopAndRestartFocus;
        return;
    end
    
%fprintf(1,'GetTime=%05.2f \t ComputeTime=%05.2f \t MergeTime=%05.2f \t \n',1000*getTime,1000*computeTime,1000*mergeTime);    
    
catch
    if state.internal.abortActionFunctions
        return
    end
    disp('makeStripe: Error in try');
    warning(lasterr);
%     f = fopen('makeStripe_error.log', 'a');
%     fprintf(f, 'Attempted reshape - stripeFinalData [%s] into [%s x %s]\r\n state.internal.samplesPerLineF: %s\r\n state.acq.linesPerFrame: %s\r\n state.internal.numberOfStripes: %s\r\n\r\n', ...
%         num2str(size(stripeFinalData)), num2str(state.internal.samplesPerLineF), ...
%         num2str(state.acq.linesPerFrame/state.internal.numberOfStripes), num2str(state.internal.samplesPerLineF), ...
%         num2str(state.acq.linesPerFrame), num2str(state.internal.numberOfStripes));
%     fclose(f);
    
    fprintf(2, 'Attempted reshape - stripeFinalData [%s] into [%s x %s]\n state.internal.samplesPerLineF: %s\n state.acq.linesPerFrame: %s\nstate.internal.numberOfStripes: %s\n\n', ...
        num2str(size(stripeFinalData(:, inputChannelCounter))), num2str(state.internal.samplesPerLineF), ...
        num2str(state.acq.linesPerFrame/state.internal.numberOfStripes), num2str(state.internal.samplesPerLineF), ...
        num2str(state.acq.linesPerFrame), num2str(state.internal.numberOfStripes));
end