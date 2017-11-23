function varargout = userPreferenceGUI(varargin)
% USERPREFERENCEGUI Application M-file for userPreferenceGUI.fig
%    FIG = USERPREFERENCEGUI launch userPreferenceGUI GUI.
%    USERPREFERENCEGUI('callback_name', ...) invoke the named callback.

% Last Modified by GUIDE v2.5 08-Nov-2008 15:16:29
% Tim O'Connor 2/18/04 TO21804c: Add options to control interaction between powerControl and uncagingPulseImporter GUIs.

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
		if (nargout)
			[varargout{1:nargout}] = feval(varargin{:}); % FEVAL switchyard
		else
			feval(varargin{:}); % FEVAL switchyard
		end
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
function varargout = acquireImageOnChange_Callback(h, eventdata, handles, varargin)
genericCallback(h);

% --------------------------------------------------------------------
function varargout = imageBox_Callback(h, eventdata, handles, varargin)
genericCallback(h);
global state
val=get(h,'Value');
if val
    setAxisGrids(state.internal.axis, 2);
else
    setImagesToWhole;
    set(state.internal.axis, 'XGrid', 'off', 'YGrid', 'off', 'XColor', 'b', 'YColor', 'b', 'GridLineStyle', 'none','Layer','Bottom');
end
rearrangeAxes(state.internal.axis);


% --------------------------------------------------------------------
function varargout = execUserFcnOnSnap_Callback(h, eventdata, handles, varargin)
genericCallback(h);


% --------------------------------------------------------------------
function varargout = controlMotorInROI_Callback(h, eventdata, handles, varargin)
genericCallback(h);



% --------------------------------------------------------------------
function varargout = roiPhaseCorrection_Callback(h, eventdata, handles, varargin)
genericCallback(h);
updateCurrentROI;



% --------------------------------------------------------------------
function varargout = roiCalibrationFactor_Callback(h, eventdata, handles, varargin)
genericCallback(h);



% --- Executes on button press in syncToPhysiology.
function syncToPhysiology_Callback(hObject, eventdata, handles)
% hObject    handle to syncToPhysiology (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of syncToPhysiology
genericCallback(hObject);


% --- Executes on button press in forceFocusFrameScan.
function forceFocusFrameScan_Callback(hObject, eventdata, handles)
genericCallback(hObject);

% --------------------------------------------------------------------
%TO21804c Add some options to control the interaction between PowerControl and UncagingPulseImporter. -- Tim O'Connor 2/18/04
function autoSelectPowerBox_Callback(hObject, eventdata, handles)

genericCallback(hObject);

return;

% --------------------------------------------------------------------
%TO21804c Add some options to control the interaction between PowerControl and UncagingPulseImporter. -- Tim O'Connor 2/18/04
function linkMaxAndBoxPower_Callback(hObject, eventdata, handles)
global state;

genericCallback(hObject);

%Start doing it right away.
if state.init.eom.pockelsOn & state.init.eom.linkMaxAndBoxPower
    for i = 1 : state.init.eom.numberOfBeams
        state.init.eom.boxPowerArray(i) = state.init.eom.maxPower(i);
    end
    
    state.init.eom.boxPower = state.init.eom.boxPowerArray(state.init.eom.beamMenu);
    updateGUIByGlobal('state.init.eom.boxPower');
end

return;


% --------------------------------------------------------------------
function cbCtlHotKeys_Callback(hObject, eventdata, handles)
genericCallback(hObject);


% --------------------------------------------------------------------
function cbCtlFastConfigHotKeys_Callback(hObject, eventdata, handles)
genericCallback(hObject);


