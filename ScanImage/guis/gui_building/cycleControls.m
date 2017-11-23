function varargout = cycleControls(varargin)
% CYCLECONTROLS Application M-file for cycleControls.fig
%    FIG = CYCLECONTROLS launch cycleControls GUI.
%    CYCLECONTROLS('callback_name', ...) invoke the named callback.

% Author: Bernardo Sabatini
% 
% Last Modified by GUIDE v2.5 29-Oct-2009 19:37:25

if nargin == 0  % LAUNCH GUI

  fig = openfig(mfilename,'reuse');


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
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

elseif ischar(varargin{1}) % INVOKE NAMED SUBFUNCTION OR CALLBACK

  try
    [varargout{1:nargout}] = feval(varargin{:}); % FEVAL switchyard
  catch
    disp(lasterr);
  end

end
% ---------------------- end cycleControls ---------------------------


%| ABOUT CALLBACKS:
%| GUIDE automatically appends subfunction prototypes to this file, and 
%| sets objects' callback properties to call them through the FEVAL 
%| switchyard above. This comment describes that mechanism.
%|
%| Each callback subfunction declaration has the following form:
%| SUBFUNCTION_NAME(H, EVENTDATA, HANDLES, VARARGIN)
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
%| CYCLECONTROLS('SUBFUNCTION_NAME', gcbo, [], guidata(gcbo))
%| Add any extra arguments after the last argument, before the final
%| closing parenthesis.

function varargout = generic_Callback(h, eventdata, handles, varargin)
	genericCallback(h);
	saveCurrentCyclePosition;
	global state
	state.internal.cycleChanged=1;
	
function varargout = averaging_Callback(h, eventdata, handles, varargin)
	genericCallback(h);
	saveCurrentCyclePosition;
	global state
	state.internal.cycleChanged=1;
	if state.internal.position==state.internal.positionToExecute
		state.acq.averaging=state.cycle.averaging;
		updateHeaderString('state.acq.averaging');
		preallocateMemory;
	end

function varargout = repeats_Callback(h, eventdata, handles, varargin)
	genericCallback(h);
	saveCurrentCyclePosition;
	global state
	state.internal.cycleChanged=1;
	if state.internal.position==state.internal.positionToExecute
		state.internal.repeatsTotal=state.cycle.repeats;
		updateGUIByGlobal('state.internal.repeatsTotal');
	end
	
function varargout = timeDelay_Callback(h, eventdata, handles, varargin)
	genericCallback(h);
	saveCurrentCyclePosition;
	global state
	state.internal.cycleChanged=1;
	if state.internal.position==state.internal.positionToExecute
		state.internal.secondsCounter=state.cycle.timeDelay;
		updateGUIByGlobal('state.internal.secondsCounter');
	end

function varargout = numberOfZSlices_Callback(h, eventdata, handles, varargin)
	genericCallback(h);
	saveCurrentCyclePosition;
	global state
	state.internal.cycleChanged=1;
	if state.internal.position==state.internal.positionToExecute
		state.acq.numberOfZSlices=state.cycle.numberOfZSlices;
		updateGUIByGlobal('state.acq.numberOfZSlices');
		preallocateMemory;
	end

function varargout = numberOfFrames_Callback(h, eventdata, handles, varargin)
	genericCallback(h);
	saveCurrentCyclePosition;
	global state
	state.internal.cycleChanged=1;
	if state.internal.position==state.internal.positionToExecute
		state.acq.numberOfFrames=state.cycle.numberOfFrames;
		updateGUIByGlobal('state.acq.numberOfFrames');
		preallocateMemory;
		alterDAQ_NewNumberOfFrames;
	end

function varargout = zStep_Callback(h, eventdata, handles, varargin)
	genericCallback(h);
	saveCurrentCyclePosition;
	global state
	state.internal.cycleChanged=1;
	if state.internal.position==state.internal.positionToExecute
		state.acq.zStepSize=state.cycle.zStepPerSlice;
		updateHeaderString('state.acq.zStepSize');
	end

function varargout = returnHome_Callback(h, eventdata, handles, varargin)
	genericCallback(h);
	saveCurrentCyclePosition;
	global state
	state.internal.cycleChanged=1;
	if state.internal.position==state.internal.positionToExecute
		state.acq.returnHome=state.cycle.returnHome;
		updateHeaderString('state.acq.returnHome');
	end

% --------------------------------------------------------------------
function varargout = chooseConfigButton_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.chooseConfigButton.
global state gh
	chooseCycleConfig;
	if state.internal.position==state.internal.positionToExecute
		state.configName='';
		state.configPath='';
		applyCyclePositionSettings
	end
	saveCurrentCyclePosition;



% --------------------------------------------------------------------
function etNumCycles_Callback(h, eventdata, handles)
global state
genericCallback(h);
state.internal.cycleChanged=1;


