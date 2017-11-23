function openShutter
global state

% openShutter.m******
% 
% Function that sends the open signal defined in the state global 
% variable to the shutter.
%
% Must be executed after the setupDAQDevices.m function.
%
% Written By: Thomas Pologruto
% Cold Spring Harbor Labs
% December 5, 2000
            
state.shutter.shutterOpen=1;
if state.shutter.shutterOn %VI031109A
    putvalue(state.shutter.shutterLine, state.shutter.open);
end