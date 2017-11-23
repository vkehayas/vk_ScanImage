%% function turnOffMotorButtons
%   Turns off motor control buttons, e.g during an action or following an error
%% CHANGES 
% VI100708A: Handle error condition use case -- Vijay Iyer 10/07/08
% VI100808A: Handle button disabling programatically. Add Grab and stack start/stop buttons to list. -- Vijay Iyer 10/08/08
% VI103008A: Add all the motorGUI controls to the list -- Vijay Iyer 10/30/08
%% ************************************************

function turnOffMotorButtons
global state gh

%%%VI100808A, VI103008A
buttons = {'xPos' 'yPos' 'zPos' 'setZeroZButton' 'setZeroXYButton' 'setZeroXYZButton' 'shiftXYZButton' 'shiftXYButton' ...
    'definePosition' 'gotoPosition' 'readPosition' 'GRAB' 'setStackStartButton' 'setStackStopButton'...
    'savePositionListButton' 'loadPositionListButton' 'positionNumber' 'positionSlider'};

for i=1:length(buttons)
    set(gh.motorGUI.(buttons{i}),'Enable','off');
end
%%%%%%%%%%%%%%%

if state.motor.errorCond %VI100708A      
    kidControls = [findobj(gh.motorGUI.figure1,'Type','uicontrol');findobj(gh.motorGUI.figure1,'Type','frame');findobj(gh.motorGUI.figure1,'Type','uipanel')];
    set(kidControls,'Visible','off'); 
    set(gh.motorGUI.pbReset,'Visible','on');
    set(gh.motorGUI.stReset,'Visible','on');     
    
   	turnOffExecuteButtons;  %VI100908A
end


