function updatemsPerLineVariables(handle)
%% function updatemsPerLineVariables(handle)
% Callback function that updates all the parameters that need to be updatred whenever
% the msPerLine variable changes.
%
% Written By: Thomas Pologruto
% Cold Spring Harbor Labs
% January 2, 2001

%% MODIFICATIONS
% TO092906A: Make sure that 'setAcquisitionParameters' precedes 'updatePixelTime', so the correct values are used in the calculation. -- Tim O'Connor 9/29/06
%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global state gh

setAcquisitionParameters; %TO092906A
updatePixelTime; %TO092906A
updateBinFactor;