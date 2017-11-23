function saveLastAcquisitionAs
%% function saveLastAcquisitionAs
% Saves the current data in memory to disk. 
%
%% NOTES
% Can be accessed by selecting CTRL+S from Main Controls Window.
%
%% CHANGES
% TPMOD_1: Modified 12/31/03 Tom Pologruto - Fixed the status string updates.
% VI071608A Vijay Iyer 7/16/08 -- Fix the '.tif.tif' problem, which appears in newer Matlab versions because behavior of uiputfile has changed
% VI091508A Vijay Iyer 9/15/08 -- Ensure that files are saved in the selected directory, not the state.files.savePath directory
% VI091508B VIjay Iyer 9/15/08 -- Display name of saved file correctly
%% ************************************************************

global state gh
% Make the file name witht the tif extension
stat=state.internal.statusString;
setStatusString('Saving Last Acq As...');
if isdir(state.files.savePath)
    cd(state.files.savePath);
end
[fname, pname]=uiputfile('*.tif', 'Choose File name...');

if isnumeric(fname)
    setStatusString(stat);
    return
else
    %%%VI071608A -- only append '.tif' if needed
    [f,p,ext] = fileparts(fname);
    if isempty(ext)
        fileName=[pname fname '.tif'];
    else
        fileName = fullfile(pname,fname); %VI091508A
    end
    %%%%%%%%%
end
for channelCounter = 1:state.init.maximumNumberOfInputChannels % Loop through all the channels
    if getfield(state.acq, ['acquiringChannel' num2str(channelCounter)]) % If acquiring..
        numberOfFrames = size(state.acq.acquiredData{channelCounter},3);
    end
end
first=1;
for frameCounter=1:numberOfFrames % Loop through all the frames
    for channelCounter = 1:state.init.maximumNumberOfInputChannels % Loop through all the channels
        if getfield(state.acq, ['acquiringChannel' num2str(channelCounter)]) % If acquiring..
            if first % if its the first frame of first channel, then overwrite...
                imwrite(state.acq.acquiredData{channelCounter}(:,:,frameCounter) ... % BSMOD 1/18/2
                    , fileName,  'WriteMode', 'overwrite', 'Compression', 'none', 'Description', state.headerString);
                first = 0;
            elseif ~all(all(state.acq.acquiredData{channelCounter}(:,:,frameCounter)==0))
                imwrite(state.acq.acquiredData{channelCounter}(:,:,frameCounter) ... % BSMOD 1/18/2
                    , fileName,  'WriteMode', 'append', 'Compression', 'none');
            end	
        end
    end
end
disp(['File ' fileName ' saved.']); %VI091508B
setStatusString(stat);