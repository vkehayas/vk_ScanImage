function turnOffMenusFocus
% Controls to turn off during FOCUS mode acquisition
%% CHANGES
%   VI101708A: Leave imageGUI controls on during FOCUS acquistion
%% ***********************************************
global gh state
%Added TP
set(gh.mainControls.Settings,'Enable','off');
set(gh.mainControls.File,'Enable','off');
%set(get(gh.imageGUI.figure1,'Children'), 'Enable', 'Off'); %VI101708A
set(get(gh.standardModeGUI.figure1, 'children'), 'Enable', 'Off');
set(get(gh.cycleControls.figure1, 'children'), 'Enable', 'Off');
set(gh.mainControls.cyclePosition, 'Enable', 'Off');
set(gh.mainControls.positionToExecuteSlider, 'Enable', 'Off');
if state.init.eom.pockelsOn
    set([gh.powerControl.Settings gh.powerControl.maxPower_Slider],'Enable','off');  %TPMODPockels
end

