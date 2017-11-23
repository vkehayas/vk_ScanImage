function doSnapShot
global state gh
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%%  Written by: Thomas Pologruto
%%
%%  Changed:
%%    Fixed putDataGrab bug when going from Snap to Grab - T. O'Connor 12/30/03
%%    TPMOD for SnapShot Mode....6/2/03
%%
%%  Copyright - Howard Hughes Medical Institute/Cold Spring Harbor Laboratories 2003
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if state.internal.snapping 
    state.files.autoSave=state.files.autoSaveBSnap;	
    state.acq.numberOfZSlices=state.acq.numberOfZSlicesBSnap;
    state.acq.numberOfFrames=state.acq.numberOfFramesBSnap;
    state.acq.averaging=state.acq.averagingBSnap;
    state.internal.snapping=0;
    snappedData=state.acq.acquiredData;
    preallocateMemory;
    for cc=1:length(snappedData)
        state.acq.acquiredData{cc}(:,:,1)=snappedData{cc};
    end
    alterDAQ_NewNumberOfFrames;
    putDataGrab; %12/30/03 - Tim O'Connor
    setStatusString('Ending Grab...');
    set(gh.mainControls.focusButton, 'Visible', 'On');
    set(gh.mainControls.startLoopButton, 'Visible', 'On');
    set(gh.mainControls.grabOneButton, 'String', 'GRAB');
    set(gh.mainControls.grabOneButton, 'Visible', 'On');
    turnOnMenus;
    setStatusString('');
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%