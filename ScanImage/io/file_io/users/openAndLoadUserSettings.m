function out=openAndLoadUserSettings
% Allows user to select a settings file (*.ini) from disk and loads it
% Author: Bernardo Sabatini
out=0;

global state gh
status=state.internal.statusString;
setStatusString('Loading user settings...');

[fname, pname]=uigetfile('*.usr', 'Choose user settings file to load');
if ~isnumeric(fname)
    periods=findstr(fname, '.');
    if any(periods)								
        fname=fname(1:periods(1)-1);
    else
        disp('openAndLoadUserSettings: Error: found file name without extension');
        setStatusString('Can''t open file...');
        return
    end		
    openusr(fullfile(pname, [fname '.usr']));
    cd(state.userSettingsPath);
    %TPMOD
    if isdir(state.userFcnGUI.UserFcnPath)
        files=dir([state.userFcnGUI.UserFcnPath '*.m']);
        state.userFcnGUI.UserFcnFiles = sortrows({files.name}'); % Sort names
        if ~isempty(state.userFcnGUI.UserFcnFiles)
            set(gh.userFcnGUI.UserFcnBrowser,'Value',1,'String',state.userFcnGUI.UserFcnFiles);
        else
            set(gh.userFcnGUI.UserFcnBrowser,'Value',1,'String',' ');
        end
    end
end


setStatusString(status);
