function turnOnMenus
global gh state
%Added TP
set(gh.mainControls.Settings,'Enable','on');
set(gh.mainControls.File,'Enable','on');
set(get(gh.imageGUI.figure1,'Children'),'Enable','on');
updateImageGUI;
state.acq.showrotbox=state.internal.oldRotBoxString;
updateMainControlSize;
set(gh.mainControls.showrotbox,'Enable','on');
set(gh.mainControls.reset, 'Enable', 'on');
set(get(gh.standardModeGUI.figure1, 'children'), 'Enable', 'On');
set(get(gh.cycleControls.figure1, 'children'), 'Enable', 'On');
set(gh.mainControls.cyclePosition, 'Enable', 'On');
set(gh.mainControls.positionToExecuteSlider, 'Enable', 'On');
userPreferenceGUI('imageBox_Callback',gh.userPreferenceGUI.imageBox);
%TPMODPockels
if state.init.eom.pockelsOn
    enableEomGui(1);    %TPMODPockels
end
figure(gh.mainControls.figure1); %VI070208A

