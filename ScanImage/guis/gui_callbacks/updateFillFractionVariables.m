function updateFillFractionVariables(handle)
%% function updateFillFractionVariables(handle)
% Callback function that updates all the parameters that need to be updatred whenever
% the fillFraction variable changes.
%
% Written By: Thomas Pologruto
% Cold Spring Harbor Labs
% January 14, 2001

%% MODIFICATONS
% TO092906A: Make sure that 'setAcquisitionParameters' precedes 'updatePixelTime', so the correct values are used in the calculation. -- Tim O'Connor 9/29/06
%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global state

setAcquisitionParameters; %TO092906A
updatePixelTime; %TO092906A
updateBinFactor;