function drawROIsOnFigure
% This function will draw rectangles on the image that correpond to the 
% ROIS selected in the field of view.
% Current image is represented also.
% blue are the rois, rd is the current position.
% Everything is normlaized with repsect to reset image...

global state gh
mockROI=[state.acq.scaleXShiftReset state.acq.scaleYShiftReset state.acq.scanRotationReset state.acq.zoomFactorReset];
fractionUsedXDirection=state.acq.fillFraction;
scanX=1/state.acq.zoomFactorReset*2*state.acq.roiCalibrationFactor*abs(state.acq.scanAmplitudeX); %VI091508A
scanY=1/state.acq.zoomFactorReset*2*abs(state.acq.scanAmplitudeY); %VI091508A

delete(findobj(state.internal.roiaxis,'type','patch','tag','roi'));
obj=[];
for roiCounter=1:size(state.acq.roiList,1)
    new=state.acq.roiList(roiCounter,1:4);
    amplitude=mockROI(4)./new(4);
    diffX=(new(1)-mockROI(1))/(scanX) - amplitude/2;
    diffY=(new(2)-mockROI(2))/(scanY) - amplitude/2;
    xdata=[diffX diffX diffX+amplitude diffX+amplitude]-state.acq.roiPhaseCorrection*state.internal.lineDelay;
    ydata=[diffY diffY+amplitude diffY+amplitude diffY];
    obj=[obj patch(xdata,ydata,[1 0 0],'EdgeColor','red',...
        'FaceColor','none','LineWidth',2,'Parent',state.internal.roiaxis,'Tag','roi','UserData',roiCounter)];
    rotate(obj(end),[0 0 1],mockROI(3)-new(3));
end    
children=get(state.internal.roiaxis,'Children');
index=find(children==state.internal.roiimage);
children(index)=[];
set(state.internal.roiaxis,'Children',[children' state.internal.roiimage]);
updateCurrentROI;
cmenu = uicontextmenu('Parent',get(state.internal.roiaxis,'Parent'));
uimenu(cmenu, 'Label', 'GOTO ROI', 'Callback', 'gotoROINum(get(gco,''UserData'')'')');
set(obj,'UIContextMenu', cmenu);