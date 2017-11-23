function out=openusr(fileName, startup)
%% function out=openusr(fileName)
%   Function parses .usr file to update selected Scanimage state variables with values saved by a user(overriding the .ini file settings)
%% SYNTAX
%   out = openusr(fileName)
%   out = openuser(fileName, startup)
%       fileName: Name of USR file to parse/process
%       startup: Optional boolean flag indicating TRUE when called during startup (i.e. open USR file for first time), FALSE otherwise. FALSE is assumed.
%       out: Flag equals 0 when there's no error, 1 if an error occurs. 
%% NOTES
%   The 'out' flag doesn't work, but isn't really needed -- Vijay Iyer 10/31/08
%       
%% MODIFICATIONS
%   VI082608A: Cycle through all 6 fastConfig, now that there are 6 instead of 3. Thanks to Jesper Sjostrom for this bug find. -- Vijay Iyer 8/26/08
%   VI103108A: Calibrate Pockels Cell here now, having determined what beams this user actually employs
%
%%
out=1;
[fid, message]=fopen(fileName);
if fid<0
    beep;
    disp(['openusr: Error opening ' fileName ': ' message]);
    out=1;
    return
end
[fileName,permission, machineormat] = fopen(fid);
fclose(fid);

disp(['*** CURRENT USER SETTINGS FILE = ' fileName ' ***']);

initGUIs(fileName);

[path,name,ext,ver] = fileparts(fileName);

global state
state.userSettingsName=name;
state.userSettingsPath=path;
saveUserSettingsPath;

state.configName='';
state.configPath='';
if length(state.cycle.cycleName)>0
    loadCycleToMemory(state.cycle.cycleName, state.cycle.cyclePath);	
else
    state.standardMode.standardModeOn=1;
end

%VI103008A: Calibrate beams now, only doing those actually used by this user
if nargin < 2 
    startup = false;
end
calibrateBeams(startup);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

applyModeCycleAndConfigSettings;

%Update uimenu checkmark-able options based on USR file 
updateAutoSaveCheckMark;		% BSMOD	
updateKeepAllSlicesCheckMark; % BSMOD
updateAutoOverwriteCheckMark;

setColorMapFromMenu(state.internal.colormapSelected);

global gh	% BSMOD added 1/30/1 with lines below

for number=1:6 %VI082608A
    fname=getfield(state.files,['fastConfig' num2str(number)]);
    if isempty(fname)
        fname=num2str(number);
    else
        [path,fname]=fileparts(fname);
    end
    h=getfield(gh.mainControls,['fastConfig' num2str(number)]);
    label=get(h,'Label');
    ind=findstr(label,' ');
    label(1:ind(end))=[];
    label=[fname '   ' label];
    set(h,'Label',label);
end

wins=fieldnames(gh);

for winCount=1:length(wins)
    winName=wins{winCount};
    if isfield(state.internal, [winName 'Bottom']) & isfield(state.internal, [winName 'Left'])
        pos=get(getfield(getfield(gh, winName), 'figure1'), 'Position');
        if ~isempty(getfield(state.internal, [winName 'Left'])) %TPMOD
            pos(1)=getfield(state.internal, [winName 'Left']);
            pos(2)=getfield(state.internal, [winName 'Bottom']);
            set(getfield(getfield(gh, winName), 'figure1'), 'Position', pos);
        end
        if isfield(state.internal, [winName 'Visible'])
             set(getfield(getfield(gh, winName), 'figure1'), 'Visible', getfield(state.internal, [winName 'Visible']));
         end
    end
end

resetImageProperties;
%TPMOD....
if isfield(state.internal, 'roifigurePositionX') & isfield(state.internal, 'roifigureVisible') 
    roipos=[state.internal.roifigurePositionX state.internal.roifigurePositionY state.internal.roifigureWidth state.internal.roifigureHeight];
    set(state.internal.roifigure,'Position',roipos,'Visible',state.internal.roifigureVisible);
end
userFcnGUI('UserFcnPath_Callback',gh.userFcnGUI.UserFcnPath);
powerControl('usePowerArray_Callback',gh.powerControl.usePowerArray);
powerTransitions('useBinaryTransitions_Callback',gh.powerTransitions.useBinaryTransitions);
updateShutterDelay;

