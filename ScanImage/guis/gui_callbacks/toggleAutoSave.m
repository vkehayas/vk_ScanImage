function toggleAutoSave
% BSMOD - 1/1/2 - callback when user selects 'autoSave' from 'settings' menu
%% CHANGES
%   VI091608A: Dispatch callback via updateGUIByGlobal, which also ensures that other controls are updated -- Vijay Iyer 9/16/08

    global gh state
	% get the index of the standard mode selection of the settings menu
	children=get(gh.mainControls.Settings, 'Children');			
	index=getPullDownMenuIndex(gh.mainControls.Settings, 'Auto save');
	
	checkState=get(children(index), 'Checked'); % check state of check mark nexted to 'autosave' option

    if strcmp(checkState,'on')     % it is on, so turn it off
        state.files.autoSave=0;
    else
        state.files.autoSave=1;
    end
    
    updateGUIByGlobal('state.files.autoSave','Callback',1); %VI091608A
    %updateAutoSaveCheckMark;
    
       