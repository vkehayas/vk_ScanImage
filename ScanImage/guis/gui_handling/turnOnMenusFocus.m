function turnOnMenusFocus
% Controls to turn back on following FOCUS mode acquisition
%% CHANGES
%   VI101708A: imageGUI controls are now left on during FOCUS acquistion, so no need to turn them back on here
%% ***********************************************
global gh state
%Added TP
set(gh.mainControls.Settings,'Enable','on');
set(gh.mainControls.File,'Enable','on');
%set(get(gh.imageGUI.figure1,'Children'),'Enable','on'); %VI101708A
%updateImageGUI; %VI101708A
set(get(gh.standardModeGUI.figure1, 'children'), 'Enable', 'On');
set(get(gh.cycleControls.figure1, 'children'), 'Enable', 'On');
set(gh.mainControls.cyclePosition, 'Enable', 'On');
set(gh.mainControls.positionToExecuteSlider, 'Enable', 'On');
userPreferenceGUI('imageBox_Callback',gh.userPreferenceGUI.imageBox);
%TPMODPockels
if state.init.eom.pockelsOn
    set([gh.powerControl.Settings gh.powerControl.maxPower_Slider],'Enable','on');  %TPMODPockels
end
figure(gh.mainControls.figure1); %VI070208A
