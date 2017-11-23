function openChannelGUI
%% function openChannelGUI

%% MODIFICATIONS
% VI043008A Vijay Iyer 4/30/2008 -- Handle the 'focus-only merge' option
% VI111708A Vijay Iyer 11/17/2008 -- Handle the 'blue as gray' option
%
%% ******************************************
global state gh

updateCurrentFigure;

if state.acq.channelMerge
    set(gh.channelGUI.cbMergeFocusOnly,'Enable','on'); %VI043008A
    set(gh.channelGUI.cbMergeBlueAsGray,'Enable','on'); %VI111708A
else
    set(gh.channelGUI.cbMergeFocusOnly,'Enable','off'); %VI043008A
    set(gh.channelGUI.cbMergeBlueAsGray,'Enable','off'); %VI111708A
end
    
seeGUI('gh.channelGUI.figure1');
