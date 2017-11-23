function varargout = powerControl(varargin)
global state
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% EOM_GUI Application M-file for eom_gui.fig
%    FIG = EOM_GUI launch eom_gui GUI.
%    EOM_GUI('callback_name', ...) invoke the named callback.
% 
% Last Modified by GUIDE v2.5 11-Mar-2004 13:55:56
%
% Changes:
%   TPMOD_1: Modified 12/31/03 Tom Pologruto - Added checkbox to set
%   whether or not to poll the photodiode upon power change.
%   TO21804a Tim O'Connor 2/18/04 - Allow power box to work in mW.
%   TO21804d Tim O'Connor 2/18/04 - Added some sensible/useful error messages.
%   TO22004a Tim O'Connor 2/18/04 - Fix missing variables, due to bad config loading.
%   TO22704a Tim O'Connor 2/27/04 - Created uncagingMapper.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin == 0  % LAUNCH GUI

	fig = openfig(mfilename,'reuse');

	% Use system color scheme for figure:
	set(fig,'Color',get(0,'defaultUicontrolBackgroundColor'));

	% Generate a structure of handles to pass to callbacks, and store it. 
	handles = guihandles(fig);
	guidata(fig, handles);
    
	if nargout > 0
		varargout{1} = fig;
	end
    
elseif ischar(varargin{1}) % INVOKE NAMED SUBFUNCTION OR CALLBACK

	try
		if (nargout)
			[varargout{1:nargout}] = feval(varargin{:}); % FEVAL switchyard
		else
			feval(varargin{:}); % FEVAL switchyard
		end
	catch
		warning(lasterr);
	end

end

%| ABOUT CALLBACKS:
%| GUIDE automatically appends subfunction prototypes to this file, and 
%| sets objects' callback properties to call them through the FEVAL 
%| switchyard above. This comment describes that mechanism.
%|
%| Each callback subfunction declaration has the following form:
%| <SUBFUNCTION_NAME>(H, EVENTDATA, HANDLES, VARARGIN)
%|
%| The subfunction name is composed using the object's Tag and the 
%| callback type separated by '_', e.g. 'slider2_Callback',
%| 'figure1_CloseRequestFcn', 'axis1_ButtondownFcn'.
%|
%| H is the callback object's handle (obtained using GCBO).
%|
%| EVENTDATA is empty, but reserved for future use.
%|
%| HANDLES is a structure containing handles of components in GUI using
%| tags as fieldnames, e.g. handles.figure1, handles.slider2. This
%| structure is created at GUI startup using GUIHANDLES and stored in
%| the figure's application data using GUIDATA. A copy of the structure
%| is passed to each callback.  You can store additional information in
%| this structure at GUI startup, and you can change the structure
%| during callbacks.  Call guidata(h, handles) after changing your
%| copy to replace the stored original so that subsequent callbacks see
%| the updates. Type "help guihandles" and "help guidata" for more
%| information.
%|
%| VARARGIN contains any extra arguments you have passed to the
%| callback. Specify the extra arguments by editing the callback
%| property in the inspector. By default, GUIDE sets the property to:
%| <MFILENAME>('<SUBFUNCTION_NAME>', gcbo, [], guidata(gcbo))
%| Add any extra arguments after the last argument, before the final
%| closing parenthesis.

function msg = debug(handles)
%global state;

%msg = sprintf('\nmaxPower_Slider:\n Max=%2.0f\n Min=%2.0f\n Val=%2.0f\nmaxLimit_Slider:\n Max=%2.0f\n Min=%2.0f\n Val=%2.0f\neom.maxPower=%2.0f\neom.min=%2.0f\neom.maxLimit=%2.0f\n', ...
 %   get(handles.maxPower_Slider, 'Max'), get(handles.maxPower_Slider, 'Min'), get(handles.maxPower_Slider, 'Value'), ...
  %  get(handles.maxLimit_Slider, 'Max'), get(handles.maxLimit_Slider, 'Min'), get(handles.maxLimit_Slider, 'Value'), ...
   % state.init.eom.maxPower, state.init.eom.min, state.init.eom.maxLimit);

return;

% --------------------------------------------------------------------
% pre - Calibrated.
% post - state.init.eom.maxPower(i) = maxPower_Slider.Value
%        <ensureState>
function varargout = maxPower_Slider_Callback(h, eventdata, handles, varargin)
global state gh

    genericCallback(h);
    
    state.init.eom.maxPower(state.init.eom.beamMenu) = round(state.init.eom.maxPowerDisplaySlider);
    state.init.eom.changed(state.init.eom.beamMenu) = 1;
    ensureEomGuiStates;

% --------------------------------------------------------------------
% pre - Calibrated.
% post - state.init.eom.maxPower(i) = maxPower_Text.Value
%        <ensureState>
function varargout = maxPowerText_Callback(h, eventdata, handles, varargin)
global state gh

genericCallback(h);

if get(gh.powerControl.mW_radioButton, 'Value') == get(gh.powerControl.mW_radioButton, 'Max')    %in mW 
    conversion = (getfield(state.init.eom, ['powerConversion' num2str(state.init.eom.beamMenu)]) * ...
        state.init.eom.maxPhotodiodeVoltage(state.init.eom.beamMenu) * .01);       
    state.init.eom.maxPower(state.init.eom.beamMenu) = round(1 / conversion * state.init.eom.maxPowerDisplay);
else
    state.init.eom.maxPower(state.init.eom.beamMenu) = round(state.init.eom.maxPowerDisplay);
end

state.init.eom.changed(state.init.eom.beamMenu) = 1;
ensureEomGuiStates;
setScanProps(h);

% --------------------------------------------------------------------
% pre - Calibrated.
% post - state.init.eom.maxLimit(i) = maxLimit.String
%        <ensureState>
function varargout = maxLimit_Callback(h, eventdata, handles, varargin)
global state gh;

    set(h, 'String', num2str(round(str2num(get(h, 'String')))));
    state.init.eom.maxLimit(state.init.eom.beamMenu) = str2num(get(h, 'String'));
    ensureEomGuiStates;
    
    if state.init.eom.changed(state.init.eom.beamMenu)
        setScanProps(h);
    end

% --------------------------------------------------------------------
% pre - Calibrated.
% post - state.init.eom.maxLimit(i) = maxLimit_Slider.Value
%        <ensureState>
function varargout = maxLimit_Slider_Callback(h, eventdata, handles, varargin)
global state gh;

state.init.eom.maxLimit(state.init.eom.beamMenu) = round(get(h, 'Value'));
ensureEomGuiStates;
if state.init.eom.changed(state.init.eom.beamMenu)
    setScanProps(h);
end

% --------------------------------------------------------------------
% pre - Calibrated.
%       power to voltage conversion is configured
% post - power readout is in mW units
%        <ensureState>
function varargout = mW_radioButton_Callback(h, eventdata, handles, varargin)
global state gh
    val = get(h, 'Value');
    set(h,'Enable','inactive');
    
    if val == get(h, 'Max')
        set(gh.powerControl.percent_radioButton, 'Value', get(h, 'Min'),'Enable','on');
    else
        set(gh.powerControl.percent_radioButton, 'Value', get(h, 'Max'),'Enable','on');        
    end
    
    set(gh.powerControl.powerBoxText, 'String', 'Power [mW]');
    
    state.init.eom.powerInMw = 1;
    
    ensureEomGuiStates;
    
    return;

% --------------------------------------------------------------------
% pre - Calibrated.
% post - power readout is in % units
%        <ensureState>
function varargout = percent_radioButton_Callback(h, eventdata, handles, varargin)
global state gh
    val = get(h, 'Value');
    set(h,'Enable','inactive');
    if val == get(h, 'Max')
        set(gh.powerControl.mW_radioButton, 'Value', get(h, 'Min'),'Enable','on');
    else
        set(gh.powerControl.mW_radioButton, 'Value', get(h, 'Max'),'Enable','on');
    end
    
    %Added to allow power box to work in mW. -- Tim O'Connor TO21804a
    set(gh.powerControl.powerBoxText, 'String', 'Power [%]');
    
    state.init.eom.powerInMw = 0;
    
    ensureEomGuiStates;
    
    return;

% --------------------------------------------------------------------
% pre - Calibrated.
% post - controls for the appropriate beamMenu are displayed
function varargout = beamMenu_Callback(h, eventdata, handles, varargin)
global state gh;
%     previous = state.init.eom.beamMenu;

    genericCallback(h);

    set(gh.powerControl.boxConstrainBox, 'Value', state.init.eom.constrainBoxToLine(state.init.eom.beamMenu));
%     state.init.eom.showBox = state.init.eom.showBoxArray(state.init.eom.beamMenu);
%     updateGuiByGlobal('state.init.eom.showBox');
%     state.init.eom.boxPower = state.init.eom.boxPowerArray(state.init.eom.beamMenu);
%     updateGuiByGlobal('state.init.eom.boxPower');    
%     state.init.eom.startFrame = state.init.eom.startFrameArray(state.init.eom.beamMenu);
%     updateGuiByGlobal('state.init.eom.startFrame');    
%     state.init.eom.endFrame = state.init.eom.endFrameArray(state.init.eom.beamMenu);
%     updateGuiByGlobal('state.init.eom.endFrame');

    ensureEomGuiStates;

    state.init.eom.beamMenuSlider = state.init.eom.numberOfBeams - state.init.eom.beamMenu + 1;
    updateGUIByGlobal('state.init.eom.beamMenuSlider');
    set(gh.powerControl.beamMenuSlider, 'Value', state.init.eom.beamMenuSlider);

    updatePowerGUI(state.init.eom.beamMenu);

%     %The powerbox or custom timings may need recalculation.
%     state.init.eom.changed(state.init.eom.beamMenu) = 1;
%     state.init.eom.changed(previous) = 1;

% --------------------------------------------------------------------
function varargout = usePowerArray_Callback(h, eventdata, handles, varargin)
genericCallback(h);
global state gh
state.init.eom.changed(state.init.eom.beamMenu)=1;

if state.init.eom.usePowerArray
    set(get(gh.powerTransitions.figure1,'Children'),'Enable','On');
end

% --------------------------------------------------------------------
function varargout = selectPowerBox_Callback(h, eventdata, handles, varargin)
global state gh;

buttonHandles=[gh.mainControls.grabOneButton gh.mainControls.focusButton gh.mainControls.startLoopButton];
if all(strcmpi(get(buttonHandles,'Visible'),'on'))
    done=drawPowerBox(gca);
    if done
        setScanProps(h);
        snapShot(1);
    end
else
    beep;
    disp('Cant select ROI when acquiring or focusing.');
end
state.init.eom.changed(state.init.eom.beamMenu)=1;

% --------------------------------------------------------------------
function done = drawPowerBox(handle)
global state gh

done = 0;
state.init.eom.changed(state.init.eom.beamMenu) = 1;
setImagesToWhole;

if nargin < 1
    ax=state.internal.axis(logical(state.acq.imagingChannel));
    image=state.internal.imagehandle(logical(state.acq.imagingChannel));
    ax = ax(1);
    image = image(1);
elseif ishandle(handle)
    ind = find(handle == state.internal.axis);
    if isempty(ind)
        return;
    end
    
    ax = handle;
    image = state.internal.imagehandle(ind);
else
    return;
end

imsize = [state.acq.pixelsPerLine  state.acq.linesPerFrame];
pos = round(getrect(ax));
if pos(3) == 0 | pos(4) == 0
    return;
elseif ~isempty(state.init.eom.boxHandles) & size(state.init.eom.boxHandles, 1) >= state.init.eom.beamMenu
    if sum(state.init.eom.boxHandles(state.init.eom.beamMenu, ishandle(state.init.eom.boxHandles(state.init.eom.beamMenu, :)))) ~= 0
        delete(state.init.eom.boxHandles(state.init.eom.beamMenu, ishandle(state.init.eom.boxHandles(state.init.eom.beamMenu, :))));
        state.init.eom.boxHandles(state.init.eom.beamMenu, :) = -1;
    end
end

%Constrain to a single line, for uncaging.
if state.init.eom.constrainBoxToLine(state.init.eom.beamMenu) & abs(pos(4)) ~= 1
    if pos(4) < 0
        pos(4) = -1;
    elseif pos(4) > 0
        pos(4) = 1;
    end
end

% remember coords in a config independent way.
state.init.eom.powerBoxNormCoords(state.init.eom.beamMenu, :) = pos;
state.init.eom.powerBoxNormCoords(state.init.eom.beamMenu, [1 3]) = state.init.eom.powerBoxNormCoords(state.init.eom.beamMenu, [1 3]) ./ imsize(1);
state.init.eom.powerBoxNormCoords(state.init.eom.beamMenu, [2 4]) = state.init.eom.powerBoxNormCoords(state.init.eom.beamMenu, [2 4]) ./ imsize(2);

%Draw the boxes....
for j = 1 : state.init.maximumNumberOfInputChannels
    state.init.eom.boxHandles(state.init.eom.beamMenu, j) = rectangle('Position', pos, 'FaceColor', 'none', ...
        'EdgeColor', state.init.eom.boxcolors(state.init.eom.beamMenu, :), 'LineWidth', 3, 'Parent', state.internal.axis(j), ...
        'ButtonDownFcn', 'powerBoxButtonDownFcn', 'UserData', state.init.eom.beamMenu, ...
        'Tag', sprintf('PowerBox%s', num2str(state.init.eom.beamMenu))); %Added a tag, so it can be found. -- Tim 12/23/03
end
state.init.eom.showBoxArray(state.init.eom.beamMenu) = 1;
state.init.eom.showBox = state.init.eom.showBoxArray(state.init.eom.beamMenu);
updateGUIByGlobal('state.init.eom.showBox');
updatePowerBoxStrings;

updateGUIByGlobal('state.init.eom.boxWidth', 'Value', round(100 * pos(3) * (1000 * state.acq.msPerLine) / state.acq.pixelsPerLine) / 100, 'Callback', 0);
state.init.eom.powerBoxWidthsInMs(state.init.eom.beamMenu) = state.init.eom.boxWidth;

% --------------------------------------------------------------------
function varargout = boxPower_Callback(h, eventdata, handles, varargin)
global state gh;

genericCallback(h);

%Added to allow power box to work in mW. -- Tim O'Connor TO21804a
conversion = 1;
if get(gh.powerControl.mW_radioButton, 'Value') == get(gh.powerControl.mW_radioButton, 'Max')    %in mW 
    
    conversion = (getfield(state.init.eom, ['powerConversion' num2str(state.init.eom.beamMenu)]) * ...
        state.init.eom.maxPhotodiodeVoltage(state.init.eom.beamMenu) * .01);
    
    state.init.eom.boxPowerArray(state.init.eom.beamMenu) = round(1 / conversion * state.init.eom.boxPower);
else
    state.init.eom.boxPowerArray(state.init.eom.beamMenu) = round(state.init.eom.boxPower);
end

%Make sure it's within bounds.
if state.init.eom.boxPowerArray(state.init.eom.beamMenu) > 100
    state.init.eom.boxPowerArray(state.init.eom.beamMenu) = 100;
    state.init.eom.boxPower = conversion * state.init.eom.boxPowerArray(state.init.eom.beamMenu);
elseif state.init.eom.boxPowerArray(state.init.eom.beamMenu) < state.init.eom.min
    state.init.eom.boxPowerArray(state.init.eom.beamMenu) = state.init.eom.min(state.init.eom.beamMenu);
    state.init.eom.boxPower = conversion * state.init.eom.boxPowerArray(state.init.eom.beamMenu);
end

state.init.eom.changed(state.init.eom.beamMenu) = 1;

%Display the rounded off figure.
state.init.eom.boxPower = round(state.init.eom.boxPower);
updateGUIByGlobal('state.init.eom.boxPower');

updatePowerBoxStrings;

return;

% --------------------------------------------------------------------
function varargout = startFrame_Callback(h, eventdata, handles, varargin)
global state gh
genericCallback(h);
state.init.eom.changed(state.init.eom.beamMenu)=1;
state.init.eom.startFrameArray(state.init.eom.beamMenu)=state.init.eom.startFrame;
updatePowerBoxStrings;

%Tim O'Connor 12/16/03, this should be an immediate warning.
%Grab the text from the gui object, because it changes when switching between linescan and framescan.
if state.init.eom.startFrame > state.init.eom.endFrame
    fprintf(2, 'WARNING: Start Frame/Line (%s) must be less than End Frame/Line (%s).\n', get(gh.powerControl.startFrame, 'String'), get(gh.powerControl.endFrame, 'String'));
end

% --------------------------------------------------------------------
function varargout = endFrame_Callback(h, eventdata, handles, varargin)
global state gh
genericCallback(h);
state.init.eom.changed(state.init.eom.beamMenu)=1;
state.init.eom.endFrameArray(state.init.eom.beamMenu)=state.init.eom.endFrame;
updatePowerBoxStrings;

%Tim O'Connor 12/16/03, this should be an immediate warning.
%Grab the text from the gui object, because it changes when switching between linescan and framescan.
if state.init.eom.startFrame > state.init.eom.endFrame
    fprintf(2, 'WARNING: ''%s'' must be less than ''%s''.\n', get(gh.powerControl.startFrame, 'String'), get(gh.powerControl.endFrame, 'String'));
end

% --------------------------------------------------------------------
function varargout = showBox_Callback(h, eventdata, handles, varargin)
global state gh

genericCallback(h);
state.init.eom.showBoxArray(state.init.eom.beamMenu) = state.init.eom.showBox;

if state.init.eom.showBox == 1
    %Display the powerbox, when in use.
    children = get(gh.powerControl.Settings, 'Children');
    index = getPullDownMenuIndex(gh.powerControl.Settings, 'Show Power Box');
    checked = get(children(index), 'Checked');

    if ~strcmpi(checked, 'On')
        resizePowerControlFigure;
    end
end

if size(state.init.eom.boxHandles, 1) < state.init.eom.beamMenu & state.init.eom.showBox

    if state.init.eom.autoSelectFullWidthPowerBox & state.init.eom.beamMenu == state.init.eom.scanLaserBeam
        createFullWidthPowerBox;

    else
        beep;
        fprintf(2, 'ERROR: Can not enable powerbox, no box selected.\n');%TO21804d
        set(h,'Value',0);
        return
    end
end

state.init.eom.changed(state.init.eom.beamMenu) = 1;

if size(state.init.eom.boxHandles, 1) < state.init.eom.beamMenu
    recth = [];%Doesn't the above `if` statement preclude this possibility? -- Tim 2/18/04
else
    recth = state.init.eom.boxHandles(state.init.eom.beamMenu, ishandle(state.init.eom.boxHandles(state.init.eom.beamMenu, :)));
end

if (isempty(recth) | (state.init.eom.powerBoxNormCoords(state.init.eom.beamMenu, :) == 0)) & state.init.eom.showBox
    if state.init.eom.autoSelectFullWidthPowerBox & state.init.eom.beamMenu == state.init.eom.scanLaserBeam        
        createFullWidthPowerBox;
    else
        beep;
        set(h, 'Value', 0);
        fprintf(2, 'ERROR: Can not enable powerbox, no box selected.\n');%TO21804d
        return
    end
end

if state.init.eom.showBox
    set(recth,'Visible','On');
else
    set(recth,'Visible','Off');
end

updatePowerBoxStrings;

%TO21804b: Tightly couple the powerbox checkbox and the UncagingPulseImporter's 'enable' button. - Tim O'Connor 2/18/04
if ~ismember(1, state.init.eom.showBoxArray) & state.init.eom.uncagingPulseImporter.enabled
    if state.init.eom.uncagingPulseImporter.coupleToPowerBoxErrors

        %Turn off the UncagingPulseImporter, if there are no powerboxes.
        state.init.eom.uncagingPulseImporter.enabled = 0;
        updateGUIByGlobal('state.init.eom.uncagingPulseImporter.enabled');
        set(gh.uncagingPulseImporter.enableToggleButton, 'ForegroundColor', [0 .6 0]);
        set(gh.uncagingPulseImporter.enableToggleButton, 'String', 'Enable');
        
        fprintf(2, 'WARNING: The UncagingPulseImporter was enabled when all powerboxes became deselected.\n         The UncagingPulseImporter has been automatically disabled.\n');
        
    else
        
        fprintf(2, 'WARNING: The UncagingPulseImporter was enabled when all powerboxes became deselected.\n         The UncagingPulseImporter will remain inactive until a powerbox is enabled.\n');
        
    end
end

return;

% --------------------------------------------------------------------
function createFullWidthPowerBox
global state;

%The x parameter is 1, normalized by the pixels per line.
state.init.eom.powerBoxNormCoords(state.init.eom.beamMenu, 1) = 1 / state.acq.pixelsPerLine;

%The width parameter is 1 (after normalization).
state.init.eom.powerBoxNormCoords(state.init.eom.beamMenu, 3) = 1;

%The y and height parameters are both 1, normalized by the lines per frame.
state.init.eom.powerBoxNormCoords(state.init.eom.beamMenu, [2 4]) = 1 / state.acq.linesPerFrame;

position([1 2 4]) = 1;
position(3) = state.acq.pixelsPerLine;

for j = 1 : state.init.maximumNumberOfInputChannels

    state.init.eom.boxHandles(state.init.eom.beamMenu, j) = rectangle('Position',  position, ...
        'FaceColor', 'none', 'EdgeColor', state.init.eom.boxcolors(state.init.eom.beamMenu, :), 'LineWidth', 3, ...
        'Parent', state.internal.axis(j), 'ButtonDownFcn', 'powerBoxButtonDownFcn', 'UserData', state.init.eom.beamMenu, ...
        'Tag', sprintf('PowerBox%s', num2str(state.init.eom.beamMenu)), 'Visible', 'On');
    
end

updateGUIByGlobal('state.init.eom.boxWidth', 'Value', round(100 * pos(3) * (1000 * state.acq.msPerLine) / state.acq.pixelsPerLine) / 100, 'Callback', 0);
state.init.eom.powerBoxWidthsInMs(state.init.eom.beamMenu) = state.init.eom.boxWidth;

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function updatePowerGUI(beam)
% This will uodate the GUIs according to which beam is selected...
global state gh;

if length(state.init.eom.showBoxArray) < state.init.eom.numberOfBeams
    state.init.eom.showBoxArray(state.init.eom.numberOfBeams) = 0;
end
state.init.eom.showBox = state.init.eom.showBoxArray(state.init.eom.beamMenu);
updateGUIByGlobal('state.init.eom.showBox');

%TO22004a - Pick up these variables from the GUI, if they don't exist, since config loading can overwrite them.
if length(state.init.eom.endFrameArray) < state.init.eom.beamMenu
    state.init.eom.endFrameArray(state.init.eom.beamMenu) = state.init.eom.endFrame;
end
state.init.eom.endFrame = state.init.eom.endFrameArray(state.init.eom.beamMenu);
updateGUIByGlobal('state.init.eom.endFrame');

if length(state.init.eom.startFrameArray) < state.init.eom.beamMenu
    state.init.eom.startFrameArray(state.init.eom.beamMenu) = state.init.eom.startFrame;
end
state.init.eom.startFrame = state.init.eom.startFrameArray(state.init.eom.beamMenu);
updateGUIByGlobal('state.init.eom.startFrame');

%Convert display to mW or % -- TO21804a
conversion = 1;
if get(gh.powerControl.mW_radioButton, 'Value') == get(gh.powerControl.mW_radioButton, 'Max')
    conversion = (getfield(state.init.eom, ['powerConversion' num2str(beam)]) * ...
        state.init.eom.maxPhotodiodeVoltage(beam) * .01);
end

if length(state.init.eom.boxPowerArray) < state.init.eom.beamMenu
    state.init.eom.boxPowerArray(state.init.eom.beamMenu) = state.init.eom.boxPower;
end

%Added to allow power box to work in mW. -- Tim O'Connor TO21804a
state.init.eom.boxPower = round(conversion * state.init.eom.boxPowerArray(state.init.eom.beamMenu));
updateGUIByGlobal('state.init.eom.boxPower');

%Try to locate the (now properly tagged) object.
fig = get(0,'CurrentFigure');
obj = findobj('Tag', sprintf('PowerBox%s', num2str(state.init.eom.beamMenu)));
if length(obj) > 1
    obj = obj(1);%Hope it's always the first one...???
end
pos = get(obj, 'Position');

if ~isempty(pos)
    %Change the coordinates.
    pos = get(obj, 'Position');
    updateGUIByGlobal('state.init.eom.boxWidth', 'Value', round(100 * pos(3) * (1000 * state.acq.msPerLine) / state.acq.pixelsPerLine) / 100, 'Callback', 0);
    state.init.eom.powerBoxWidthsInMs(state.init.eom.beamMenu) = state.init.eom.boxWidth;
end

updatePowerBoxStrings;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function updatePowerBoxStrings
% This will uodate the GUIs according to which beam is selected...
global state
state.init.eom.showBoxArrayString = mat2str(state.init.eom.showBoxArray);
updateHeaderString('state.init.eom.showBoxArrayString');
state.init.eom.endFrameArrayString = mat2str(state.init.eom.endFrameArray);
updateHeaderString('state.init.eom.endFrameArrayString');
state.init.eom.startFrameArrayString = mat2str(state.init.eom.startFrameArray);
updateHeaderString('state.init.eom.startFrameArrayString');
state.init.eom.boxPowerArrayString = mat2str(state.init.eom.boxPowerArray);
updateHeaderString('state.init.eom.boxPowerArrayString');
state.init.eom.powerBoxNormCoordsString = mat2str(state.init.eom.powerBoxNormCoords);
updateHeaderString('state.init.eom.powerBoxNormCoordsString');

% --------------------------------------------------------------------
function varargout = boxConstrainBox_Callback(h, eventdata, handles, varargin)
global state gh;

genericCallback(h);
state.init.eom.constrainBoxToLine(state.init.eom.beamMenu) = state.init.eom.powerBoxUncagingConstraint;

if state.init.eom.powerBoxUncagingConstraint & state.init.eom.showBox
    %Can't use powerBoxButtonDownFcn because it's too vague when choosing the right 
    %graphics object works with.
    %Try to locate the (now properly tagged) object.
    fig = get(0,'CurrentFigure');
    obj = findobj('Tag', sprintf('PowerBox%s', num2str(state.init.eom.beamMenu)));
    if length(obj) > 1
        obj = obj(1);%Hope it's always the first one...???
    end
    %Change the coordinates.
    pos = get(obj, 'Position');
    if pos(4) < 0
        pos(4) = -1;
    elseif pos(4) > 0
        pos(4) = 1;
    end
    %Save the new coordinates.
    imsize = [state.acq.pixelsPerLine  state.acq.linesPerFrame];
    state.init.eom.powerBoxNormCoords(state.init.eom.beamMenu, :) = pos;
    state.init.eom.powerBoxNormCoords(state.init.eom.beamMenu, [1 3]) = pos([1 3]) ./ imsize(1);
    state.init.eom.powerBoxNormCoords(state.init.eom.beamMenu, [2 4]) = pos([2 4]) ./ imsize(2);
    %Update all the channels.
    for j = 1 : state.init.maximumNumberOfInputChannels
        set(state.init.eom.boxHandles(state.init.eom.beamMenu, j), 'Position', pos);
    end
end

% --------------------------------------------------------------------
function varargout = beamMenuSlider_Callback(h, eventdata, handles, varargin)
global state gh;

    genericCallback(h);

    %Keep things within bounds.
    if state.init.eom.beamMenuSlider > state.init.eom.numberOfBeams
        state.init.eom.beamMenuSlider = state.init.eom.numberOfBeams;
    elseif state.init.eom.beamMenuSlider < 1
        state.init.eom.beamMenuSlider = 1;
    end

    %Invert the slider, so that Beam2 is graphically below Beam1, to match the popup menu behavior.
    state.init.eom.beamMenu = state.init.eom.numberOfBeams - state.init.eom.beamMenuSlider + 1;

    updateGUIByGlobal('state.init.eom.beamMenu'); %Again, why doesn't this ever work properly???

    set(gh.powerControl.beamMenu, 'Value', state.init.eom.beamMenu);
    powerControl('beamMenu_Callback', gh.powerControl.beamMenu);

% start TPMOD_1 12/31/03
function updatePowerContinuously_Callback(hObject, eventdata, handles)
genericCallback(hObject);
% end TPMOD_1 12/31/03


% --- Executes during object creation, after setting all properties.
function boxWidth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to boxWidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function boxWidth_Callback(hObject, eventdata, handles)
% hObject    handle to boxWidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of boxWidth as text
%        str2double(get(hObject,'String')) returns contents of boxWidth as a double
global state;

genericCallback(hObject);

if ~state.init.eom.showBox
    return;
end

%Try to locate the (now properly tagged) object.
fig = get(0,'CurrentFigure');
obj = findobj('Tag', sprintf('PowerBox%s', num2str(state.init.eom.beamMenu)));
if isempty(obj)
    obj = state.init.eom.boxHandles(state.init.eom.beamMenu, :);
end
if length(obj) > 1
    obj = obj(1);%Hope it's always the first one...???
end

%Change the coordinates.
pos = get(obj, 'Position');

if state.init.eom.boxWidth < 0
    state.init.eom.boxWidth = 0;
elseif state.init.eom.boxWidth  + (state.init.eom.powerBoxNormCoords(state.init.eom.beamMenu, 1) ...
        * 1000 * state.acq.msPerLine) > 1000 * state.acq.msPerLine
    state.init.eom.boxWidth = 1000 * state.acq.msPerLine - (state.init.eom.powerBoxNormCoords(state.init.eom.beamMenu, 1) ...
        * 1000 * state.acq.msPerLine);
end

updateGUIByGlobal('state.init.eom.boxWidth', 'Value', round(100 * state.init.eom.boxWidth) / 100, 'Callback', 0);
state.init.eom.powerBoxWidthsInMs(state.init.eom.beamMenu) = state.init.eom.boxWidth;

pos(3) = state.init.eom.boxWidth / (1000 * state.acq.msPerLine) * state.acq.pixelsPerLine;
% updateGuiByGlobal('state.init.eom.boxWidth', 'Value', ...
%     pos(3) * (1000 * state.acq.msPerLine) / state.acq.pixelsPerLine), 'Callback', 0);

%Save the new coordinates.
imsize = [state.acq.pixelsPerLine  state.acq.linesPerFrame];
state.init.eom.powerBoxNormCoords(state.init.eom.beamMenu, :) = pos;
state.init.eom.powerBoxNormCoords(state.init.eom.beamMenu, [1 3]) = pos([1 3]) ./ imsize(1);
state.init.eom.powerBoxNormCoords(state.init.eom.beamMenu, [2 4]) = pos([2 4]) ./ imsize(2);

%Update all the channels.
for j = 1 : state.init.maximumNumberOfInputChannels
    set(state.init.eom.boxHandles(state.init.eom.beamMenu, j), 'Position', pos);
end