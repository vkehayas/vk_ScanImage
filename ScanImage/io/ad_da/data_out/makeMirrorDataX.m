function outXData = makeMirrorDataX(x1, x2)
%% function outXData = makeMirrorDataX(x1, x2)
% makeMirrorDataX.m*****
% Function that takes the output from the sawtooth function fsawtoothx.m and manipulates it so that the proper data
% is output to the data engine.
%
% Written by: Thomas Pologruto
% Cold Spring Harbor Labs
% October 23, 2000
%
%% MODIFICATIONS
%   VI022508A Vijay Iyer 02/25/08 - Handled bidirectional scanning case 
%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global state

if ~state.acq.bidirectionalScan %VI022508A --only execute the enclosed original code in the unidirectional (sawtooth) scanning case
    state.internal.lineDelay = .001*state.acq.lineDelay/state.acq.msPerLine;
    
    flybackDecimal = (1- state.acq.fillFraction-state.internal.lineDelay); %I don't understand this original version (Vijay Iyer 2/25/08)


    sizex1 = size(x1); 								% determines the dimensions fo the sawtooth output; Should be 1 x (tau*ActualRate)
    state.internal.lengthOfXData = sizex1(1,2);		% grabs the non-zero dimension of sizex and defines number of points output on the x-channel
    % for one sawtooth.

    numberOfPositiveSlopePoints = round((1-flybackDecimal)*state.internal.lengthOfXData ); 		% Number of data points for positive slope on x channel

    % Replaces with zeros the positive slope values after the maximum is reached: Defines the cusp

    x1(1, (numberOfPositiveSlopePoints+1):state.internal.lengthOfXData ) = zeros(1,(state.internal.lengthOfXData  - numberOfPositiveSlopePoints));
    x2(1,1:numberOfPositiveSlopePoints) = zeros(1,numberOfPositiveSlopePoints);
    outXData = (x1' + x2'); 
    outXData = repmat(outXData, [state.acq.linesPerFrame 1]); 			% Constructs an array of sawtoothx functions for each line acquired% Makes the column vector for one line of data
else    
    state.internal.lengthOfXData = length(x1); %Sets this parameter to the length of each line
    outXData = [x1';x2'];
    outXData = repmat(outXData,[state.acq.linesPerFrame/2 1]); %Only need half the repeats--each repeated element contains 2 lines
end


