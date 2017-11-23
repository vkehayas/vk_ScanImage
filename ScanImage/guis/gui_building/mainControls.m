function varargout = mainControls(varargin)
% Author: Bernardo Sabatini with modifications by Tom Pologruto
%
% MAINCONTROLS Application M-file for mainControls.fig
%    FIG = MAINCONTROLS launch mainControls GUI.
%    MAINCONTROLS('callback_name', ...) invoke the named callback.

% Last Modified by GUIDE v2.5 05-Nov-2008 18:06:06
%% CHANGES
% VI041308A: Disallow external triggering for multi-slice acquisitions -- Vijay Iyer 4/13/2008
% VI043008A: Specify key /release/ callback as a function handle in order to take advantage of eventdata feature-- Vijay Iyer 4/30/2008
% VI091508A: Employ absoute value with scanAmplitudeX/Y to handle case where scan direction is reversed by using negative value -- Vijay Iyer 9/15/2008
% VI091508B: Restored phase and phaseSlider controls (tied to cusp delay) and added FinePhaseControl checkbox -- Vijay Iyer 9/15/08
% VI091608A: Handle newly added autoSave checkbox -- Vijay Iyer 9/16/2008
% VI110608A: New implementation allowing scanOffset update to be optionally written to current INI file
% VI120108A: Abort current scan (if any) quietly when toggling line scan -- Vijay Iyer 12/01/08
% VI121908A: Handle removal of maxOffsetX/Y and maxAmplitudeX/Y parameters (and updateScanFOV function) -- Vijay Iyer 12/19/08
% VI121908B: Warn user before parking at scan center -- Vijay Iyer 12/19/08
%% ***************************************************

if nargin == 0  % LAUNCH GUI

	fig = openfig(mfilename,'reuse');

	% Generate a structure of handles to pass to callbacks, and store it. 
	handles = guihandles(fig);
	guidata(fig, handles);

	if nargout > 0
		varargout{1} = fig;
    end
    
    set(fig,'KeyPressFcn',@genericKeyPressFunction); %VI043008A
    %%%%VI070308 -- Ensure all children respond to key presses, when they have the focus (for whatever reason)
    kidControls = findall(fig,'Type','uicontrol');
    for i=1:length(kidControls)
        if ~strcmpi(get(kidControls(i),'Style'),'edit')
            set(kidControls(i),'KeyPressFcn',@genericKeyPressFunction');
        end
    end
    %%%%%%

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
	genericCallback(h);

	% --------------------------------------------------------------------
function varargout = focusButton_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.focusButton.
 	global state gh
	figure(gh.mainControls.figure1);
	state.internal.whatToDo=1;
	executeFocusCallback(h);	
		
% --------------------------------------------------------------------
function varargout = grabOneButton_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.grabOneButton.
 	global state gh
	figure(gh.mainControls.figure1);
	state.internal.whatToDo=2;
	executeGrabOneCallback(h);

% --------------------------------------------------------------------
function varargout = startLoopButton_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.startLoopButton.
 	global gh
	figure(gh.mainControls.figure1);
	executeStartLoopCallback(h);
	
% --------------------------------------------------------------------
function varargout =  genericZoomRot_Callback(h, eventdata, handles, varargin)
genericCallback(h);
setScanProps(h);

% --------------------------------------------------------------------
function varargout = mainZoom_Callback(h, eventdata, handles, varargin)
genericCallback(h);
setScanProps(h);

% --------------------------------------------------------------------
function varargout = fullfield_Callback(h, eventdata, handles, varargin)
global gh state
state.acq.zoomFactor=1;
updateGUIByGlobal('state.acq.zoomFactor');
state.acq.zoomhundreds=0;
state.acq.zoomtens=0;
state.acq.zoomones=1;
updateGUIByGlobal('state.acq.zoomhundreds');
updateGUIByGlobal('state.acq.zoomtens');
updateGUIByGlobal('state.acq.zoomones');
setScanProps(h);

% --------------------------------------------------------------------
function varargout = scaleYShift_Callback(h, eventdata, handles, varargin)
genericCallback(h);
setScanProps(h);

% --------------------------------------------------------------------
function varargout = scaleXShift_Callback(h, eventdata, handles, varargin)
genericCallback(h);
setScanProps(h);

% --------------------------------------------------------------------
function varargout = right_Callback(h, eventdata, handles, varargin)
global state
state.acq.scaleXShift=state.acq.scaleXShift+1/state.acq.zoomFactor*state.acq.xstep;
if abs(state.acq.scaleXShift) < .0001
    state.acq.scaleXShift=0;
end
%updateScanFOV; %VI062508A, VI121908A
updateGUIByGlobal('state.acq.scaleXShift');
setScanProps(h);

% --------------------------------------------------------------------
function varargout = left_Callback(h, eventdata, handles, varargin)
global state
state.acq.scaleXShift=state.acq.scaleXShift-1/state.acq.zoomFactor*state.acq.xstep;
if abs(state.acq.scaleXShift) < .0001
    state.acq.scaleXShift=0;
end
%updateScanFOV; %VI062508A, VI121908A
updateGUIByGlobal('state.acq.scaleXShift');
setScanProps(h);

% --------------------------------------------------------------------
function varargout = down_Callback(h, eventdata, handles, varargin)
global state
state.acq.scaleYShift=state.acq.scaleYShift+1/state.acq.zoomFactor*state.acq.ystep;
if abs(state.acq.scaleYShift) < .0001
    state.acq.scaleYShift=0;
end
%updateScanFOV; %VI062508A, VI121908A
updateGUIByGlobal('state.acq.scaleYShift');
setScanProps(h);

% --------------------------------------------------------------------
function varargout = up_Callback(h, eventdata, handles, varargin)
global state
state.acq.scaleYShift=state.acq.scaleYShift-1/state.acq.zoomFactor*state.acq.ystep;
if abs(state.acq.scaleYShift) < .0001
    state.acq.scaleYShift=0;
end
%updateScanFOV; %VI062508A, VI121908A
updateGUIByGlobal('state.acq.scaleYShift');
setScanProps(h);

% --------------------------------------------------------------------
function varargout = zero_Callback(h, eventdata, handles, varargin)
global state
state.acq.scaleYShift=0;
updateGUIByGlobal('state.acq.scaleYShift');
state.acq.scaleXShift=0;
updateGUIByGlobal('state.acq.scaleXShift');
setScanProps(h);

% --------------------------------------------------------------------
function varargout = ROI_Callback(h, eventdata, handles, varargin)
global state gh
buttonHandles=[gh.mainControls.grabOneButton gh.mainControls.focusButton gh.mainControls.startLoopButton];
if all(strcmpi(get(buttonHandles,'Visible'),'on'))
    setUndo;
    done=drawROISI(gca);
    if done
        setScanProps(gh.mainControls.ROI);
        snapShot(1);
    end
else
    beep;
    disp('Cant select ROI when acquiring or focusing.');
end

% --------------------------------------------------------------------
function done=drawROISI(handle)
global state
done=0;
[axis,volts_per_pixelX,volts_per_pixelY,sizeImage]=genericFigSelectionFcn(gca);
pos=(getrect(axis));
if pos(3)==0 | pos(4)==0
    return
end
state.acq.zoomFactor=ceil(state.acq.zoomFactor*round(sizeImage(1)./pos(3)));
updateGUIByGlobal('state.acq.zoomFactor');
updateZoomStrings;

centerX=(pos(1)+.5*pos(3));
centerY=(pos(2)+.5*pos(4));
state.acq.scaleXShift=state.acq.scaleXShift+volts_per_pixelX*(centerX-sizeImage(2)/2);
state.acq.scaleYShift=state.acq.scaleYShift+volts_per_pixelY*(centerY-sizeImage(1)/2);
updateGUIByGlobal('state.acq.scaleXShift');
updateGUIByGlobal('state.acq.scaleYShift');
done=1;

% --------------------------------------------------------------------
function varargout = reset_Callback(h, eventdata, handles, varargin)
global state gh
state.acq.scaleXShift=state.acq.scaleXShiftReset;
state.acq.scaleYShift=state.acq.scaleYShiftReset;
state.acq.scanRotation=state.acq.scanRotationReset;
state.acq.zoomFactor=state.acq.zoomFactorReset;
state.acq.zoomones=state.acq.zoomonesReset;
state.acq.zoomtens=state.acq.zoomtensReset;
state.acq.zoomhundreds=state.acq.zoomhundredsReset;
updateGUIByGlobal('state.acq.scaleYShift');
updateGUIByGlobal('state.acq.scaleXShift');
updateGUIByGlobal('state.acq.zoomFactor');
updateGUIByGlobal('state.acq.zoomhundreds');
updateGUIByGlobal('state.acq.zoomtens');
updateGUIByGlobal('state.acq.zoomones');
updateGUIByGlobal('state.acq.scanRotation');
setScanProps(h);
buttonHandles=[gh.mainControls.grabOneButton gh.mainControls.focusButton gh.mainControls.startLoopButton];
if all(strcmpi(get(buttonHandles,'Visible'),'on'))
    snapShot(1);
end
setUndo;
% -------------------------------------------------------------------
function varargout = ystep_Callback(h, eventdata, handles, varargin)
genericCallback(h);

% --------------------------------------------------------------------
function varargout = xstep_Callback(h, eventdata, handles, varargin)
genericCallback(h);

% --------------------------------------------------------------------
function varargout = showrotbox_Callback(h, eventdata, handles, varargin)
global state gh
currentString=get(h,'String');
pos=get(ancestor(h,'figure'),'position'); %VI070308A -- replace get(h,'Parent') with ancestor(h,'figure')
if strcmp(currentString,'>>')
    set(h,'String','<<');
    pos(3)=92.6;
    set(ancestor(h,'figure'),'position',pos); %VI070308A -- replace get(h,'Parent') with gcbf
else
    set(h,'String','>>');
    pos(3)=48;
    set(ancestor(h,'figure'),'position',pos); %VI070308A -- replace get(h,'Parent') with gcbf
end
state.acq.showrotbox=get(h,'String');

% --------------------------------------------------------------------
function varargout = linescan_Callback(h, eventdata, handles, varargin)
global state gh
genericCallback(h);
if strcmp(get(gh.mainControls.focusButton,'Visible'),'off')
    beep;
    disp('Cant switch to linescan during acquisition.  Must be Focusing');
    return
end
set(h,'Enable','off');
try
    focus=0;
    if ~strcmpi(get(gh.mainControls.focusButton,'String'),'FOCUS')
        focus=1;
    end    
    abortCurrent(0); %VI120108A
    if state.acq.linescan==1
        state.internal.oldAmplitude=state.acq.scanAmplitudeY;
        state.acq.scanAmplitudeY=0;
        
        %12/16/03 Tim O'Connor - Make things a little more obvious, when using a powerbox.
%         set(gh.powerControl.startFrametext, 'String', 'Start Line');
%         set(gh.powerControl.endFrametext, 'String', 'End Line');
        set(gh.powerControl.text30, 'String', 'Lines:');
    else
        state.acq.scanAmplitudeY=state.internal.oldAmplitude;
        
        %12/16/03 Tim O'Connor - Make things a little more obvious, when using a powerbox.
%         set(gh.powerControl.startFrametext, 'String', 'Start Frame');
%         set(gh.powerControl.endFrametext, 'String', 'End Frame');
        set(gh.powerControl.text30, 'String', 'Frames:');
    end
    updateGUIByGlobal('state.acq.scanAmplitudeY');
    setImagesToWhole;
    checkConfigSettings;
	stopGrab;
	stopFocus;
	
	setupDAQDevices_ConfigSpecific;
	preallocateMemory;
	setupAOData;
    flushAOData;
	resetCounters;
	updateHeaderString('state.acq.pixelsPerLine');
	updateHeaderString('state.acq.fillFraction');
	state.internal.configurationChanged=0;
	startPMTOffsets;
    if focus
        executeFocusCallback(gh.mainControls.focusButton);
    end
    set(h,'Enable','on');
catch
    set(h,'Enable','on');
end
% --------------------------------------------------------------------
function varargout = phase_Callback(h, eventdata, handles, varargin)
genericCallback(h);
% --------------------------------------------------------------------
function varargout = phaseSlider_Callback(h, eventdata, handles, varargin)
genericCallback(h);
% --------------------------------------------------------------------
function done=setLS(handle)
global state gh
done=0;
setImagesToWhole;
if nargin<1
    axis=state.internal.axis(logical(state.acq.imagingChannel));
    image=state.internal.imagehandle(logical(state.acq.imagingChannel));
    axis=axis(1);
    image=image(1);
elseif ishandle(handle)
    ind=find(handle==state.internal.axis);
    if isempty(ind)
        return
    end
    axis=handle;
    image=state.internal.imagehandle(ind);
else
    ~ishandle(handle)
    return
end
fractionUsedXDirection=state.acq.fillFraction;
x=get(axis,'XLim');
y=get(axis,'YLim');
sizeImage=[y(2) round(state.acq.roiCalibrationFactor*x(2))];
volts_per_pixelX=((1/state.acq.zoomFactor)*2*fractionUsedXDirection*abs(state.acq.scanAmplitudeX))/sizeImage(2); %VI091508A
volts_per_pixelY=((1/state.acq.zoomFactor)*2*abs(state.acq.scanAmplitudeY))/sizeImage(1); %VI091508A
[xpt,ypt]=getline(axis);
slope=(ypt(2)-ypt(1))/(xpt(2)-xpt(1));
state.acq.scanRotation=state.acq.scanRotation-(180/pi*atan(slope));
updateGUIByGlobal('state.acq.scanRotation');

centerX=.5*(xpt(1)+xpt(2));
centerY=.5*(ypt(1)+ypt(2));
 
state.acq.scaleXShift=state.acq.scaleXShift+volts_per_pixelX*(centerX-x(2)/2);
state.acq.scaleYShift=state.acq.scaleYShift+volts_per_pixelY*(centerY-sizeImage(1)/2);
updateGUIByGlobal('state.acq.scaleXShift');
updateGUIByGlobal('state.acq.scaleYShift');

done=1;
% --------------------------------------------------------------------
function varargout = abortCurrentAcq_Callback(h, eventdata, handles, varargin)
abortCurrent;

% --------------------------------------------------------------------
function varargout = zoomhundredsslider_Callback(h, eventdata, handles, varargin)
setZoom(h);
% --------------------------------------------------------------------
function varargout = zoomhundreds_Callback(h, eventdata, handles, varargin)
setZoom(h);
% --------------------------------------------------------------------
function varargout = zoomtensslider_Callback(h, eventdata, handles, varargin)
global state
genericCallback(h);
if state.acq.zoomtens == 10 & state.acq.zoomhundreds<9
    state.acq.zoomtens=0;
    state.acq.zoomhundreds=state.acq.zoomhundreds+1;
elseif state.acq.zoomtens == 10 & state.acq.zoomhundreds>=9
    state.acq.zoomtens=9;
elseif state.acq.zoomtens == -1 & state.acq.zoomhundreds>1
    state.acq.zoomtens=9;
    state.acq.zoomhundreds=state.acq.zoomhundreds-1;
elseif state.acq.zoomtens == -1 & state.acq.zoomhundreds==1
    state.acq.zoomones=9;
    state.acq.zoomtens=9;
    state.acq.zoomhundreds=0;
elseif state.acq.zoomtens == -1 & state.acq.zoomhundreds < 1
    state.acq.zoomtens=0;
end
updateGUIByGlobal('state.acq.zoomones');
updateGUIByGlobal('state.acq.zoomtens');
updateGUIByGlobal('state.acq.zoomhundreds');
setZoom(h);
% --------------------------------------------------------------------
function varargout = zoomtens_Callback(h, eventdata, handles, varargin)
setZoom(h);
% --------------------------------------------------------------------
function varargout = zoomonesslider_Callback(h, eventdata, handles, varargin)
genericCallback(h);

global state
if state.acq.zoomones == 10 & state.acq.zoomtens<9
    state.acq.zoomones=0;
    state.acq.zoomtens=state.acq.zoomtens+1;
elseif state.acq.zoomones == 10 & state.acq.zoomtens>=9
    state.acq.zoomones=0;
    state.acq.zoomtens=0;
    state.acq.zoomhundreds=1;
elseif state.acq.zoomones < 0 & state.acq.zoomtens>=1
    state.acq.zoomones=9;
    state.acq.zoomtens=state.acq.zoomtens-1;
elseif state.acq.zoomones < 0 & state.acq.zoomtens<1 & state.acq.zoomhundreds>=1
    state.acq.zoomones=9;
    state.acq.zoomtens=9;
    state.acq.zoomhundreds=state.acq.zoomhundreds-1;
end
updateGUIByGlobal('state.acq.zoomones');
updateGUIByGlobal('state.acq.zoomtens');
updateGUIByGlobal('state.acq.zoomhundreds');
setZoom(h);

% --------------------------------------------------------------------
function varargout = zoomones_Callback(h, eventdata, handles, varargin)
setZoom(h);
% --------------------------------------------------------------------
function setZoom(h)
set(h,'Value',round(get(h,'Value')));
genericCallback(h);

global state
state.acq.zoomFactor=str2num([num2str(round(state.acq.zoomhundreds))...
        num2str(round(state.acq.zoomtens)) num2str(round(state.acq.zoomones))]);
if state.acq.zoomFactor < 1
    state.acq.zoomFactor=1;
    state.acq.zoomones=1;
    updateGUIByGlobal('state.acq.zoomones');
end
setScanProps(h);



% --------------------------------------------------------------------
function varargout = shutterDelay_Callback(h, eventdata, handles, varargin)
genericCallback(h);
updateShutterDelay;



% --------------------------------------------------------------------
function varargout = syncToPhysiology_Callback(h, eventdata, handles, varargin)
genericCallback(h);



% --------------------------------------------------------------------
function varargout = selectLineScanAngle_Callback(h, eventdata, handles, varargin)
global state gh
buttonHandles=[gh.mainControls.grabOneButton gh.mainControls.focusButton gh.mainControls.startLoopButton];
if all(strcmpi(get(buttonHandles,'Visible'),'on'))
    setUndo;
    done=setLS(gca);
    if done
        setScanProps(h);
        snapShot(1);
    end
else
    beep;
    disp('Cant select LS angle when acquiring or focusing.');
end


% --------------------------------------------------------------------
function varargout = setReset_Callback(h, eventdata, handles, varargin)
defineReset;
global gh state
buttonHandles=[gh.mainControls.grabOneButton gh.mainControls.focusButton gh.mainControls.startLoopButton];
while ~all(strcmpi(get(buttonHandles,'Visible'),'on'))
    pause(.001);
end
index=~cellfun('isempty',state.acq.acquiredData);
channels=find(index==1);
data=state.acq.acquiredData(index);
new=[];
hi=[];
low=[];
if ~isempty(data)
    for j=1:length(data)
        low=min([low state.internal.lowPixelValue(channels(j))]);
        hi=max([hi state.internal.highPixelValue(channels(j))]);
        new=max(cat(3,new,data{j}(:,:,1)),[],3);
    end
    set(state.internal.roiimage,'CData',new)
    set(state.internal.roiaxis,'CLim',[low hi]);
end
state.acq.roiList=[];
set(gh.mainControls.roiSaver,'Value',1,'String',' ');
drawROIsOnFigure;

% --------------------------------------------------------------------
function varargout = addROI_Callback(h, eventdata, handles, varargin)
addROI;

% --------------------------------------------------------------------
function varargout = roiSaver_Callback(h, eventdata, handles, varargin)
gotoROI(h);

%---------------------------------------------------------------------
function defineReset
global state gh
state.acq.scaleXShiftReset=state.acq.scaleXShift;
state.acq.scaleYShiftReset=state.acq.scaleYShift;
state.acq.scanRotationReset=state.acq.scanRotation;
state.acq.zoomFactorReset=state.acq.zoomFactor;
state.acq.zoomonesReset=state.acq.zoomones;
state.acq.zoomtensReset=state.acq.zoomtens;
state.acq.zoomhundredsReset=state.acq.zoomhundreds;
mainControls('reset_Callback',gh.mainControls.reset);

%---------------------------------------------------------------------
function addROI
global state gh
updateMotorPosition;
state.acq.roiList=[state.acq.roiList; [state.acq.scaleXShift state.acq.scaleYShift state.acq.scanRotation...
            state.acq.zoomFactor state.acq.zoomones state.acq.zoomtens state.acq.zoomhundreds ...
            state.motor.absXPosition state.motor.absYPosition state.motor.absZPosition]];
set(gh.mainControls.roiSaver,'String',cellstr(num2str((1:size(state.acq.roiList,1))')));
drawROIsOnFigure;

% --------------------------------------------------------------------
function varargout = dropROI_Callback(h, eventdata, handles, varargin)
global gh state
if isempty(state.acq.roiList)
    return
end
str=get(gh.mainControls.roiSaver,'String');
val=get(gh.mainControls.roiSaver,'Value');
if ~isempty(str) 
    state.acq.roiList(val,:)=[];
    set(gh.mainControls.roiSaver,'Value',max(val-1,1));
    set(gh.mainControls.roiSaver,'String',cellstr(num2str((1:size(state.acq.roiList,1))')));
end
drawROIsOnFigure;


% --------------------------------------------------------------------
function varargout = backROI_Callback(h, eventdata, handles, varargin)
global gh state
str=get(gh.mainControls.roiSaver,'String');
if ~iscellstr(str) 
    return
end
val=get(gh.mainControls.roiSaver,'Value');
if val == 1
    val=length(str);
else
    val=val-1;
end
set(gh.mainControls.roiSaver,'Value',val);
gotoROI(h);

% --------------------------------------------------------------------
function varargout = nextROI_Callback(h, eventdata, handles, varargin)
global gh state
str=get(gh.mainControls.roiSaver,'String');
if ~iscellstr(str) 
    return
end
val=get(gh.mainControls.roiSaver,'Value');
if val == length(str)
    val=1;
else
    val=val+1;
end
set(gh.mainControls.roiSaver,'Value',val);
gotoROI(h);

% --------------------------------------------------------------------
function varargout = snapShot_Callback(h, eventdata, handles, varargin)
global state
old=state.acq.acquireImageOnChange;
state.acq.acquireImageOnChange=1;
snapShot(state.acq.numberOfFramesSnap);
state.acq.acquireImageOnChange=old;


% --------------------------------------------------------------------
function varargout = numberOfFramesSnap_Callback(h, eventdata, handles, varargin)
genericCallback(h);

% --------------------------------------------------------------------
function varargout = centerOnSelection_Callback(h, eventdata, handles, varargin)
global state gh
buttonHandles=[gh.mainControls.grabOneButton gh.mainControls.focusButton gh.mainControls.startLoopButton];
if all(strcmpi(get(buttonHandles,'Visible'),'on'))
    setUndo;
    done=centerOnSelection(gca);
    if done
        setScanProps(h);
        snapShot(1);
    end
else
    beep;
    disp('Cant select ROI when acquiring or focusing.');
end

% --------------------------------------------------------------------
function done=centerOnSelection(handle)
global state gh
done=0;
setImagesToWhole;
if nargin<1
    axis=state.internal.axis(logical(state.acq.imagingChannel));
    image=state.internal.imagehandle(logical(state.acq.imagingChannel));
    axis=axis(1);
    image=image(1);
elseif ishandle(handle)
    ind=find(handle==state.internal.axis);
    if isempty(ind)
        return
    end
    axis=handle;
    image=state.internal.imagehandle(ind);
else
    ~ishandle(handle)
    return
end
fractionUsedXDirection=state.acq.fillFraction;
x=get(axis,'XLim');
y=get(axis,'YLim');
sizeImage=[y(2) round(state.acq.roiCalibrationFactor*x(2))];
volts_per_pixelX=((1/state.acq.zoomFactor)*2*fractionUsedXDirection*abs(state.acq.scanAmplitudeX))/sizeImage(2); %VI091508A
volts_per_pixelY=((1/state.acq.zoomFactor)*2*abs(state.acq.scanAmplitudeY))/sizeImage(1); %VI091508A
[xpt,ypt]=getpts(axis);
if isempty(xpt)
    return
elseif length(xpt)>1
    xpt=xpt(end);
    ypt=ypt(end);
end
centerX=(xpt);
centerY=(ypt);
state.acq.scaleXShift=state.acq.scaleXShift+volts_per_pixelX*(centerX-x(2)/2);
state.acq.scaleYShift=state.acq.scaleYShift+volts_per_pixelY*(centerY-sizeImage(1)/2);
updateGUIByGlobal('state.acq.scaleXShift');
updateGUIByGlobal('state.acq.scaleYShift');
done=1;

% --------------------------------------------------------------------
function varargout = zeroRotate_Callback(h, eventdata, handles, varargin)
global state
state.acq.scanRotation=0;
updateGUIByGlobal('state.acq.scanRotation');
setScanProps(h);

% --------------------------------------------------------------------
function varargout = undo_Callback(h, eventdata, handles, varargin)
global state gh

if ~isempty(state.acq.lastROIForUndo)
    state.acq.scaleXShift=state.acq.lastROIForUndo(1);
    state.acq.scaleYShift=state.acq.lastROIForUndo(2);
    state.acq.scanRotation=state.acq.lastROIForUndo(3);
    state.acq.zoomFactor=state.acq.lastROIForUndo(4);
    updateGUIByGlobal('state.acq.scaleYShift');
    updateGUIByGlobal('state.acq.scaleXShift');
    updateGUIByGlobal('state.acq.zoomFactor');
    updateGUIByGlobal('state.acq.scanRotation');
    setScanProps(h);
    buttonHandles=[gh.mainControls.grabOneButton gh.mainControls.focusButton gh.mainControls.startLoopButton];
    if all(strcmpi(get(buttonHandles,'Visible'),'on'))
        snapShot(1);
    end
end


% --------------------------------------------------------------------
function tbExternalTrig_Callback(h, eventdata, handles)
global state

%Disallow external trigger for multi-slice acqusitions (VI041308A)
if state.acq.numberOfZSlices > 1
    state.acq.externallyTriggered = 0;
    updateGUIByGlobal('state.acq.externallyTriggered');
    setStatusString('Ext trig not possible');
    disp('External triggering not possible for multi-slice acquisitions');
else
    genericCallback(h);
end


% --------------------------------------------------------------------
function cbInfiniteFocus_Callback(h, eventdata, handles)
genericCallback(h);

% --------------------------------------------------------------------
function pbParkAtOffset_Callback(hObject, eventdata, handles)
% hObject    handle to pbParkAtOffset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global state gh
figure(gh.mainControls.figure1);

resp = questdlg('Click OK to park laser beam at scan center for beam alignment/measurement. Shutter will be opened.','Park Beam @ Center','OK', 'Cancel', 'OK'); %VI121908B
if strcmpi(resp,'OK') %VI121908B
    scim_parkLaser([state.init.scanOffsetX state.init.scanOffsetY]);
    h = msgbox('Click when done aligning and/or measuring the laser beam','Park Beam @ Center','modal');
    uiwait(h);
    scim_parkLaser;
end


% --------------------------------------------------------------------
function pbSetOffset_Callback(hObject, eventdata, handles)

global state gh

if state.acq.scanRotation
    h=msgbox('Cannot set X/Y ScanOffset with non-zero rotation. Collect image with rotation set to 0 before setting X/Y ScanOffset.');
    uiwait(h);
else
    h=gh.mainControls.focusButton;
    if strcmpi(get(h,'String'),'Abort') %presently focusing
        abortFocus;
    end
    
    %%%VI110608A%%%%%%%%%%%%%    
    %Cache shift values, to restore if needed
    cachedXShift = state.acq.scaleXShift;
    cachedYShift = state.acq.scaleYShift;

    state.init.scanOffsetX = state.init.scanOffsetX + state.acq.scaleXShift;
    state.init.scanOffsetY = state.init.scanOffsetY + state.acq.scaleYShift;

    %%%VI121908A%%%%%%%%
    state.acq.scaleXShift = 0;
    state.acq.scaleYShift = 0;    
    %     if abs(state.init.scanOffsetX) <= state.init.maxOffsetX
    %         state.acq.scaleXShift = 0;
    %     else
    %         h = warndlg(['Offset value cannot exceed ' num2str(state.init.maxOffsetX) '. Excess shift remains.'], 'Exceeded Max Offset', 'modal');
    %         uiwait(h);
    %         state.acq.scaleXShift = sign(state.init.scanOffsetX) * (abs(state.init.scanOffsetX)-state.init.maxOffsetX);
    %         state.init.scanOffsetX = sign(state.init.scanOffsetX) * state.init.maxOffsetX;
    %     end
    %
    %     if abs(state.init.scanOffsetY) <= state.init.maxOffsetY
    %         state.acq.scaleYShift = 0;
    %     else
    %         h = warndlg(['Offset value cannot exceed ' num2str(state.init.maxOffsetY) '. Excess shift remains.'], 'Exceeded Max Offset', 'modal');
    %         uiwait(h);
    %         state.acq.scaleYShift = sign(state.init.scanOffsetY) * (abs(state.init.scanOffsetY)-state.init.maxOffsetY);
    %         state.init.scanOffsetY = sign(state.init.scanOffsetY) * state.init.maxOffsetY;
    %     end
    %%%%%%%%%%%%%%%%%%%%%%
    
    updateGUIByGlobal('state.init.scanOffsetX');
    updateGUIByGlobal('state.init.scanOffsetY');
    updateGUIByGlobal('state.acq.scaleXShift');
    updateGUIByGlobal('state.acq.scaleYShift');

    iniFileName = [state.iniPath filesep state.iniName '.ini'];
    resp = questdlg(['Save new offset values to current INI file?' sprintf('\n') '(' iniFileName ')']);
    switch resp
        case 'Yes'
            resp2 = questdlg(['INI files are commonly shared between multiple users on a rig.' sprintf('\n') 'Save new Offset values to INI file anyway?'],'WARNING', 'Yes','No','No');
            if strcmpi(resp2,'Yes')
                iniFID = fopen(iniFileName,'r+');
                while ~feof(iniFID)
                    writeNewLine = false;
                    finished = false;

                    posn = ftell(iniFID);
                    origLine = fgets(iniFID);
%                     newLineX = regexprep(origLine, 'scanOffsetX=(?:-?[0-9]+\.?[0-9]*)\w*([^\n]*)',['scanOffsetX=' num2str(state.init.scanOffsetX,'%0.2f') '$1']);
%                     newLineY = regexprep(origLine, 'scanOffsetY=(?:-?[0-9]+\.?[0-9]*)\w*([^\n]*)',['scanOffsetY=' num2str(state.init.scanOffsetY,'%0.2f') '$1']);
                    [startX, endX] = regexp(origLine,'scanOffsetX=(?:-?[0-9]+\.?[0-9]*)','start','end');
                    [startY, endY] = regexp(origLine,'scanOffsetY=(?:-?[0-9]+\.?[0-9]*)','start','end');

                    %if ~strcmp(origLine,newLineX)
                    if ~isempty(startX)
                        writeNewLine = true;
                        %newLine = newLineX
                        posn = posn+(startX-1);
                        newLine = ['scanOffsetX=' num2str(state.init.scanOffsetX,'%0.2f')];
                        extraSpaces = (endX-startX+1) - length(newLine);
                        %while (endX-startX+1) > length(newLine)
                        %    newLine = [newLine ''];
                        %end
                    %elseif ~strcmp(origLine,newLineY)
                    elseif ~isempty(startY)
                        writeNewLine = true;
                        finished = true;
                        %newLine = newLineY
                        posn = posn+(startY-1);
                        newLine = ['scanOffsetY=' num2str(state.init.scanOffsetY,'%0.2f')];
                        extraSpaces = (endY-startY+1) - length(newLine);
                        %while (endY-startY+1) > length(newLine)
                        %    newLine = [newLine ''];
                        %end
                    end

                    if writeNewLine
                        fseek(iniFID,posn,'bof');
                        fprintf(iniFID,'%s',newLine);
                        for i=1:length(extraSpaces)
                            fprintf(iniFID,' ');
                        end
                    end

                    if finished
                        break;
                    end
                end
                fclose(iniFID);
            end

        case 'No'
            %all done!
        case 'Cancel'
            %Restore Shift&Offset values
            state.acq.scaleXShift = cachedXShift;
            state.acq.scaleYShift = cachedYShift;

            state.init.scanOffsetX = state.init.scanOffsetX - state.acq.scaleXShift;
            state.init.scanOffsetY = state.init.scanOffsetY - state.acq.scaleYShift;

            updateGUIByGlobal('state.init.scanOffsetX');
            updateGUIByGlobal('state.init.scanOffsetY');
            updateGUIByGlobal('state.acq.scaleXShift');
            updateGUIByGlobal('state.acq.scaleYShift');
    end
    %%%%%%%%%%%%%%
    

    %     h = msgbox(['The X/Y ScanOffset parameters have been updated: ' sprintf('\n') ...
    %         sprintf('\n') ...
    %         'scanOffsetX=' num2str(state.init.scanOffsetX) sprintf('\n') ...
    %         'scanOffsetY=' num2str(state.init.scanOffsetY) sprintf('\n') ...
    %         sprintf('\n') ...
    %     'Update scanOffsetX and scanOffsetY in the ''standard.ini'' file to store these new values'],'ScanOffsetX/Y Updated');
    %     uiwait(h);

    applyConfigurationSettings; %Though scanOffsetX/Y are not part of configuration, handle this as if a new configruation was loaded
end


% ------------------------(VI091508B)------------------------------------
function cbFinePhaseAdjust_Callback(hObject, eventdata, handles)
% hObject    handle to cbFinePhaseAdjust (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global gh

sliderStep = get(gh.mainControls.phaseSlider,'SliderStep');

if get(hObject,'Value')
    sliderStep(1) = .005;
else
    sliderStep(1) = .025;
end


% ------------------------(VI091608A)------------------------------------
function cbAutoSave_Callback(hObject, eventdata, handles)
% hObject    handle to cbAutoSave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

genericCallback(hObject);





function etScanOffsetY_Callback(hObject, eventdata, handles)
% hObject    handle to etScanOffsetY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of etScanOffsetY as text
%        str2double(get(hObject,'String')) returns contents of etScanOffsetY as a double


% --- Executes during object creation, after setting all properties.
function etScanOffsetY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to etScanOffsetY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function etScanOffsetX_Callback(hObject, eventdata, handles)
% hObject    handle to etScanOffsetX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of etScanOffsetX as text
%        str2double(get(hObject,'String')) returns contents of etScanOffsetX as a double


% --- Executes during object creation, after setting all properties.
function etScanOffsetX_CreateFcn(hObject, eventdata, handles)
% hObject    handle to etScanOffsetX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit34_Callback(hObject, eventdata, handles)
% hObject    handle to edit34 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit34 as text
%        str2double(get(hObject,'String')) returns contents of edit34 as a double


% --- Executes during object creation, after setting all properties.
function edit34_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit34 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


