function varargout = standardModeGUI(varargin)
% STANDARDMODEGUI Application M-file for standardModeGUI.fig
%    FIG = STANDARDMODEGUI launch simpleModeGUI GUI.
%    STANDARDMODEGUI('callback_name', ...) invoke the named callback.

% Last Modified by GUIDE v2.0 15-Jan-2001 15:14:20
%% MODIFICATIONS
% VI041308A - Don't allow external triggering for multi-slize acqs -- Vijay Iyer 4/13/2008
% VI042108A - Handle changes to number of frames and/or slices via shared external callback logic -- Vijay Iyer 4/21/2008
% VI091608A - Defer to external updateSaveDuringAcq function -- Vijay Iyer 9/16/2008
% VI110808A - Handle interaction of Z step size and # of slices with stack endpoints, if defined -- Vijay Iyer 11/08/08
% VI111108A - Slice #/size interaction with endpoints now controlled by state.motor.stackEndpointsDominate -- Vijay Iyer 11/11/2008
% VI111108B - If endpoints not constraining slice #/size, then endpoint should be cleared by change to one of slice #/size
% VI120108A - Set up keyPressFcn() callback, binding to the figure and all child controls
% VI120208A - Handle updates to Z step size and # of slices correctly when stack endpoints are NOT defined -- Vijay Iyer 12/02/08
%
%% ****************************************************

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
    
    %%%VI120108A%%%%%%%%%%%%%%%%%%%%%%
    set(fig,'KeyPressFcn',@genericKeyPressFunction);
    %Ensure all children respond to key presses, when they have the focus (for whatever reason)
    kidControls = findall(fig,'Type','uicontrol');
    for i=1:length(kidControls)
        if ~strcmpi(get(kidControls(i),'Style'),'edit')
            set(kidControls(i),'KeyPressFcn',@genericKeyPressFunction');
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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
genericCallback(h);
global state
state.internal.secondsCounter=state.standardMode.repeatPeriod;
updateGUIByGlobal('state.internal.secondsCounter');
state.acq.returnHome=state.standardMode.returnHome;
updateHeaderString('state.acq.returnHome');
%VI110808A
% state.acq.zStepSize=state.standardMode.zStepPerSlice;
% updateHeaderString('state.acq.zStepSize');


% VI110808A--------------------------------------------------------------
function varargout = ZStepSize_Callback(h, eventdata, handles, varargin)

genericCallback(h);

global state
if state.acq.zStepSize ~= state.standardMode.zStepPerSlice %Check that value actually changed
    
    %%%VI120208A: Do this here, not in the following IF clause as before
    state.acq.zStepSize = state.standardMode.zStepPerSlice;
    updateHeaderString('state.acq.zStepSize');
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
    if ~isempty(state.motor.stackStart) && ~isempty(state.motor.stackStop)
        
        if state.motor.stackEndpointsDominate... 
                && sign(state.acq.zStepSize) ~= sign(state.standardMode.zStepPerSlice)
            beep;            
            state.standardMode.zStepPerSlice  = -state.standardMode.zStepPerSlice;
            updateGUIByGlobal('state.standardMode.zStepPerSlice');
        end 

        if state.motor.stackEndpointsDominate %VI111108A
            distance = abs(state.motor.stackStop(3) - state.motor.stackStart(3));
            state.standardMode.numberOfZSlices = round(distance/abs(state.acq.zStepSize));
            state.acq.numberOfZSlices = state.standardMode.numberOfZSlices; %this ensures that processing logic isn't infinitely recursed
            updateGUIByGlobal('state.standardMode.numberOfZSlices','Callback',true);
            beep;
            setStatusString('Adjusted Num Slices!');
        else
            %state.motor.stackStop(3) = state.motor.stackStart(3) + state.standardMode.numberOfZSlices * state.standardMode.zStepPerSlice;
            [state.motor.stackStart, state.motor.stackStop] = deal([]); %VI111108B
            updateStackEndpoints;
            %beep;
            %setStatusString('Cleared Stack End!');
        end
    end
end


% --------------------------------------------------------------------
function varargout = ZSlice_Callback(h, eventdata, handles, varargin)
% Stub for Callback of most uicontrol handles
genericCallback(h);

%%%VI110808A%%%%%%%%%
global state
if state.acq.numberOfZSlices ~= state.standardMode.numberOfZSlices %Check that value actually changed
    state.acq.numberOfZSlices=state.standardMode.numberOfZSlices;
    updateHeaderString('state.acq.zStepSize');
    
    if ~isempty(state.motor.stackStart) && ~isempty(state.motor.stackStop) 
        if state.motor.stackEndpointsDominate %VI111108A
            distance = abs(state.motor.stackStop(3) - state.motor.stackStart(3));
            state.standardMode.zStepPerSlice = sign(state.standardMode.zStepPerSlice) * distance/state.acq.numberOfZSlices;
            state.acq.zStepSize = state.standardMode.zStepPerSlice; %this ensures that processing logic isn't infinitely recursed
            updateGUIByGlobal('state.standardMode.zStepPerSlice','Callback',true);
            beep;
            setStatusString('Adjusted Z Step!');
        else
            %state.motor.stackStop(3) = state.motor.stackStart(3) + state.standardMode.numberOfZSlices * state.standardMode.zStepPerSlice;
            [state.motor.stackStart, state.motor.stackStop] = deal([]); %VI111108B
            updateStackEndpoints;
            %beep;
            %setStatusString('Changed Stack End!');
        end
    end
end  
%%%%%%%%%%%%%%%%%%%%

updateAcquisitionSize(h); %VI042108A
%REPLACE BELOW WITH GENERAL HANDLER
% global state
% state.acq.numberOfZSlices=state.standardMode.numberOfZSlices;
% updateGUIByGlobal('state.acq.numberOfZSlices');
% reconcileStandardModeSettings;
% preallocateMemory;
% 
% %Don't allow external triggering for multi-slice acqs (VI041308A)
% if state.acq.numberOfZSlices > 1
%     state.acq.externallyTriggered = 0;
%     updateGUIByGlobal('state.acq.externallyTriggered');
% end
	
function varargout = numberOfFrames_Callback(h, eventdata, handles, varargin)
genericCallback(h); 
global state

updateAcquisitionSize(h); %VI042108A
% state.acq.numberOfFrames=state.standardMode.numberOfFrames;
% updateGUIByGlobal('state.acq.numberOfFrames');
% reconcileStandardModeSettings;
% 
% if isfield(state.acq,'dm')  %VI031408A
%     preallocateMemory;
%     alterDAQ_NewNumberOfFrames;
%     %Tim O'Connor 12/17/03 - Flag all Pockels cells, so they regenerate data for the right # of frames.
%     state.init.eom.changed(:) = 1;
% end


function varargout = averaging_Callback(h, eventdata, handles, varargin)
% Stub for Callback of most uicontrol handles
	genericCallback(h);
	global state
	state.acq.averaging=state.standardMode.averaging;
	updateHeaderString('state.acq.averaging');
    reconcileStandardModeSettings;
	preallocateMemory;
  
    
function cbSaveDuringAcq_Callback(h,eventdata,handles)
genericCallback(h); %VI091608A


function etFramesPerFile_Callback(h,eventdata,handles)        
genericCallback(h);


        
	
	