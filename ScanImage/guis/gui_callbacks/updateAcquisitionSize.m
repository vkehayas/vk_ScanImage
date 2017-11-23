function  updateAcquisitionSize(varargin)
%% function  updateAcquisitionSize(varargin)
%Shared callback logic for handling updates to the number of frames and/or number of images
%
%   updateAquisitionSize()
%   updateAcquisitionSize(h)
%       h: (Optional) handle to uicontrol that led to this function execution (via a callback)
%
%% NOTES
%   This function is only ever reached in StandardMode operation -- Vijay Iyer 10/28/09
%
%% CHANGES
% VI031408A Vijay Iyer 3/14/08 -- Handle case (i.e. ScanImage startup) where this callback is entered before any DAQ initialization has occured
% VI042108A Vijay Iyer 4/21/08 -- Make shared for changes to either number of images or frames
%% *********************************************************

global state

changedNumFrames = false;
if state.acq.numberOfFrames~=state.standardMode.numberOfFrames;
    state.acq.numberOfFrames=state.standardMode.numberOfFrames;
    updateGUIByGlobal('state.acq.numberOfFrames');
    changedNumFrames = true;
end

state.acq.numberOfZSlices=state.standardMode.numberOfZSlices;
updateGUIByGlobal('state.acq.numberOfZSlices');

reconcileStandardModeSettings;

if isfield(state.acq,'dm')  %VI031408A
    preallocateMemory;
    
    if changedNumFrames %VI042108A -- handle specifically the changed # frames case
        alterDAQ_NewNumberOfFrames; 
    end
    %Tim O'Connor 12/17/03 - Flag all Pockels cells, so they regenerate data for the right # of frames.
    state.init.eom.changed(:) = 1;
end

%Don't allow external triggering for multi-slice acqs (VI041308A)
if state.acq.numberOfZSlices > 1
    state.acq.externallyTriggered = 0;
    updateGUIByGlobal('state.acq.externallyTriggered');
end