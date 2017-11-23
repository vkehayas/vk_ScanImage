function updateCycleLengthSlider(handle)


global state gh;

updateGUIByGlobal('state.internal.position');
if state.internal.position>state.cycle.length
    state.internal.position=state.cycle.length;
    updateGUIByGlobal('state.cycle.position');
    loadCurrentCyclePosition;
end
if state.internal.positionToExecute>state.cycle.length
    state.internal.positionToExecute=1;
    updateGUIByGlobal('state.cycle.positionToExecute');
    changePositionToExecute;
end
if state.cycle.length<=1
    set(gh.cycleControls.cyclePositionSlider, 'Max', 2);
    set(gh.cycleControls.cyclePositionSlider, 'Visible', 'off');
    set(gh.mainControls.positionToExecuteSlider, 'Max', 2);
    set(gh.mainControls.positionToExecuteSlider, 'Visible', 'off');
else
    set(gh.cycleControls.cyclePositionSlider, 'Max', state.cycle.length);
    set(gh.cycleControls.cyclePositionSlider, 'SliderStep', [1/(state.cycle.length-1), 1/(state.cycle.length-1)]);
    set(gh.cycleControls.cyclePositionSlider, 'Visible', 'on');
    set(gh.mainControls.positionToExecuteSlider, 'Max', state.cycle.length);
    set(gh.mainControls.positionToExecuteSlider, 'SliderStep', [1/(state.cycle.length-1), 1/(state.cycle.length-1)]);
    set(gh.mainControls.positionToExecuteSlider, 'Visible', 'on');
end

if ~state.standardMode.standardModeOn %VI102909A: This kludge prevents cycleChanged flag from being on just during INI file loading
    state.internal.cycleChanged=1;
end
newCycleLength;
