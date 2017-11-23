function calculateStackParameters
	 global state gh
	if ~state.standardMode.standardModeOn
		disp('*** Stack boundry mode only works with Standard Mode ***');
	end
	
	step=abs(state.standardMode.zStepPerSlice);
	if length(state.motor.stackStart)==3
		zStart=state.motor.stackStart(3);
	else
		disp('*** Stack starting position not defined.');
		return
	end

	if length(state.motor.stackStop)==3
		zStop=state.motor.stackStop(3);
	else
		disp('*** Stack ending position not defined.');
		return
	end
	
	if zStart<zStop
		state.standardMode.zStepPerSlice=step;
	else
		state.standardMode.zStepPerSlice=-step;
	end
	state.acq.zStepSize=state.standardMode.zStepPerSlice;
	updateGUIByGlobal('state.standardMode.zStepPerSlice');
	updateHeaderString('state.acq.zStepSize');


	state.standardMode.numberOfZSlices=max(ceil(abs(zStop-zStart)/step),1);
	state.acq.numberOfZSlices=state.standardMode.numberOfZSlices;
	updateGUIByGlobal('state.standardMode.numberOfZSlices');
	updateGUIByGlobal('state.acq.numberOfZSlices');

	preallocateMemory;


	
	
