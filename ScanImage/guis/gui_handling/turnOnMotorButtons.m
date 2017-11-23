%% function turnOnMotorButtons
%% CHANGES 
% VI100708A: Handle error condition case handling -- Vijay Iyer 10/07/08
% VI100808A: Handle button disabling programatically. Add Grab and stack start/stop buttons to list. -- Vijay Iyer 10/08/08
% VI103008A: Add all the motorGUI controls to the list -- Vijay Iyer 10/30/08
%% ************************************************
function turnOnMotorButtons
global state gh

if ~state.motor.errorCond   %VI100708A    
    kidControls = [findobj(gh.motorGUI.figure1,'Type','uicontrol');findobj(gh.motorGUI.figure1,'Type','frame');findobj(gh.motorGUI.figure1,'Type','uipanel')];
    set(kidControls,'Visible','on');
    set(gh.motorGUI.pbReset,'Visible','off');
    set(gh.motorGUI.stReset,'Visible','off');
   
    turnOnExecuteButtons; %VI100708A (Execute buttons are turned off during an error)
    
    %%%VI100808A, VI103008A
    buttons = {'xPos' 'yPos' 'zPos' 'setZeroZButton' 'setZeroXYButton' 'setZeroXYZButton' 'shiftXYZButton' 'shiftXYButton' ...
        'definePosition' 'gotoPosition' 'readPosition' 'GRAB' 'setStackStartButton' 'setStackStopButton'...
        'savePositionListButton' 'loadPositionListButton' 'positionNumber' 'positionSlider'};

    for i=1:length(buttons)
        set(gh.motorGUI.(buttons{i}),'Enable','on');
    end
    %%%%%%%%%%%%%%%
else
    
    fprintf(2,'WARNING (%s): Cannot restore motor control buttons while in MP285 error condition\n',mfilename);
end

