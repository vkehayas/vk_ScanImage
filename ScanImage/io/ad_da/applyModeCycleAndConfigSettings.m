function applyModeCycleAndConfigSettings
% Ensures that acquisition program is in the state described by current configuration and mode settings

	global gh state
	% get the index of the standard mode selection of the settings menu
	children=get(gh.mainControls.Settings, 'Children');			
	index=getPullDownMenuIndex(gh.mainControls.Settings, 'Standard Cycle Mode');
	
	if state.standardMode.standardModeOn==0			% a user defined cycle is being used
		set(children(index), 'Checked', 'off');	% turn off the check mark next to 'Standard Mode'
												% in the settings menu
		hideGUI('gh.standardModeGUI.figure1');	% hide the standard mode window
		seeGUI('gh.cycleControls.figure1');				% activate the cycle controls window

		% activate the appropriate menus
		turnonPullDownMenu(gh.mainControls.Settings, 'Edit Cycle...');
		turnonPullDownMenu(gh.mainControls.File, 'Load Cycle...');
		turnonPullDownMenu(gh.mainControls.File, 'Save Cycle');		
		turnonPullDownMenu(gh.mainControls.File, 'Save Cycle As...');
		turnoffPullDownMenu(gh.mainControls.File, 'Display Cycle');
		turnoffPullDownMenu(gh.mainControls.File, 'Load Configuration...');
		turnoffPullDownMenu(gh.mainControls.File, 'Save Configuration');
		turnoffPullDownMenu(gh.mainControls.File, 'Save Configuration As...');

		% activate fields in the mainControls window that describe a cycle
		seeGUI('gh.mainControls.cycleName');
		seeGUI('gh.mainControls.cycleNameTag');
		seeGUI('gh.mainControls.repeatsTotal');
		seeGUI('gh.mainControls.repeatsDoneOf');
		seeGUI('gh.mainControls.positionToExecuteSlider');
		seeGUI('gh.mainControls.cyclePosition');
		seeGUI('gh.mainControls.cyclePositionText');

		state.configName='';
		state.configPath='';
		
		applyCyclePositionSettings;
	else										% standard mode is being used
		set(children(index), 'Checked', 'on');	% turn on the check mark next to 'Standard Mode'
												% in the settings menu
		hideGUI('gh.cycleControls.figure1');				% hide the cycle controls window
		seeGUI('gh.standardModeGUI.figure1');		% activate the standard mode window

		% activate the appropriate menus
		turnoffPullDownMenu(gh.mainControls.Settings, 'Edit Cycle...');
		turnoffPullDownMenu(gh.mainControls.File, 'Load Cycle...');
		turnoffPullDownMenu(gh.mainControls.File, 'Save Cycle');		
		turnoffPullDownMenu(gh.mainControls.File, 'Save Cycle As...');
		turnoffPullDownMenu(gh.mainControls.File, 'Display Cycle');
		turnonPullDownMenu(gh.mainControls.File, 'Load Configuration...');
		turnonPullDownMenu(gh.mainControls.File, 'Save Configuration');
		turnonPullDownMenu(gh.mainControls.File, 'Save Configuration As...');

		% hide fields in the mainControls window that describe a cycle
		hideGUI('gh.mainControls.cycleName')
		hideGUI('gh.mainControls.cycleNameTag')
		hideGUI('gh.mainControls.repeatsTotal');
		hideGUI('gh.mainControls.repeatsDoneOf');
		hideGUI('gh.mainControls.positionToExecuteSlider');
		hideGUI('gh.mainControls.cyclePosition');
		hideGUI('gh.mainControls.cyclePositionText');

		state.internal.repeatsTotal=[]; %VI110209A: Use empty value, rather than 1e9 to signal that value does not pertain in Standard mode
		loadStandardModeConfig;		% load the appropriate configuration
	end
	