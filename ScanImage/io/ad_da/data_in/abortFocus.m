%% function abortFocus
%Handle Focus mode aborts
%% CHANGES
%  VI100608A: Use MP285Clear() instead of MP285Flush() -- Vijay Iyer 10/06/08
%% ***************************************************************
function abortFocus
global gh state

h=gh.mainControls.focusButton;

state.internal.abortActionFunctions=1;
setStatusString('Aborting Focus...');

closeShutter;
set(h, 'Enable', 'off');
stopFocus;
MP285Clear; %VI100608A

scim_parkLaser;
putDataFocus;

set(h, 'String', 'FOCUS');
set(h, 'Enable', 'on');
set(gh.mainControls.startLoopButton, 'Visible', 'On');
if ~state.internal.looping
    set(gh.mainControls.grabOneButton, 'Visible', 'On');
    turnOnMenusFocus;
else
    MP285Clear; %VI100608A
    turnOffMenusFocus;
    
    resetCounters;
    state.internal.abortActionFunctions=0;
    setStatusString('Resuming cycle...');
    
    stopFocus;
    updateGUIByGlobal('state.internal.frameCounter');
    updateGUIByGlobal('state.internal.zSliceCounter');
    
    state.internal.abort=0;
    state.internal.currentMode=3;
    
    mainLoop;
end
userPreferenceGUI('imageBox_Callback',gh.userPreferenceGUI.imageBox);
setStatusString('');