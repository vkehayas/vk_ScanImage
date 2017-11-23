%% function updateStackEndpoints
% Function that updates display of stack endpoints
%
%% CHANGES
%   VI111108A: Handle case where update is a clearing of stack start or stop; enable GRAB button only if stack start & stop are defined
%% CREDITS
%   Created 10/09/08 by Vijay Iyer
%% **************************

function updateStackEndpoints

global state gh

out=[];

if state.motor.motorOn
    if ~isempty(state.motor.stackStart)
        set(gh.motorGUI.etStackStart,'String', num2str(state.motor.stackStart(3) - state.motor.offsetZ));
    else
        set(gh.motorGUI.etStackStart,'String', ''); %VI111108A
    end
    
    if ~isempty(state.motor.stackStop)
        set(gh.motorGUI.etStackStop,'String', num2str(state.motor.stackStop(3) - state.motor.offsetZ));
    else
        set(gh.motorGUI.etStackStop,'String', ''); %VI111108A
    end
    
    %%%VI111108A%%%%
    if ~isempty(state.motor.stackStart) && ~isempty(state.motor.stackStop)
        set(gh.motorGUI.GRAB,'Enable','on');
    else
        set(gh.motorGUI.GRAB,'Enable','off');
    end
    %%%%%%%%%%%%%%%%%
        
end
    

