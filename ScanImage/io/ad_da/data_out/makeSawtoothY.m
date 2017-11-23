function [y1,y2] = makeSawtoothY(t, scanOffsetY, scanAmplitudeY)
%% function [y1,y2] = makeSawtoothY(t, scanOffsetY, scanAmplitudeY)
% Function that defines the frame scanning mirror output.
%
%% CREDITS
% Written by: Thomas Pologruto
% Cold Spring Harbor Labs
% February 9, 2001
%% NOTES
%   This function computes the scanAmplitude after accounting for the zoom factor, but this is not needed as the caller has already ensured that Zoom=1 for the purpose of this calculation
%
%% CHANGES
%   VI071508A Vijay Iyer 7/15/2008 -- Handle bidirectional case differently
%   VI071508B Vijay Iyer 7/15/2008 -- For bidirectional case, account for the X fill fraction...
%% ************************************************************************

global state

state.internal.lineDelay = .001*state.acq.lineDelay/state.acq.msPerLine;

% Parameter that define the scan and flyback functions for the y channel(frame scanning mirror).
state.internal.scanAmplitudeY = scanAmplitudeY/state.acq.zoomFactor; 

if ~state.acq.bidirectionalScan %VI071508A
    flybackDecimal = (1-state.acq.fillFraction-state.internal.lineDelay);
    slopey1 = ((2*state.internal.scanAmplitudeY)/(state.acq.msPerLine*(state.acq.linesPerFrame - flybackDecimal)));
    intercepty1 = (scanOffsetY - state.internal.scanAmplitudeY);
    slopey2 =  (-(2*state.internal.scanAmplitudeY)/(state.acq.msPerLine*flybackDecimal));
    intercepty2 = ((2*state.internal.scanAmplitudeY*(state.acq.linesPerFrame-flybackDecimal))/(flybackDecimal)) + (scanOffsetY + state.internal.scanAmplitudeY);
else
    state.internal.scanAmplitudeY = state.internal.scanAmplitudeY*state.acq.fillFraction; %VI071508B
    
    slopey1 = (2*state.internal.scanAmplitudeY)/(state.acq.msPerLine*(state.acq.linesPerFrame-1));
    intercepty1 = scanOffsetY - state.internal.scanAmplitudeY;
    
    slopey2 = -(2*state.internal.scanAmplitudeY)/state.acq.msPerLine; %flyback in the time it takes for one line
    intercepty2 = scanOffsetY + state.internal.scanAmplitudeY;
end

y1 = slopey1*t + intercepty1;
if ~state.acq.bidirectionalScan %VI080608A
    y2 = slopey2*t + intercepty2;
else
    y2 = slopey2*(t-(state.acq.msPerLine*(state.acq.linesPerFrame-1))) + intercepty2;
end
    