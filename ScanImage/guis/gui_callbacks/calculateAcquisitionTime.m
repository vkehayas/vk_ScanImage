function calculateAcquisitionTime
global state gh

% Function that calculates the acquisition time for a given acquisition and
% stroes it as a state.internal.acquisitionTime

state.acq.acquisitionTime = (state.acq.msPerLine*state.acq.linesPerFrame*state.acq.numberOfFrames*state.acq.numberOfZSlices);
