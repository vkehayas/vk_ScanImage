function changePositionToExecute(h)
	if nargin<1
		h=0;
	end
	
	global state
	if state.initializing
		return
	end
	global state

	if ~iscell(state.cycle.cycleParts)
		return
	end
	
	applyCyclePositionSettings;
