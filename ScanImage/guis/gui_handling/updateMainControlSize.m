function updateMainControlSize
% Thsi function checks to see if the main controls are 
% set correctly...
global state gh
currentState=get(gh.mainControls.showrotbox,'String');
if ~strcmp(currentState,state.acq.showrotbox)
    mainControls('showrotbox_Callback',gh.mainControls.showrotbox);
end
