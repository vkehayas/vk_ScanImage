function updateBeamSelection(handle)
%% function updateBeamSelection(handle)
% Callback function that handles update to the currently selected beam
%% NOTES
%   This contains code that was previously in powerControl/beamMenu_Callback(). 
%   By handling these changes in a separate callback, the code can be shared with roiCycleGUI's pmBeamMenu_Callback()
%
%% CHANGES
%   VI102008A: Only execute these callback actions if the EOM has already been started -- Vijay Iyer 10/20/08
%   VI102008B: Invoke updatePowerGUI() via powerControl.m
%
%% CREDITS
%   Created 10/20/08 by Vijay Iyer
%% *****************************************

global state gh

if isfield(state.init.eom,'started') && state.init.eom.started %VI12008A
     set(gh.powerControl.boxConstrainBox, 'Value', state.init.eom.constrainBoxToLine(state.init.eom.beamMenu));
%     state.init.eom.showBox = state.init.eom.showBoxArray(state.init.eom.beamMenu);
%     updateGUIByGlobal('state.init.eom.showBox');
%     state.init.eom.boxPower = state.init.eom.boxPowerArray(state.init.eom.beamMenu);
%     updateGUIByGlobal('state.init.eom.boxPower');    
%     state.init.eom.startFrame = state.init.eom.startFrameArray(state.init.eom.beamMenu);
%     updateGUIByGlobal('state.init.eom.startFrame');    
%     state.init.eom.endFrame = state.init.eom.endFrameArray(state.init.eom.beamMenu);
%     updateGUIByGlobal('state.init.eom.endFrame');

    ensureEomGuiStates;

    state.init.eom.beamMenuSlider = state.init.eom.numberOfBeams - state.init.eom.beamMenu + 1;
    updateGUIByGlobal('state.init.eom.beamMenuSlider');
    set(gh.powerControl.beamMenuSlider, 'Value', state.init.eom.beamMenuSlider);

    %updatePowerGUI(state.init.eom.beamMenu); %VI102008B
    powerControl('updatePowerGUI',state.init.eom.beamMenu); %VI102008B

%     %The powerbox or custom timings may need recalculation.
%     state.init.eom.changed(state.init.eom.beamMenu) = 1;
%     state.init.eom.changed(previous) = 1;

end


        
        