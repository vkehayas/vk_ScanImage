function setFastConfig(number)
global state gh

if ~isempty(state.configPath) && isdir(state.configPath)
    cd(state.configPath);
end

if ~isempty(getfield(state.files,'lastFastConfigPath')) && isdir(getfield(state.files,'lastFastConfigPath'))
     cd(getfield(state.files,'lastFastConfigPath'));
end

[fname, pname]=uigetfile('*.cfg', 'Choose Configuration name...');
if isnumeric(fname)
    disp('No Quick Configuration Set');
    return
end

if isfield(state.files,['fastConfig' num2str(number)])
    state.files=setfield(state.files,['fastConfig' num2str(number)],[pname fname]);
    state.files=setfield(state.files,'lastFastConfigPath', pname);
    h=getfield(gh.mainControls,['fastConfig' num2str(number)]);
    label=get(h,'Label');
    ind=findstr(label,' ');
    label(1:ind(end))=[];
    label=[fname '   ' label];
    set(h,'Label',label);
end
