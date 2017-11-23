function applyCyclePositionSettings(position)
% takes settings of current cycle position and applies them

	global state gh
	
	if nargin<1
		position=state.internal.positionToExecute;
	end
	
	if position>state.cycle.length | position<1
		disp('makeCyclePositionCurrent: Attempted to load position of out range. Position 1 loaded');
		position=1;
	end
	
	state.internal.positionToExecute=position;
	
	reload=0;
	if ~strcmp(state.configName, state.cycle.cycleParts{position}) | ...
		(~isempty(state.configPath) & ~strcmp(state.configPath, state.cycle.cyclePaths{position}))
		reload=1;
	end

	if isempty(state.cycle.cycleParts{position})
		reload=0;
	else
		state.configName=state.cycle.cycleParts{position};
		state.configPath=state.cycle.cyclePaths{position};
	end
	
	if isempty(state.configName)
		setStatusString('Select a config');
		disp('makeCyclePositionCurrent: No configuration selected.  Please select one');
		return
	end
	
	if reload 
		loadCycleModeConfig;
		applyChannelSettings;
	else	
		state.internal.repeatsTotal=state.cycle.cycleRepeats(position);
		%state.internal.secondsCounter=state.cycle.cycleTimeDelay(position); %VI102809A: Removed
		state.acq.returnHome=state.cycle.cycleReturnHome(position);
		state.acq.averaging=state.cycle.cycleAveraging(position);
		state.acq.numberOfZSlices=state.cycle.cycleNumberOfZSlices(position);
		state.acq.numberOfFrames=state.cycle.cycleNumberOfFrames(position);
		state.acq.zStepSize=state.cycle.cycleZStepPerSlice(position);
		updateAllGUIVars(gh.mainControls);
		updateHeaderString('state.acq.zStepSize');
		updateHeaderString('state.acq.averaging');
		updateHeaderString('state.acq.returnHome');
		alterDAQ_NewNumberOfFrames;
		preallocateMemory;
	end
	
	state.internal.repeatsDone=0;
	resetCounters;

	global gh

