function editCycle
	global gh state
	if state.standardMode.standardModeOn==1
		seeGUI('gh.standardModeGUI.figure1');
	else
		seeGUI('gh.cycleControls.figure1');
	end
