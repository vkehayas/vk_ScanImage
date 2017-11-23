function preallocateMemory(verbose)
%% function preallocateMemory
%
% This function Preallocates the appropriate memory for each acquisition mode.
%% SYNTAX
%   preallocateMemory()
%   preallocateMemory(verbose)
%       verbose: Logical value indicating, if true, to display warning info during function operation. If omitted, value assumed to be true.
%
%% MODIFICATIONS
% VI030808A Vijay Iyer 3/8/08 -- Handled case where 'Save During Acquisition' mode is active
% VI031208A Vijay Iyer 3/12/08 -- Check if acquisition time would exceed the max time allowed for buffered acquisitions, as set in standard.ini
% VI042108A Vijay Iyer 4/21/08 -- Handle out-of-memory condition more generally, by warning user and setting # of frames and slices both to 1 
% VI090908A Vijay Iyer 9/09/08 -- Ensure that acquisition parameter gets updated when resetting number of frames and slices. Only handle the standardMode case...not sure how to nicely reset when memory issues found in midst of Cycle mode.
% VI120208A Vijay Iyer 12/02/08 -- Add option to suppress warning messages, which is particularly useful for callbacks that may be invoked during configuration loading
% VI030409A Vijay Iyer 3/4/09 -- No longer prevent user from initiating a long grab without saving during acquisition. Provide a user warning though.
% VI030609A Vijay Iyer 3/6/09 -- state.init.maxBufferedGrabTime is now state.internal.maxBufferedGrabTime
% VI102609A Vijay Iyer 10/26/09 -- Remove warnings that buffered GRAB time is too long. Provide instructive message only upon actually encountering the error. 
% VI102809A Vijay Iyer 10/28/09 -- Only suggest SaveDuringAcquisition when in Standard mode..does not apply to Cycle mode.
% 
%
%% CREDITS
% Written by: Thomas Pologruto and Bernardo Sabatini
% Cold Spring Harbor Labs
% February 1, 2001
%% ****************************************************************************

global state

%%%VI120208A%%%
if nargin < 1
    verbose = true;
end
%%%%%%%%%%%%%%%

try %TPMOD 6/4/03   Correct if too large....
    state.acq.maxData = cell(1,state.init.maximumNumberOfInputChannels);
    state.acq.acquiredData = cell(1,state.init.maximumNumberOfInputChannels);
    
    for channelCounter = 1:state.init.maximumNumberOfInputChannels
        if getfield(state.acq, ['acquiringChannel' num2str(channelCounter)])			% BSMOD 1/18/2 - removed eval for channelOn
            if state.acq.numberOfZSlices == 1 || state.internal.keepAllSlicesInMemory==0 % BSMOD 1/18/2 - added or statement
                % Continuous Time Series or only saving 1 slice in memory
                if state.acq.averaging == 0 && ~state.acq.saveDuringAcquisition			% No averaging (and not saving during acq--VI030808A)
                    %%%VI102609A: Removed %%%%%%%%
                    %                     if state.acq.linesPerFrame * 1e-3 * state.acq.msPerLine * state.acq.numberOfFrames > state.internal.maxBufferedGrabTime %VI031208A, VI012109A, VI030609A
                    %                         if verbose %VI120208A
                    %                             %setStatusString('Grab too long'); %VI030409A
                    %                             beep; %VI030409A
                    %                             fprintf(2,['WARNING(' mfilename '): Number of frames may be too great for buffered (RAM) acquisition. Consider saving during acquisition and/or averaging frames.\n']); %VI030409A
                    %                         end
                    %                         %%%VI030409A: Removed %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %                         %if state.standardMode.standardModeOn %VI090908A
                    %                         %   if verbose
                    %                         %       fprintf(2,'Reset number of frames to 1.\n');
                    %                         %   end
                    %                         %   state.standardMode.numberOfFrames = 1;
                    %                         %   updateGUIByGlobal('state.standardMode.numberOfFrames');
                    %                         %   updateAcquisitionSize; %VI090908A
                    %                         %end
                    %                         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %                     else
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    
                    state.acq.acquiredData{channelCounter}=uint16(zeros(state.acq.linesPerFrame, state.acq.pixelsPerLine, 1));
                    state.acq.acquiredData{channelCounter}(:,:,state.acq.numberOfFrames)= ...
                        uint16(zeros(state.acq.linesPerFrame, state.acq.pixelsPerLine));

                elseif state.acq.averaging == 1 || state.acq.saveDuringAcquisition	% Averaging Time Series (or saving during acquisition--VI030808A)
                    state.acq.acquiredData{channelCounter}= uint16(zeros(state.acq.linesPerFrame, ...
                        state.acq.pixelsPerLine, 1));
                    
                end
                
            elseif state.acq.numberOfZSlices > 1 	% Discontinuous Z-Stack
                if state.acq.averaging == 0			% No averaging
                    %%%VI102609A: Removed %%%%%%%%%%%%%
                    %                     if state.acq.linesPerFrame * 1e-3 * state.acq.msPerLine * state.acq.numberOfFrames*state.acq.numberOfZSlices > state.internal.maxBufferedGrabTime %VI031208A, VI012109A
                    %                         if verbose %VI120208A
                    %                             setStatusString('Grab too long');
                    %                             fprintf(2,'Number of frames and/or slices too great for buffered (RAM) acquisition.  Consider saving during acquisition and/or averaging frames. \n');
                    %                         end
                    %                         if state.standardMode.standardModeOn %VI090908A
                    %                             if verbose %VI120208A
                    %                                 fprintf(2, 'Reset number of frames and slices to 1.\n');
                    %                             end
                    %                             state.standardMode.numberOfFrames = 1;
                    %                             state.standardMode.numberOfZSlices = 1;
                    %
                    %                             updateGUIByGlobal('state.standardMode.numberOfZSlices');
                    %                             updateGUIByGlobal('state.standardMode.numberOfFrames');
                    %
                    %                             updateAcquisitionSize; %VI090908A
                    %                         end
                    %                     else
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                    state.acq.acquiredData{channelCounter}=uint16(zeros(state.acq.linesPerFrame, state.acq.pixelsPerLine, 1));
                    state.acq.acquiredData{channelCounter}(:,:,state.acq.numberOfFrames*state.acq.numberOfZSlices) = ...
                        uint16(zeros(state.acq.linesPerFrame, state.acq.pixelsPerLine));

                elseif state.acq.averaging == 1 	% Averaging Z-Stack Series
                    state.acq.acquiredData{channelCounter}= uint16(zeros(state.acq.linesPerFrame, ...
                        state.acq.pixelsPerLine, 1));
                    state.acq.acquiredData{channelCounter}(:,:,state.acq.numberOfZSlices)= ...
                        uint16(zeros(state.acq.linesPerFrame, state.acq.pixelsPerLine));
                    
                end
            end
        else
            state.acq.acquiredData{channelCounter}=[];
        end			
    end
    
    if (state.acq.numberOfFrames == 1 | state.acq.averaging == 1) & state.acq.numberOfChannelsMax > 0
        state.acq.maxData = cell(1,state.init.maximumNumberOfInputChannels);
        for channelCounter = 1:state.init.maximumNumberOfInputChannels
            if getfield(state.acq, ['maxImage' num2str(channelCounter)])		% BSMOD - removed eval 
                % if statemetnt only gets executed when there is a channel to max.
                state.acq.maxData{channelCounter} = uint16(zeros(state.acq.linesPerFrame, state.acq.pixelsPerLine));
            end
        end
    end
catch%TPMOD 6/4/03   Correct if too large...
    beep; 
    
    %VI042108A -- Handle insufficient memory problems specifically and generally
    switch getfield(lasterror,'identifier')
        case 'MATLAB:nomem'
            if state.standardMode.standardModeOn %VI102809A
                if verbose %VI120208A
                    %%%VI102609A%%
                    errordlg({'Insufficient memory for intended acquisition!';...
                        'Number of slices and frames reset to 1 each.'; ...
                        '';...
                        'Consider activating ''Save During Acquisition'' feature.'},'Insufficient Memory','modal');
                    %%%%%%%%%%%%%%
                    %fprintf(2,'WARNING: Insufficient memory for intended acquisition. Number of slices and frames set to 1 instead.'); %VI102609A
                end
                state.standardMode.numberOfFrames = 1;
                state.standardMode.numberOfZSlices = 1;

                updateGUIByGlobal('state.standardMode.numberOfZSlices');
                updateGUIByGlobal('state.standardMode.numberOfFrames');

                updateAcquisitionSize; %Handle change to number of frames /and/ slices
            else
                rethrow(lasterror); %VI102809A
            end
        otherwise
            error(['Failed to preallocate memory for acquisition: ' lasterr]);
    end            
    % toggleKeepAllSlicesInMemory; %VI042108A -- don't assume problem is with # of slices as before
end
