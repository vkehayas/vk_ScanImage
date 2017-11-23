function setROIProps(num)
global state gh

vars={'state.acq.scaleXShift' 'state.acq.scaleYShift' 'state.acq.scanRotation'...
        'state.acq.zoomFactor' 'state.acq.zoomones' 'state.acq.zoomtens' 'state.acq.zoomhundreds'};
vals=state.acq.roiList;
if isempty(state.acq.roiList)
    disp('No ROIs Defined. Using full field.');
    vals=[state.acq.scaleXShiftReset state.acq.scaleYShiftReset state.acq.scanRotationReset...
            state.acq.zoomFactorReset state.acq.zoomonesReset state.acq.zoomtensReset state.acq.zoomhundredsReset];
    num=1;
elseif num > size(state.acq.roiList,1)
    disp(['ROI ' num2str(num) ' not Defined. Using last roi...']);
    num=max(size(state.acq.roiList,1),1);
end
current=vals(num,:);
for varCounter=1:length(vars)
    eval([vars{varCounter} '=current(varCounter);']);
% fprintf(1, '%s = %s\n', vars{varCounter}, num2str(current(varCounter)));
    updateGUIByGlobal(vars{varCounter});
end

current(1:length(vars))=[];
%Do motor parameters...........
if state.motor.motorOn & state.acq.controlMotorInROI & ~isempty(state.acq.roiList)
    currentPos=updateMotorPosition; %In actual coordinates....
    [state.motor.absXPosition state.motor.absYPosition state.motor.absZPosition]=deal(current(1),current(2),current(3));
    if (any(currentPos~=[state.motor.absXPosition state.motor.absYPosition state.motor.absZPosition]))
        state.motor.relXPosition = state.motor.absXPosition - state.motor.offsetX; % Calculate absoluteX Position
        state.motor.relYPosition = state.motor.absYPosition - state.motor.offsetY; % Calculate absoluteX Position
        state.motor.relZPosition = state.motor.absZPosition - state.motor.offsetZ; % Calculate absoluteX Position
        updateGUIByGlobal('state.motor.relXPosition');
        updateGUIByGlobal('state.motor.relYPosition');
        updateGUIByGlobal('state.motor.relZPosition');
%         motorGUI('relPos_Callback',gh.motorGUI.zPos);
    end
end
updateCurrentROI;
state.acq.mirrorDataOutput = rotateAndShiftMirrorData(1/state.acq.zoomFactor*state.acq.mirrorDataOutputOrg);
flushAOData;
