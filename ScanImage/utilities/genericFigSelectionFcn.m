function [axis,volts_per_pixelX,volts_per_pixelY,sizeImage]=genericFigSelectionFcn(handle)
%This is the generic function called when the user wants to change the 
% scan params interactively with the mouse selection.
% This includes ROI selection, Center selection, and 
% linescan selection.
% Calculates which axis is selected, the pixles per volts in X and Y, as
% wella as the image size...
%% CHANGES
%   VI110308A: Handle negative scanAmplitude case for Y dimension -- Vijay Iyer 11/03/08
%% ***************************************
global state gh
setImagesToWhole;
if nargin<1
    axis=state.internal.axis(logical(state.acq.imagingChannel));
    image=state.internal.imagehandle(logical(state.acq.imagingChannel));
    axis=axis(1);
    image=image(1);
elseif ishandle(handle)
    ind=find(handle==state.internal.axis);
    if isempty(ind)
        return
    end
    axis=handle;
    image=state.internal.imagehandle(ind);
else
    ~ishandle(handle)
    return
end
fractionUsedXDirection=state.acq.fillFraction;
x=get(axis,'XLim');
y=get(axis,'YLim');
sizeImage=[y(2) round(state.acq.roiCalibrationFactor*x(2))];
volts_per_pixelX=((1/state.acq.zoomFactor)*2*fractionUsedXDirection*abs(state.acq.scanAmplitudeX))/sizeImage(2); %VI091508A
volts_per_pixelY=((1/state.acq.zoomFactor)*2*abs(state.acq.scanAmplitudeY))/sizeImage(1); %VI110308A
