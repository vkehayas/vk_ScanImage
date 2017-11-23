function varargout =saveCurrentConfigAs
global state

if ~isempty(state.configPath)
    cd(state.configPath)
end

[fname, pname]=uiputfile('*.cfg', 'Choose Configuration name...');

if ~isnumeric(fname)
    setStatusString('Saving config...');

    periods=findstr(fname, '.');
    if any(periods)
        fname=fname(1:periods(1)-1);
    end
    state.configName=fname;
    state.configPath=pname;

    %%%VI020209A%%%%%%%%%
    if state.standardMode.standardModeOn
        state.standardMode.configName = state.configName;
        state.standardMode.configPath = state.configPath;
    end
    %%%%%%%%%%%%%%%%%%%%%%

    updateGUIByGlobal('state.configName');
    saveCurrentConfig;
    setStatusString('');
    state.internal.configurationNeedsSaving=0;
else
    setStatusString('Cannot open file');
end
