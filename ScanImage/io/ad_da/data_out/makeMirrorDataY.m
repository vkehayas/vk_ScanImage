% makeMirrorDataY.m*****
% Function that takes the output from the sawtooth function fsawtoothy.m and manipulates it so that the proper data
% is output to the data engine.
%% CHANGES
%   VI080608A Vijay Iyer 8/6/2008 -- Handle bidirectional case differently
%% CREDITS
% Written by: Thomas Pologruto
% Cold Spring Harbor Labs
% November 16, 2000
%% *********************************************
function outYData = makeMirrorDataY(y1,y2)
global state

if ~state.acq.bidirectionalScan %VI080608A
    state.internal.lineDelay = .001*state.acq.lineDelay/state.acq.msPerLine;
    
    flybackDecimal = (1- state.acq.fillFraction-state.internal.lineDelay);
    numberOfPositiveSlopePointsY = round((state.acq.linesPerFrame-flybackDecimal)*state.internal.lengthOfXData );		% Number of data points for positive slope on y channel
else
    numberOfPositiveSlopePointsY = (state.acq.linesPerFrame-1)*state.internal.lengthOfXData;    
end

y1(1,(numberOfPositiveSlopePointsY + 1):(state.acq.linesPerFrame*state.internal.lengthOfXData )) = zeros(1,(state.acq.linesPerFrame*state.internal.lengthOfXData - numberOfPositiveSlopePointsY ));
y2(1,1:numberOfPositiveSlopePointsY) = zeros(1,numberOfPositiveSlopePointsY);

outYData = (y1' + y2');						% Makes the column vector for one frame of data
