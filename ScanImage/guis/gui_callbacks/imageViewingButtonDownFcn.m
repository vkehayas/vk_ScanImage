function imageViewingButtonDownFcn
global gh state
try

	currentPoint = recordCurrentPoint(gh.currentImageViewerGUI.axis1);
	state.internal.currentPointX = currentPoint(1,1);
	updateGUIByGlobal('state.internal.currentPointX');
	state.internal.currentPointY = currentPoint(1,2);
	updateGUIByGlobal('state.internal.currentPointY');
	CData = get(state.imageViewing.currentImageBeingViewed, 'CData');
	state.internal.intensity = CData(state.internal.currentPointY, state.internal.currentPointX);
	updateGUIByGlobal('state.internal.intensity');
catch
	disp(lasterr);
end
