function stopFocus
%% function stopFocus
%  Function that will stop the DAQ devices running for Focus (ao1F, ao2F, aiF).
%
%  Written by: Thomas Pologruto
%  Cold Spring Harbor Labs
%  February 7, 2001
%% 
%  Copyright - Howard Hughes Medical Institute/Cold Spring Harbor Laboratories 2002
%% MODIFICATIONS
%   11/24/03 Tim O'Connor - Start using the daqmanager object
%   1/8/04 Tim O'Connor (TO1804a) - Set 'RepeatOutput' back to one, since startFocus set it to 195...
%   2/16/04 Tim O'Connor (TO21604b) - Set power back to user specified level after acquisition.
%   7/21/04 Tim O'Connor (TO072104c) - RepeatOutput should be 0 by default.
%   3/11/08 Vijay Iyer (VI031108A) - Handle trigger timer, if present
%   3/18/08 Vijay Iyer (VI031808A) - Update GUI based on state changes that can occur during focus
%   10/20/08 Vijay Iyer (VI102008A) - Reset all focused laser beams, not just the (defunct) 'scanLaserBeam'
%   10/20/08 Vijay Iyer (VI102008B) - Correctly check whether any of the data streams are running
%
%% ************************************************************************

global gh state

% Handle trigger timer cleanup(VI031108A)
if ~isempty(state.internal.triggerTimer) 
    if strcmp(get(state.internal.triggerTimer,'Running'),'on')
        stop(state.internal.triggerTimer);
    end
    delete(state.internal.triggerTimer);
    state.internal.triggerTimer = [];
end   

%Update GUI based on any state changes that occurred during focus (VI031808A)
updateGUIByGlobal('state.acq.cuspDelay');
checkConfigSettings;

if state.init.eom.pockelsOn == 1
	stop([state.init.aiF state.init.ao2F ]);
%       stopChannel(state.acq.dm, state.init.eom.scanLaserName);
    %Changed under protest, to enable all beams during focus. Tim O'Connor 3/31/04 - TO033104a
    stopChannel(state.acq.dm, state.init.eom.pockelsCellNames);
    onList = state.init.eom.pockelsCellNames; %VI102008B
    [onList{:}] = deal('On'); %VI102008B
	while any(strcmpi({state.init.aiF.Running, state.init.ao2F.Running state.init.eom.pockelsCellNames{:}}, {'On' 'On' onList{:}})) %VI102008B: Corrected to use cell arrays
        pause(.1); %VI102008A
	end
    
    %After focusing, set the power to whatever is selected by the user. - TO21604b
    for i = 1 : state.init.eom.numberOfBeams
        putDaqSample(state.acq.dm, state.init.eom.pockelsCellNames{i}, state.init.eom.lut(i, state.init.eom.maxPower(i)));
    end
        
    %%%VI102008A%%%%%%%%%%%%%%%%%
    %setAOProperty(state.acq.dm, state.init.eom.scanLaserName, 'RepeatOutput', 0); %TO1804a, %TO072104c: This should get set to 0 not 1.
    list = delimitedList(state.init.eom.focusLaserList, ',');
    for i=1:length(list)
        setAOProperty(state.acq.dm, list{i}, 'RepeatOutput', 0);
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

else
	stop([state.init.aiF state.init.ao2F ]);
	while any(strcmpi({state.init.aiF.Running  state.init.ao2F.Running}, {'On' 'On'}))  %VI102008B: Corrected to use cell arrays
        pause(.1); %VI102008B
	end	
end