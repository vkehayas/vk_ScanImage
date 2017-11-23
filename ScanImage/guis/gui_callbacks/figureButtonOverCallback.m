function figureButtonOverCallback
global state gh
% This function will grab the current position and intensity from the figure
% and display it in the imageGUI Window.
		
		% If your focusing, get out.
		focusString = get(gh.mainControls.focusButton, 'String');
		if strcmp(focusString, 'ABORT')
			return
		end
		
		% Figure out which window you ar ein
        channel=find(state.internal.GraphFigure==gcf);
        if isempty(channel)
            return
        else
            handle=state.internal.GraphFigure(channel);
		    name = get(handle,'Name');
        end
		%what is the state of the software?
		loopString = get(gh.mainControls.startLoopButton, 'String');
		grabString = get(gh.mainControls.grabOneButton, 'String');
		
		currentPoint = recordCurrentPoint(gca);
		state.internal.currentPointX = currentPoint(1,1);
		updateGUIByGlobal('state.internal.currentPointX');
		state.internal.currentPointY = currentPoint(1,2);
		updateGUIByGlobal('state.internal.currentPointY');
	
	if state.acq.averaging == 1 
		if strcmp('Max', name(1:3))	 % Looking at a max projection
			pos=state.internal.zSliceCounter+1;
			if pos>size(state.acq.maxData{channel},3)
				pos=size(state.acq.maxData{channel},3);
			end
			state.internal.intensity = state.acq.maxData{channel}(state.internal.currentPointY, state.internal.currentPointX, pos);
		else
			pos=state.internal.zSliceCounter+1;
			if pos>size(state.acq.acquiredData{channel},3)
				pos=size(state.acq.acquiredData{channel},3);
			end
			state.internal.intensity = state.acq.acquiredData{channel}(state.internal.currentPointY, state.internal.currentPointX, pos);
		end			
	else
		if strcmp('Max', name(1:3)) % Looking at a max projection
			if state.acq.numberOfFrames==1
				pos=state.internal.zSliceCounter+1;
				if pos>size(state.acq.maxData{channel},3)
					pos=size(state.acq.maxData{channel},3);
				end
				state.internal.intensity = state.acq.maxData{channel}(state.internal.currentPointY, state.internal.currentPointX, pos);
			else
				beep;
			end
		else
			pos=state.internal.frameCounter+state.acq.numberOfFrames*state.internal.zSliceCounter;
			if pos>size(state.acq.acquiredData{channel},3)
				pos=size(state.acq.acquiredData{channel},3);
			end
			state.internal.intensity = state.acq.acquiredData{channel}(state.internal.currentPointY, state.internal.currentPointX, pos);
		end
	end
	updateGUIByGlobal('state.internal.intensity');
	
		
		
		
		
	