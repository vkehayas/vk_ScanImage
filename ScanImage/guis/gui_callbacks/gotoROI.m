function gotoROI(h)
global state gh
set(h,'Enable','off');
str=get(gh.mainControls.roiSaver,'String');
val=get(gh.mainControls.roiSaver,'Value');
if ~isempty(str) 
    if iscellstr(str) 
        str=str{val};
    end
    num=str2num(str);
    if isempty(num)
        beep;
        disp('No ROI Defined. Hit Add');
        return
    end
    %Do scan parameters...........
    vars={'state.acq.scaleXShift' 'state.acq.scaleYShift' 'state.acq.scanRotation'...
            'state.acq.zoomFactor' 'state.acq.zoomones' 'state.acq.zoomtens' 'state.acq.zoomhundreds'};
    current=state.acq.roiList(num,:);
    for varCounter=1:length(vars)
        eval([vars{varCounter} '=current(varCounter);']);
        updateGUIByGlobal(vars{varCounter});
    end
    current(1:length(vars))=[];
     %Do motor parameters...........
    if state.motor.motorOn & state.acq.controlMotorInROI 
        currentPos=updateMotorPosition; %In actual coordinates....
        [state.motor.absXPosition state.motor.absYPosition state.motor.absZPosition]=deal(current(1),current(2),current(3));
        if (any(currentPos~=[state.motor.absXPosition state.motor.absYPosition state.motor.absZPosition]))
            state.motor.relXPosition = state.motor.absXPosition - state.motor.offsetX; % Calculate absoluteX Position
            state.motor.relYPosition = state.motor.absYPosition - state.motor.offsetY; % Calculate absoluteX Position
            state.motor.relZPosition = state.motor.absZPosition - state.motor.offsetZ; % Calculate absoluteX Position
            updateGUIByGlobal('state.motor.relXPosition');
            updateGUIByGlobal('state.motor.relYPosition');
            updateGUIByGlobal('state.motor.relZPosition');
            motorGUI('relPos_Callback',gh.motorGUI.zPos);
        end
    end
    setScanProps(h,'enable','off');
    buttonHandles=[gh.mainControls.grabOneButton gh.mainControls.focusButton gh.mainControls.startLoopButton];
    if all(strcmpi(get(buttonHandles,'Visible'),'on'))
        snapShot(1);
    end
end
set(h,'Enable','on');