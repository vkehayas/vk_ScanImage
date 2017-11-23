function resetCounters
global state gh

% Function that resets the counters for a new acquisition at the end of acquisitions or ABORT.

	state.internal.frameCounter = 1;
	updateGUIByGlobal('state.internal.frameCounter');
	state.internal.stripeCounter=0;
    state.internal.stripeCounter2=0;
	state.internal.focusFrameCounter = 1;
	state.internal.zSliceCounter=0;
	updateGUIByGlobal('state.internal.zSliceCounter');
	state.internal.inputChannelCounter = 1;
    


