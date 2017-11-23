%% function resumeLoop
%
%% NOTES
%   This function is where X/Y/Z steps, if any, are applied at the end of an acquisition within a LOOP. 
%   Note that the X/Y/Z steps occur on every repeat (if more than 1) of the cycle position
%
%   The positionToExecute value in this function pertains to the just-executed position -- Vijay Iyer 10/27/09
%
%% CHANGES
%   VI101008A: Defer updateRelativeMotorPosition() to setMotorPosition() -- Vijay Iyer 10/10/08
%   VI102709A: state.internal.lastTimeDelay renamed to state.internal.lastRepeatPeriod -- Vijay Iyer 10/27/09
%   VI102709B: Eliminate state.internal.positionJustExectuted -- state.internal.positionToExecute refers everywhere in this fucntion to the position just executed -- Vijay Iyer 10/27/09
%
%% ************************************************************

function resumeLoop
	global state gh
    %TODO: Update time here?
	updateGUIByGlobal('state.internal.secondsCounter');
		
	%state.internal.positionJustExecuted=state.internal.positionToExecute; %VI102709A
	state.internal.repeatsDone=state.internal.repeatsDone+1;
	updateGUIByGlobal('state.internal.repeatsDone');
	set(gh.mainControls.focusButton, 'Visible', 'On');
		
	if state.standardMode.standardModeOn==0
		moveStageNeeded=0;
	
		if state.cycle.cycleDX(state.internal.positionToExecute)~=0
			moveStageNeeded=1;
			state.motor.absXPosition=state.motor.absXPosition+state.cycle.cycleDX(state.internal.positionToExecute); %VI102709B
		end
			 
		if state.cycle.cycleDY(state.internal.positionToExecute)~=0 %VI102709B
			moveStageNeeded=1;
			state.motor.absYPosition=state.motor.absYPosition+state.cycle.cycleDY(state.internal.positionToExecute); %VI102709B
		end
	
		if state.cycle.cycleDZ(state.internal.positionToExecute)~=0 %VI102709B
			state.motor.absZPosition=state.motor.absZPosition+state.cycle.cycleDZ(state.internal.positionToExecute); %VI102709B
		end

		if moveStageNeeded==1
			%setStatusString('Moving Stage...'); %Message is redundant
			setMotorPosition;
			%updateRelativeMotorPosition; %VI101008A
			setStatusString('');
		end
	else
	end
	state.internal.lastRepeatPeriod=state.cycle.cycleTimeDelay(state.internal.positionToExecute); %VI102709A %Stores /last/ posn's delay value, as implied
	mainLoop;
