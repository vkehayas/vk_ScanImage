function standardModeMenuSelection
% called when user selects or deselects standard mode from the menu
	global state
	
	state.standardMode.standardModeOn=1-state.standardMode.standardModeOn;
    updateSaveDuringAcq; %VI091608A
	applyModeCycleAndConfigSettings;
	