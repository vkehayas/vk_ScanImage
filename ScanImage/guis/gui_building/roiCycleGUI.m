function varargout = roiCycleGUI(varargin)
% ROICYCLEGUI Application M-file for roiCycleGUI.fig
%    FIG = ROICYCLEGUI launch roiCycleGUI GUI.
%    ROICYCLEGUI('callback_name', ...) invoke the named callback.

% Last Modified by GUIDE v2.5 20-Oct-2008 11:28:16

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Programming Notes:
% All the cycle information is stopred in an array called state.roiCycle.currentROICycle
% It has the following structure:
% Array of numbers that correspond to the fields in the roiCycleGUI...
% In order: [Repeats Period ROI NOF Avg Power]
% The number of rows indicates the number of positions in the cycle.

% --------------------------------------------------------------------
function varargout = roiCyclePosition_Callback(h, eventdata, handles, varargin)
genericCallback(h);
checkROICycleParams;
updateGUIFromCycle;
updateCurrentCycle;

% --------------------------------------------------------------------
function varargout = roiCyclePositionSlider_Callback(h, eventdata, handles, varargin)
genericCallback(h);
checkROICycleParams;
updateGUIFromCycle;
updateCurrentCycle;

% --------------------------------------------------------------------
function varargout = roiCycleNOF_Callback(h, eventdata, handles, varargin)
genericCallback(h);
checkROICycleParams;
updateCurrentCycle;
% --------------------------------------------------------------------
function varargout = roiCycleRepeat_Callback(h, eventdata, handles, varargin)
genericCallback(h);
checkROICycleParams;
updateCurrentCycle;
% --------------------------------------------------------------------
function varargout = roiCyclePeriod_Callback(h, eventdata, handles, varargin)
genericCallback(h);
updateCurrentCycle;
% --------------------------------------------------------------------
function varargout = roiCyclePower_Callback(h, eventdata, handles, varargin)
genericCallback(h);
updateCurrentCycle;
% --------------------------------------------------------------------
function varargout = roiCycleROI_Callback(h, eventdata, handles, varargin)
genericCallback(h);
checkROICycleParams;
updateCurrentCycle;
% --------------------------------------------------------------------
function varargout = roiCycleAvg_Callback(h, eventdata, handles, varargin)
genericCallback(h);
updateCurrentCycle;

% --------------------------------------------------------------------
function varargout = deletePos_Callback(h, eventdata, handles, varargin)
global state
cpos=state.roiCycle.roiCyclePosition;    %Current Position....  
if size(state.roiCycle.currentROICycle,1) == 1
    beep;
    disp('Cant delete last row in a cycle');
    return
else
    state.roiCycle.currentROICycle(cpos,:)=[];
    if state.roiCycle.roiCyclePosition > 1
        state.roiCycle.roiCyclePosition=state.roiCycle.roiCyclePosition-1;
        updateGUIByGlobal('state.roiCycle.roiCyclePosition');
    end
    updateGUIFromCycle;
    calculateTotalTimeAndLength;
end

% --------------------------------------------------------------------
function varargout = insertPos_Callback(h, eventdata, handles, varargin)
global state
cpos=state.roiCycle.roiCyclePosition;    %Current Position....  
state.roiCycle.roiCyclePosition=state.roiCycle.roiCyclePosition+1;
updateGUIByGlobal('state.roiCycle.roiCyclePosition');
if cpos >= size(state.roiCycle.currentROICycle,1)
    updateGUIFromCycle;
    updateCurrentCycle;
else
    state.roiCycle.currentROICycle(end+1,:)=0;  % add a row of zeros to end
    state.roiCycle.currentROICycle(state.roiCycle.roiCyclePosition+1:end,:)=...
        state.roiCycle.currentROICycle(state.roiCycle.roiCyclePosition:end-1,:);
    state.roiCycle.currentROICycle(state.roiCycle.roiCyclePosition,:)=...
        state.roiCycle.currentROICycle(cpos,:);
    updateGUIFromCycle;
    updateCurrentCycle
end

% --------------------------------------------------------------------
function varargout = currentPos_Callback(h, eventdata, handles, varargin)
genericCallback(h);
global state
if state.roiCycle.currentPos > size(state.roiCycle.currentROICycle,1)
    state.roiCycle.currentPos=size(state.roiCycle.currentROICycle,1);
    updateGUIByGlobal('state.roiCycle.currentPos');
end
% --------------------------------------------------------------------
function varargout = startROICycle_Callback(h, eventdata, handles, varargin)
global state gh
str=get(h,'String');
if strcmpi(str,'go')
    if isempty(state.roiCycle.currentROICycle) | strcmp(get(gh.mainControls.focusButton,'Visible'),'off') | ...
            strcmp(get(gh.mainControls.focusButton,'String'),'ABORT')
        beep;
        disp('Cant start cycle: Already acquiring.')
        return
    end
    if ~savingInfoIsOK;
        return
    end
    set(h,'String','STOP','ForegroundColor',[1 0 0]);
    state.internal.whatToDo=5;
    state.internal.roiCycleExecuting=1;
    state.roiCycle.firstTimeThroughLoop=1;
    %Do General preparationf for acquisition...
    h=gh.mainControls.grabOneButton;
    setStatusString('Acquiring ROI Cycle...');
    set(h, 'String', 'ABORT');
    set([gh.mainControls.focusButton gh.mainControls.startLoopButton], 'Visible', 'Off');
    turnOffMenus;
    executeROICycle(state.roiCycle.currentROICycle(state.roiCycle.currentPos,:),1);
else
    state.internal.roiCycleExecuting=0;
    abortROICycle(0);
    set(h,'String', 'GO','ForegroundColor',[0 .6 0]);
end

% --------------------------------------------------------------------
function varargout = resetROICycle_Callback(h, eventdata, handles, varargin)
global state gh
state.roiCycle.currentPos=1;
state.roiCycle.roiCyclePosition=1;
state.roiCycle.repeatNumber=0;
updateGUIByGlobal('state.roiCycle.currentPos');
updateGUIByGlobal('state.roiCycle.repeatNumber');
updateGUIByGlobal('state.roiCycle.roiCyclePosition');
roiCycleGUI('roiCyclePosition_Callback',gh.roiCycleGUI.roiCyclePosition);

% --------------------------------------------------------------------
function calculateTotalTimeAndLength
global state
% Calculates total cycle time and displays it.
if isempty(state.roiCycle.currentROICycle)
    return
else
    state.roiCycle.totalPos=size(state.roiCycle.currentROICycle,1);
    state.roiCycle.totalTime=...
        1/60*sum(state.roiCycle.currentROICycle(:,1).*state.roiCycle.currentROICycle(:,2));
    updateGUIByGlobal('state.roiCycle.totalTime');
    updateGUIByGlobal('state.roiCycle.totalPos');
end

% --------------------------------------------------------------------
function updateCurrentCycle
global state
% Update current cycle with new data.
newline=[];
fn={'roiCycleRepeat' 'roiCyclePeriod' 'roiCycleROI' 'roiCycleNOF' 'roiCycleAvg'  'roiCyclePower'};
for fnCounter=1:length(fn)
    newline=[newline getfield(state.roiCycle,fn{fnCounter})];
end
cpos=state.roiCycle.roiCyclePosition;    %Current Position....      
if isempty(state.roiCycle.currentROICycle)
    state.roiCycle.currentROICycle=newline;
else
    state.roiCycle.currentROICycle(cpos,:)=newline;
end
state.roiCycle.roiCycleSaved=0;
calculateTotalTimeAndLength;

% --------------------------------------------------------------------
function updateGUIFromCycle
global state
% Update GUI with current cycle data.
cpos=state.roiCycle.roiCyclePosition;    %Current Position....   
if cpos > size(state.roiCycle.currentROICycle,1)
    updateCurrentCycle;
end
fn={'roiCycleRepeat' 'roiCyclePeriod' 'roiCycleROI' 'roiCycleNOF' 'roiCycleAvg'  'roiCyclePower'};
for fnCounter=1:length(fn)
    state.roiCycle=setfield(state.roiCycle,fn{fnCounter},...
        state.roiCycle.currentROICycle(cpos,fnCounter));
    updateGUIByGlobal(['state.roiCycle.' fn{fnCounter}]);
end

% --------------------------------------------------------------------
function checkROICycleParams
global state
% Check all are integers
cpos=state.roiCycle.roiCyclePosition;    %Current Position....   
fn={'roiCycleRepeat' 'roiCycleROI' 'roiCycleNOF' 'roiCycleAvg'  'roiCyclePower'};
for fnCounter=1:length(fn)
    state.roiCycle=(setfield(state.roiCycle,fn{fnCounter},round(getfield(state.roiCycle,fn{fnCounter}))));
    updateGUIByGlobal(['state.roiCycle.' fn{fnCounter}]);
end
% --------------------------------------------------------------------
function varargout = loopROICycle_Callback(h, eventdata, handles, varargin)
genericCallback(h);
%TPMODBox



% --- Executes on button press in roiCycleStandardPower.
function roiCycleStandardPower_Callback(hObject, eventdata, handles)
global state gh;

genericCallback(hObject);

if state.roiCycle.standardPower
    set(gh.roiCycleGUI.roiCyclePower, 'Enable', 'Off');
else
    set(gh.roiCycleGUI.roiCyclePower, 'Enable', 'On');
end

return;


% --------------------------------------------------------------------
function pmBeamMenu_Callback(hObject, eventdata, handles)

genericCallback(hObject);

