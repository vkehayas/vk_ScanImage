function loadConfigFast(number)
%% function loadConfigFast(number)
%loads a configuration quickly with a hotkey.
%
%% MODIFICATIONS
% VI043008A Vijay Iyer 04/30/08 -- Place focus (back) on mainControls window following fast configuration loading
% VI052208A Vijay Iyer 05/22/08 -- Give user some feedback when configuration is switching

global state gh
setStatusString('Switching config...'); %VI052208A
if ~isfield(state.files,['fastConfig' num2str(number)])
    disp('No Quick Configuration Set for Key');
    return
elseif isempty(getfield(state.files,['fastConfig' num2str(number)]))
    disp('No Quick Configuration Set for Key');
    return
end
%status=state.internal.statusString;
[pname,fname,ext]=fileparts(getfield(state.files,['fastConfig' num2str(number)]));
state.standardMode.configName=fname;
state.standardMode.configPath=pname;
turnOffMenus;
turnOffExecuteButtons;
loadStandardModeConfig;
turnOnMenus;
turnOnExecuteButtons;
%setStatusString(status);
figure(gh.mainControls.figure1); %VI043008A
