function varargout = laserFunctionPanel(varargin)
% LASERFUNCTIONPANEL M-file for laserFunctionPanel.fig
%      LASERFUNCTIONPANEL, by itself, creates a new LASERFUNCTIONPANEL or raises the existing
%      singleton*.
%
%      H = LASERFUNCTIONPANEL returns the handle to a new LASERFUNCTIONPANEL or the handle to
%      the existing singleton*.
%
%      LASERFUNCTIONPANEL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LASERFUNCTIONPANEL.M with the given input arguments.
%
%      LASERFUNCTIONPANEL('Property','Value',...) creates a new LASERFUNCTIONPANEL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before laserFunctionPanel_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to laserFunctionPanel_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help laserFunctionPanel

% Last Modified by GUIDE v2.5 17-Oct-2008 16:04:32

% Begin initialization code - DO NOT EDIT
%% CHANGES
%   VI101708A: Add support for 3 beams. Removed frame from GUI. -- Vijay Iyer 10/17/08
%   VI103108A: Handle update of lists and needed beam calibrations upon closing the dialog box -- Vijay Iyer 10/31/08
%   VI110208A: Moved everything to the closing function callback -- Vijay Iyer 11/2/08
%   VI111008A: Handle display of the user settings note in a GUI size dependent manner -- Vijay Iyer 11/10/08
%
%% *********************************************************************

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @laserFunctionPanel_OpeningFcn, ...
                   'gui_OutputFcn',  @laserFunctionPanel_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin & isstr(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

% --- Executes just before laserFunctionPanel is made visible.
function laserFunctionPanel_OpeningFcn(hObject, eventdata, handles, varargin)
global state;
state.init.eom.laserFunctionPanel.callback = @laserFunctionPanelCallback;
state.init.eom.laserFunctionPanel.updateDisplay = @updateLaserFunctionPanelDisplay;

handles.output = hObject;
guidata(hObject, handles);

return;

% --- Executes upon request to close GUI
function laserFunctionPanel_ClosingFcn(hObject, eventdata, handles, varargin)
global state gh

%beamChange = getappdata(hObject,'beamChange');
lists = {'focusLaserList' 'grabLaserList' 'snapLaserList'};
beamAlreadyActive = zeros(3,1);
for i=1:length(lists)   
    eval([lists{i} '= state.init.eom.' lists{i} ';']);
    for j=1:3
        if strfind(state.init.eom.(lists{i}), ['PockelsCell-' num2str(j)])
            beamAlreadyActive(j) = 1;
        end
    end
    state.init.eom.(lists{i}) = ''; %Reset the list here, to recreate below
end

% if ~isempty(beamChange) && beamChange
%beamChanges = false;
for i = 1 : state.init.eom.numberOfBeams
    beamActive = false; %VI103008A
    if get(getfield(gh.laserFunctionPanel, ['focus' num2str(i)]), 'Value') == 1
        beamActive = true; %VI103008A
        state.init.eom.focusLaserList = [state.init.eom.focusLaserList ', ', ['PockelsCell-' num2str(i)]];
    end
    if get(getfield(gh.laserFunctionPanel, ['grab' num2str(i)]), 'Value') == 1
        beamActive = true; %VI103008A
        state.init.eom.grabLaserList = [state.init.eom.grabLaserList ', ', ['PockelsCell-' num2str(i)]];
    end
    if get(getfield(gh.laserFunctionPanel, ['snap' num2str(i)]), 'Value') == 1
        beamActive = true; %VI103008A
        state.init.eom.snapLaserList = [state.init.eom.snapLaserList ', ', ['PockelsCell-' num2str(i)]];
    end
    
    if beamActive && ~beamAlreadyActive(i)
        calibrateEom(i);
    end

end

updateHeaderString('state.init.eom.focusLaserList');
updateHeaderString('state.init.eom.grabLaserList');
updateHeaderString('state.init.eom.snapLaserList');
% end


return;

% --- Outputs from this function are returned to the command line.
function varargout = laserFunctionPanel_OutputFcn(hObject, eventdata, handles)

varargout{1} = handles.output;

return;

%-------------------------------------------------------------
function laserFunctionPanelCallback(hObject, eventdata, handles)
% Handles changes to the beam/mode checkboxes

%%%VI110208A: Nothing needed here anymore
%setappdata(hObject,'beamChange',beamChange); %VI103108A   


return;




function updateLaserFunctionPanelDisplay(varargin)

global state gh;

%Resize the display for the correct # of beams.
%When support is added for more than two beams, it should go here.
if state.init.eom.numberOfBeams == 1
    guiWidth = 22;
    pos = get(gh.laserFunctionPanel.figure1, 'Position');
    pos(3) = guiWidth; %VI101708A: was 27.2
    set(gh.laserFunctionPanel.figure1, 'Position', pos);
       
%     pos = get(gh.laserFunctionPanel.frame1, 'Position');
%     pos(3) = 25.0;
%     set(gh.laserFunctionPanel.frame1, 'Position', pos);
elseif state.init.eom.numberOfBeams == 2
    guiWidth = 35;
    pos = get(gh.laserFunctionPanel.figure1, 'Position');
    pos(3) = guiWidth; %VI101708A: was 41.2
    set(gh.laserFunctionPanel.figure1, 'Position', pos);
    
%     pos = get(gh.laserFunctionPanel.frame1, 'Position');
%     pos(3) = 39.0;
%     set(gh.laserFunctionPanel.frame1, 'Position', pos);
elseif state.init.eom.numberOfBeams == 3
    guiWidth = 46;
    pos = get(gh.laserFunctionPanel.figure1, 'Position');
    pos(3) = guiWidth; %VI101708A: was 41.2
    set(gh.laserFunctionPanel.figure1, 'Position', pos);
else
    guiWidth = 46;
    pos = get(gh.laserFunctionPanel.figure1, 'Position');
    pos(3) = guiWidth; %VI101708A: was 41.2
    set(gh.laserFunctionPanel.figure1, 'Position', pos);
    
%     pos = get(gh.laserFunctionPanel.frame1, 'Position');
%     pos(3) = 39.0;
%     set(gh.laserFunctionPanel.frame1, 'Position', pos);
     fprintf(2, 'Warning: LaserFunctionPanel GUI is only able to support 3 beams, for now.\n'); %VI101708A
end

%%%VI111008A: Resize the note about this being a User Settign
pos = get(gh.laserFunctionPanel.stUserSettingsNote, 'Position');
pos(3) = guiWidth*.90;
pos(1) = guiWidth*.05;
set(gh.laserFunctionPanel.stUserSettingsNote, 'Position', pos);
%%%%%%%%%

%Set the checkboxes to match the lists.
for i = 1 : state.init.eom.numberOfBeams
    %TO080507C - Debugged 3 beams.
    if i <= 3 %VI101708A
        name = ['PockelsCell-' num2str(i)];
        
        if any(strcmp(name, delimitedList(state.init.eom.focusLaserList, ',')))
            set(getfield(gh.laserFunctionPanel, ['focus' num2str(i)]), 'Value', 1);
        else
            set(getfield(gh.laserFunctionPanel, ['focus' num2str(i)]), 'Value', 0);
        end
        
        if any(strcmp(name, delimitedList(state.init.eom.grabLaserList, ',')))
            set(getfield(gh.laserFunctionPanel, ['grab' num2str(i)]), 'Value', 1);
        else
            set(getfield(gh.laserFunctionPanel, ['grab' num2str(i)]), 'Value', 0);
        end
        
        if any(strcmp(name, delimitedList(state.init.eom.snapLaserList, ',')))
            set(getfield(gh.laserFunctionPanel, ['snap' num2str(i)]), 'Value', 1);
        else
            set(getfield(gh.laserFunctionPanel, ['snap' num2str(i)]), 'Value', 0);
        end
    end
end

return;


