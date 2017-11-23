function toggleAutomaticOverwrite
% BSMOD - 1/1/2 - callback when user selects 'autoSave' from 'settings' menu

    global gh state
	% get the index of the standard mode selection of the settings menu
	children=get(gh.mainControls.Settings, 'Children');			
	index=getPullDownMenuIndex(gh.mainControls.Settings, 'Automatic overwrite');
	
	checkState=get(children(index), 'Checked'); % check state of check mark nexted to 'autosave' option

    if strcmp(checkState,'on')     % it is on, so turn it off
        state.files.automaticOverwrite=0;
    else
        state.files.automaticOverwrite=1;
    end
    
    updateAutoOverwriteCheckMark;
    
       