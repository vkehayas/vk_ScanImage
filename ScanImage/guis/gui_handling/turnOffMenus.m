function turnOffMenus
global gh state
%Added TP
set(gh.mainControls.Settings,'Enable','off');
set(gh.mainControls.File,'Enable','off');
set(get(gh.imageGUI.figure1,'Children'), 'Enable', 'Off');
state.internal.oldRotBoxString=state.acq.showrotbox;
if strcmp(state.internal.oldRotBoxString,'<<')
    state.acq.showrotbox='>>';
    updateMainControlSize;
end
set(gh.mainControls.showrotbox,'Enable','off');
set(gh.mainControls.reset, 'Enable', 'Off');
set(get(gh.standardModeGUI.figure1, 'children'), 'Enable', 'Off');
set(get(gh.cycleControls.figure1, 'children'), 'Enable', 'Off');
set(gh.mainControls.cyclePosition, 'Enable', 'Off');
set(gh.mainControls.positionToExecuteSlider, 'Enable', 'Off');
enableEomGui(0);    %TPMODPockels


