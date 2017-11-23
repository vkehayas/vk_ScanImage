function closeShutter
global state

% closeShutter.m******
% 
% Function that sends the close signal defined in the state global 
% variable to the shutter.
%
% Must be executed after the setupDAQDevices.m function.
%
% Written By: Thomas Pologruto
% Cold Spring Harbor Labs
% December 5, 2000
state.shutter.shutterOpen=0;
if state.shutter.shutterOn %VI031109A
    putvalue(state.shutter.shutterLine, state.shutter.closed);
end
