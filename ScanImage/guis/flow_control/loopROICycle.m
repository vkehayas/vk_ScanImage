function loopROICycle
global state gh
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%TPMOD 7/8/03 for roi cycles....
% Get current cycle parameters....
% TPMODBox
currentAcq=state.roiCycle.currentROICycle(state.roiCycle.currentPos,:);
if state.roiCycle.repeatNumber == currentAcq(1) %Done repeats...move along to next 
    if state.roiCycle.currentPos == size(state.roiCycle.currentROICycle,1)  % Last position so clean up....
        if state.roiCycle.loopROICycle
            state.roiCycle.firstTimeThroughLoop=1;
            roiCycleGUI('resetROICycle_Callback',gh.roiCycleGUI.resetROICycle);
            state.roiCycle.repeatNumber=0;
            updateGUIByGlobal('state.roiCycle.repeatNumber');
            executeROICycle(state.roiCycle.currentROICycle(state.roiCycle.currentPos,:),1);
        else
            abortROICycle;
        end
    else
        state.roiCycle.currentPos=state.roiCycle.currentPos+1;
        state.roiCycle.roiCyclePosition=state.roiCycle.currentPos;
        state.roiCycle.repeatNumber=0;
        updateGUIByGlobal('state.roiCycle.currentPos');
        updateGUIByGlobal('state.roiCycle.repeatNumber');
        updateGUIByGlobal('state.roiCycle.roiCyclePosition');
        roiCycleGUI('roiCyclePosition_Callback',gh.roiCycleGUI.roiCyclePosition);
        executeROICycle(state.roiCycle.currentROICycle(state.roiCycle.currentPos,:),1);
    end
else
    executeROICycle(state.roiCycle.currentROICycle(state.roiCycle.currentPos,:),0);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%