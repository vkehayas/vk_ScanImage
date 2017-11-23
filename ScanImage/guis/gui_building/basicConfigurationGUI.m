function varargout = basicConfigurationGUI(varargin)
% BASICCONFIGURATIONGUI_OLD Application M-file for configurationGUI.fig
%    FIG = BASICCONFIGURATIONGUI_OLD launch configurationGUI GUI.
%    BASICCONFIGURATIONGUI_OLD('callback_name', ...) invoke the named callback.

% Last Modified by GUIDE v2.0 18-Mar-2003 15:50:15

if nargin == 0  % LAUNCH GUI
    
    fig = openfig(mfilename,'reuse');
    
    % Generate a structure of handles to pass to callbacks, and store it. 
    handles = guihandles(fig);
    guidata(fig, handles);
    
    if nargout > 0
        varargout{1} = fig;
    end
    
elseif ischar(varargin{1}) % INVOKE NAMED SUBFUNCTION OR CALLBACK
    
    try
        [varargout{1:nargout}] = feval(varargin{:}); % FEVAL switchyard
    catch
        disp(lasterr);
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



% --------------------------------------------------------------------
function varargout = generic_Callback(h, eventdata, handles, varargin)
% Stub for Callback of most uicontrol handles
global state
state.internal.configurationChanged=1;
state.internal.configurationNeedsSaving=1;
if any(strcmp(get(h,'tag'),{'xScanAmplitude','yScanAmplitude'}))
    state.internal.aspectRatioChanged=1;
end
genericCallback(h);


% --------------------------------------------------------------------
function varargout = pixelsPerLine_Callback(h, eventdata, handles, varargin)
% Stub for Callback of most uicontrol handles
global state
state.internal.configurationChanged=1;
state.internal.configurationNeedsSaving=1;
state.acq.pixelsPerLineGUI = get(h,'Value');
state.acq.pixelsPerLine = str2num(getMenuEntry(h, state.acq.pixelsPerLineGUI));
genericCallback(h);

% --------------------------------------------------------------------
function varargout = fastScanRadioX_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.fastScanRadioX.
global gh state
state.internal.configurationChanged=1;
genericCallback(h);
state.acq.fastScanningY = 0;
updateGUIByGlobal('state.acq.fastScanningY');

% --------------------------------------------------------------------
function varargout = fastScanRadioY_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.fastScanRadioY.
global gh state
state.internal.configurationChanged=1;
genericCallback(h);
state.acq.fastScanningX = 0;
updateGUIByGlobal('state.acq.fastScanningX');



% --------------------------------------------------------------------
function varargout = linesPerFrame_Callback(h, eventdata, handles, varargin)
global state

state.internal.configurationChanged=1;
state.internal.configurationNeedsSaving=1;
genericCallback(h);