function [x1,x2] = makeSawtoothX(t, scanOffsetX, scanAmplitudeX);
%% function [x1,x2] = makeSawtoothX(t, scanOffsetX, scanAmplitudeX);
% Function that defines the line scanning mirror output.
%% 
% Written by: Thomas Pologruto
% Cold Spring Harbor Labs
% February 9, 2001
%
%% NOTES
%   
%% MODIFICATIONS
%   VI022608A Vijay Iyer 2/26/08 -- Handled bidirectional scanning case
%   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
global state

state.internal.lineDelay = .001*state.acq.lineDelay/state.acq.msPerLine; %I don't understand why one divides (rather than multiplies) by state.acq.msPerLine (Vijay Iyer)

% Parameter that define the scan and flyback functions for the x channel(line scanning mirror).
state.internal.scanAmplitudeX = scanAmplitudeX/state.acq.zoomFactor;

%TPMOD 2/6/02
newDelay = .001*state.acq.cuspDelay/state.acq.msPerLine;

if ~state.acq.bidirectionalScan %VI022608A
    flybackDecimal = (1 - state.acq.fillFraction - state.internal.lineDelay + newDelay); 
    
    slopex1 = ((2*state.internal.scanAmplitudeX)/(state.acq.msPerLine*(1-flybackDecimal)));
    interceptx1 = (scanOffsetX - state.internal.scanAmplitudeX);
    slopex2 = (-(2*state.internal.scanAmplitudeX)/(state.acq.msPerLine*flybackDecimal));
    interceptx2 = ((1-flybackDecimal)/(flybackDecimal))*(2*state.internal.scanAmplitudeX) + (scanOffsetX + state.internal.scanAmplitudeX);
    
else      
    slopex1 = (2*state.internal.scanAmplitudeX)/(state.acq.msPerLine);
    slopex2 = -slopex1;
    interceptx1 = scanOffsetX - state.internal.scanAmplitudeX;
    interceptx2 = scanOffsetX + state.internal.scanAmplitudeX;         
end

x1 = slopex1*t + interceptx1;
x2 = slopex2*t + interceptx2;


