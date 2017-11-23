function writeData
%% function writeData
% Function that searches through all the channels and sees which to save.
% It then will save the acquired Data from the global state.acq.acquiredData{i} (i = 1:numberOFChannels)
% as tif files.  
% The images are interleaved....They are stored as frame 1, Channel 1, frame 1, Channel 2, ....
% frame 2, channel 1, frame 2, channel 2, ....and Z-slice stacks are stored one after the other.
%
% Each new Z-slice has the string header state.headerString stored in the tif header under the 
% field ImageDescription.
%
% Written By: Bernardo Sabatini and Thomas Pologruto
% Cold Spring Harbor Labs
% Februarry 1, 2001

%% MODIFICATIONS
%   VI030708A Vijay Iyer 3/7/08 -- Handled the case of saving during acquisition (for long grabs)
%   VI031108A Vijay Iyer 3/11/08 -- Handled case where 'Frames/File' is infinite
%   VI041808A Vijay Iyer 4/18/08 -- Number files with up to 3 leading zeros
%   VI050708A Vijay Iyer 5/7/08 -- (Slightly) optimize the writing by bypassing the imwrite() function, and using the imageWriter function directly
%
%% ***************************************************************************

global state

% Make the file name witht the tif extension
fileName = [state.files.fullFileName '.tif'];

if state.internal.zSliceCounter == 0
    first = 1;
else
    first = 0;
end
% If we are averaging, then there is only 1 frame per Z-Slice
if state.acq.averaging
    numberOfFrames = 1;
else  % If we are not averaging,, there are state.acq.numberOfFrames per slice
    numberOfFrames = state.acq.numberOfFrames;
end

if state.internal.keepAllSlicesInMemory
    startingFrame=state.internal.zSliceCounter*numberOfFrames;
else
    startingFrame=0;
end

if state.acq.saveDuringAcquisition %VI030708A
    %Check to see if it's time to start a new file (i.e. a new frame chunk)
    if ~isinf(state.acq.framesPerFile) && mod(state.internal.frameCounter,state.acq.framesPerFile)==1 && state.internal.frameCounter > state.acq.framesPerFile 
        close(state.files.tifStream);
        fileChunkCounter = ceil(state.internal.frameCounter/state.acq.framesPerFile);
        fileName  = [state.files.fullFileName '_' num2str(fileChunkCounter,'%03d') '.tif'];
        state.files.tifStream = scim_tifStream(fileName,state.acq.pixelsPerLine, state.acq.linesPerFrame, state.headerString);       
    end
        
    %Append this frame's data to the current stream
    for channelCounter = 1:state.init.maximumNumberOfInputChannels % Loop through all the channels
        if ~isempty(state.acq.acquiredData{channelCounter}(:,:,1))
            appendFrame(state.files.tifStream,state.acq.acquiredData{channelCounter}(:,:,1));
        end
    end
    
    
%    if ~isinf(state.acq.framesPerFile) %VI031108A
%        fileChunkCounter = ceil((state.internal.frameCounter)/state.acq.framesPerFile);
%        fileName  = [state.files.fullFileName '_' num2str(fileChunkCounter,'%03d') '.tif']; %VI041808A
%    else
%        fileName = [state.files.fullFileName '.tif'];
%    end
%    
%    for channelCounter = 1:state.init.maximumNumberOfInputChannels % Loop through all the channels
%        if getfield(state.acq, ['savingChannel' num2str(channelCounter)]) % If saving..
% %           imwrite(uint16(state.acq.acquiredData{channelCounter}(:,:,1)),fileName,'WriteMode','append','Compression','none','Description',state.headerString);
% %           imwrite(uint16(state.acq.acquiredData{channelCounter}(:,:,1)),fileName,'WriteMode','append');
%             feval(state.internal.imageWriter, uint16(state.acq.acquiredData{channelCounter}(:,:,1)),[],fileName,'WriteMode','append','Description',state.headerString,'Compression','none'); %VI050708A 
%        end
%    end
%    
else
    for frameCounter=1:numberOfFrames % Loop through all the frames
        for channelCounter = 1:state.init.maximumNumberOfInputChannels % Loop through all the channels
            if getfield(state.acq, ['savingChannel' num2str(channelCounter)]) % If saving..
                if first % if its the first frame of first channel, then overwrite...
                    imwrite(state.acq.acquiredData{channelCounter}(:,:,frameCounter + startingFrame) ...
                        , fileName,  'WriteMode', 'overwrite', 'Compression', 'none', 'Description', state.headerString);
                    first = 0;
                else
                    imwrite(state.acq.acquiredData{channelCounter}(:,:,frameCounter + startingFrame) ...
                        , fileName,  'WriteMode', 'append', 'Compression', 'none');
                end
            end
        end
    end
end
