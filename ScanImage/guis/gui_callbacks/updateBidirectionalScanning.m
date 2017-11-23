function updateBidirectionalScanning(handle)
%% function updateBidirectionalScanning(handle)
% Callback function that handles update to the bidirectional scanning checkbox
%

global state gh

if state.acq.bidirectionalScan
    set(gh.advancedConfigurationGUI.lineDelay,'Enable','Off');
else
    set(gh.advancedConfigurationGUI.lineDelay,'Enable','On');
end



        
        