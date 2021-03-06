function out = checkFileBeforeSave(fullFileName) 
%% function out = checkFileBeforeSave()
% This function checks if the file about to be saved already exists
% name includes extension
% out = 1 indicates user fixed problem (or no problem), out = 0 means they did not. out = [] means action was cancelled.
%
%% MODIFICATIONS
%   VI042208A Vijay Iyer 4/22/08 -- Handle case where save occurs during acquisition (included removing input argument)
%   VI050508A Vijay Iyer 5/5/08 -- Correctly read existingFiles cell array to determine if there are pre-existing files
%   VI050508B Vijay Iyer 5/5/08 -- Allow auto overwrite only when /not/ saving during acquisition
%   VI082208A Vijay Iyer 8/22/08 -- Add option to change basename and/or acquisition number, rather than only basename option
%   VI082208B Vijay Iyer 8/22/08 -- Place existing file ID into nested subfunction, so functionality can be reused. Get /all/ the existing files that match the filestem&path, so all can be cleared.
%   VI082508A Vijay Iyer 8/25/08 -- Actually recycle files as intended
%% *********************************************************

global gh state

if (state.files.automaticOverwrite || ~state.files.autoSave) && ~state.acq.saveDuringAcquisition
	out=0;
	return;
end

%exist = doesFileExist(fullname);
%exist = doesFileExist([state.files.fullFileName '.tif']) || doesFileExist(state.files.fullFileName); %Check for either directory or file (VI042208A)
    
    %Use regexp to get all files that match filestem specified in state.files.fullFileName (VI042208A)
    function exist = identifyExistingFiles() %VI082208C
        [pname,fname] = fileparts(state.files.fullFileName);
        if isempty(pname) || isempty(fname)
            existingFiles = {};
            exist = false;
        else 
            fileStruct = dir(pname); 
            fnames=cell(length(fileStruct),1); 
            [fnames{:}] = deal(fileStruct.('name'));
            
            existingFiles = {};
            exist = false;
            for i=1:length(fnames)
                newFile = regexpi(fnames{i},[fname '.*' '\.tif'],'match','once'); %VI082208B
                if ~isempty(newFile)
                    exist=true;
                    existingFiles{end+1} = newFile;
                end
            end                
            %exist = ~all(cellfun(@isempty,existingFiles)) %VI050508A
        end
    end

if identifyExistingFiles(); %VI042208A, VI082208C	
    %TO091604c - Made this message a bit more useful. - Tim O'Connor 9/16/04
    
    if state.files.automaticOverwrite && ~state.acq.saveDuringAcquisition %VI042208A, VI050508B
        button = 'Overwrite';        
    else
        button = questdlg(sprintf('File Already Exists - ''%s''.  Do you wish to:', state.files.fullFileName), ... %VI0422808A
            'Overwrite warning!',...
            'Update Filename','Overwrite', 'Cancel', 'Update Filename'); %VI082208A
    end
	switch button
        case 'Overwrite'
            %Clear out old data in advance, if to save during acquisition (VI042208A)
            if state.acq.saveDuringAcquisition
                for i=1:length(existingFiles)
                    if ~isempty(existingFiles{i})                      
                        recycleFile(fullfile(pname,existingFiles{i}));
                    end
                end
            end
            out =1 ;
        case 'Update Filename'
            oldBaseName = state.files.baseName;
            oldAcqNo = state.files.fileCounter; 
            failedUpdate = false;
   
            answer = inputdlg({'Basename:' 'Acquisition Number:'}, 'Update Basename and/or Acq Number', 1, {state.files.baseName num2str(state.files.fileCounter+1)});
            state.files.baseName = answer{1};
            state.files.fileCounter = round(str2num(answer{2}));
            
            if isempty(state.files.fileCounter) || state.files.fileCounter <= 0      
                failedUpdate = true;
                errordlg('Invalid acquisition number. Cancelling acquisition.');
            end
            
            updateFullFileName();
            if identifyExistingFiles()
                failedUpdate = true;
                errordlg('File with newly specified basename and acq. number already exists. Cancelling acquisition.');
            end

            if failedUpdate
                state.files.baseName = oldBaseName;
                state.files.fileCounter = oldAcqNo;
                updateFullFileName();
                out = [];
            else
                updateGUIByGlobal('state.files.fileCounter');
                updateGUIByGlobal('state.files.baseName');
                out = 1;
            end                                                     
%         case 'Select New Basename'
%             answer  = inputdlg('Select base name','Choose Base Name',1,{state.files.baseName});
%             if ~isempty(answer)
%                 state.files.baseName = answer{1};
%                 updateFullFileName(0);
%                 updateGUIByGlobal('state.files.baseName');
%                 out=1;
%             else
%                 out=1;
%             end
        case 'Cancel'
            out=[];
	end
else
	out=1;
end

    %VI082508A: Send file to recycle bin
    function recycleFile(file)
        status = recycle;
        recycle on;
        delete(file);
        recycle(status);        
    end


end
	
