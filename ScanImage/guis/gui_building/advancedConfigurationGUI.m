function varargout = advancedConfigurationGUI(varargin)
%% function varargout = advancedConfigurationGUI(varargin)
% ADVANCEDCONFIGURATIONGUI Application M-file for configurationGUI.fig
%    FIG = ADVANCEDCONFIGURATIONGUI launch configurationGUI GUI.
%    ADVANCEDCONFIGURATIONGUI('callback_name', ...) invoke the named callback.

% Last Modified by GUIDE v2.5 28-Feb-2008 11:39:07
% 
%% MODIFICATIONS
% VI030508A Vijay Iyer 3/5/08 -- Blank out (unused) Pockels line delay parameter when in bidirectional scanning mode
% VI031708A Vijay Iyer 3/17/08 -- No longer set state.internal.lineDelay here...leave to setAcquisitionParameters(). 
% VI031708B Vijay Iyer 3/17/08 -- Call setAcquisitionParameters() from all vars which affect it
% VI031808A Vijay Iyer 3/18/08 -- Update pockels parameters when the cusp delay is changed
% VI102008A Vijay Iyer 10/20/08 -- Eliminate use of scanLaserBeam state variable
%
%% **************************************************

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
% Stub for Callback of the uicontrol handles
global state

state.internal.configurationChanged=1;
state.internal.configurationNeedsSaving=1;
genericCallback(h);


% --------------------------------------------------------------------
function varargout = fillFraction_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.popupmenu2.
global state gh
state.internal.configurationChanged=1;
state.internal.configurationNeedsSaving=1;
genericCallback(h);
setAcquisitionParameters;
%state.internal.lineDelay = .001*state.acq.lineDelay/state.acq.msPerLine; %VI031708A
%TPMODPockels
advancedConfigurationGUI('pockelsClosedOnFlyback_Callback',gh.advancedConfigurationGUI.pockelsClosedOnFlyback);

% --------------------------------------------------------------------
function varargout = msPerLine_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.popupmenu1.
global state
state.internal.configurationChanged=1;
state.internal.configurationNeedsSaving=1;
genericCallback(h);
setAcquisitionParameters;


% --------------------------------------------------------------------
function varargout = cuspDelay_Callback(h, eventdata, handles, varargin)
global state gh
state.internal.configurationChanged=1;
state.internal.configurationNeedsSaving=1;
genericCallback(h);
advancedConfigurationGUI('pockelsClosedOnFlyback_Callback',gh.advancedConfigurationGUI.pockelsClosedOnFlyback); %VI031808A


% --------------------------------------------------------------------
function varargout = lineDelay_Callback(h, eventdata, handles, varargin)
global state gh
state.internal.configurationChanged=1;
state.internal.configurationNeedsSaving=1;
genericCallback(h);
%state.internal.lineDelay = .001*state.acq.lineDelay/state.acq.msPerLine; %VI031708A
setAcquisitionParameters; %VI031708B
%TPMODPockels
advancedConfigurationGUI('pockelsClosedOnFlyback_Callback',gh.advancedConfigurationGUI.pockelsClosedOnFlyback);

%TPMODPockels Changed again to be more efficient.....
% --------------------------------------------------------------------
function varargout = pockelsCellLineDelay_Callback(h, eventdata, handles, varargin)
global state;
genericCallback(h);
state.internal.configurationChanged=1;
state.internal.configurationNeedsSaving=1;
%state.init.eom.changed(state.init.eom.scanLaserBeam) = 1; %VI102008A
state.init.eom.changed(1:state.init.eom.numberOfBeams) = 1; %VI102008A

if state.acq.pockelsCellLineDelay < 0
    state.acq.pockelsCellLineDelay=0;
elseif state.acq.pockelsCellLineDelay > 1000*state.acq.msPerLine %Changed, so it never goes over state.acq.msPerLine - Tim O'Connor 7/28/03
    state.acq.pockelsCellLineDelay=1000*state.acq.msPerLine;
end

updateGUIByGlobal('state.acq.pockelsCellLineDelay');

% --------------------------------------------------------------------
function varargout = pockelsCellFillFraction_Callback(h, eventdata, handles, varargin)
global state;
genericCallback(h);
state.internal.configurationChanged = 1;
state.internal.configurationNeedsSaving = 1;
%state.init.eom.changed(state.init.eom.scanLaserBeam) = 1; %VI102008A
state.init.eom.changed(1:state.init.eom.numberOfBeams) = 1; %VI102008A


% --------------------------------------------------------------------
function varargout = pockelsClosedOnFlyback_Callback(h, eventdata, handles, varargin)
global state gh
state.internal.configurationChanged = 1;
state.internal.configurationNeedsSaving = 1;
%state.init.eom.changed(state.init.eom.scanLaserBeam) = 1; %VI102008A
state.init.eom.changed(1:state.init.eom.numberOfBeams) = 1; %VI102008A

if get(h, 'Value') == get(h, 'Max')
    state.acq.pockelsCellLineDelay = state.acq.lineDelay;
    state.acq.pockelsCellFillFraction = state.acq.fillFraction+state.acq.cuspDelay;
    
    set(gh.advancedConfigurationGUI.pockelsCellFillFraction, 'Enable', 'Off');
    set(gh.advancedConfigurationGUI.pockelsCellLineDelay, 'Enable', 'Off');
    set(gh.advancedConfigurationGUI.pockelsCellFillFractionSlider, 'Enable', 'Off');
else
    set(gh.advancedConfigurationGUI.pockelsCellFillFraction, 'Enable', 'On');
    if get(gh.advancedConfigurationGUI.cbBidirectionalScan,'Value') == 0 %VI030508A
        set(gh.advancedConfigurationGUI.pockelsCellLineDelay, 'Enable', 'On');
    end
    set(gh.advancedConfigurationGUI.pockelsCellFillFractionSlider, 'Enable', 'On');
end

updateGUIByGlobal('state.acq.pockelsCellFillFraction')
updateGUIByGlobal('state.acq.pockelsCellLineDelay')

% --------------------------------------------------------------------
function varargout = pockelsCellFillFractionSlider_Callback(h, eventdata, handles, varargin)
global state 

genericCallback(h);
state.internal.configurationChanged = 1;
state.internal.configurationNeedsSaving = 1;
%state.init.eom.changed(state.init.eom.scanLaserBeam) = 1; %VI102008A
state.init.eom.changed(1:state.init.eom.numberOfBeams) = 1; %VI102008A


% --------------------------------------------------------------------
function cbBidirectionalScan_Callback(h, eventdata, handles)
global state gh

state.internal.configurationChanged=1;
state.internal.configurationNeedsSaving=1;
genericCallback(h);

%VI030508A
if get(h,'Value')
    set(gh.advancedConfigurationGUI.pockelsCellLineDelay,'Enable','Off');
else
    if get(gh.advancedConfigurationGUI.pockelsClosedOnFlyback,'Value') == 0
        set(gh.advancedConfigurationGUI.pockelsCellLineDelay,'Enable','On');
    else
        set(gh.advancedConfigurationGUI.pockelsCellLineDelay,'Enable','Off');
    end
end

    

