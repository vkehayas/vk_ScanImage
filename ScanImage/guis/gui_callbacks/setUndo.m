function setUndo
global state

state.acq.lastROIForUndo=[state.acq.scaleXShift state.acq.scaleYShift state.acq.scanRotation ...
    state.acq.zoomFactor];