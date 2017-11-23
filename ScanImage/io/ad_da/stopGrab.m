function stopGrab
%% function stopGrab
% Function that will stop the DAQ devices running for Grab (ao1, ao2, ai).
%
% Written by: Thomas Pologruto
% Cold Spring Harbor Labs
% February 7, 2001
% 
%% MODIFICATIONS
%   11/24/03 Tim O'Connor - Use the daqmanager object.
%   2/16/04 Tim O'Connor (TO21604c) - Set power back to user specified level after acquisition.
%   3/11/08 Vijay Iyer (VI031108A) - Handle trigger timer cleanup, if needed
%   8/21/08 Vijay Iyer (VI082108A) - Close tifStream, if any
%   10/20/08 Vijay Iyer (VI102008A) - Correctly check if any of the DAQ data streams are still running
% 
%% **********************************************************

global gh state

% Handle trigger timer cleanup(VI031108A)
if ~isempty(state.internal.triggerTimer) 
    if strcmp(get(state.internal.triggerTimer,'Running'),'on')
        stop(state.internal.triggerTimer);
    end
    delete(state.internal.triggerTimer);
    state.internal.triggerTimer = [];
end   

if state.init.eom.pockelsOn == 1

    stopChannel(state.acq.dm, state.init.eom.pockelsCellNames);
	stop([state.init.ao2 state.init.ai]);
    
    %%%VI102008A%%%%%%%%%%%%%%%%%%
    % 	while ~strcmp([state.init.ai.Running getAOField(state.acq.dm, state.init.eom.scanLaserName, 'Running') ...
    %                 state.init.ao2.Running], ['Off' 'Off' 'Off'])
    %     end    
    list = delimitedList(state.init.eom.grabLaserList, ',');
    onList = list;
    [onList{:}] = deal('On');
    while any(strcmpi({state.init.ai.Running state.init.ao2.Running list{:}},{'On' 'On' onList{:}}))
        pause(.1); %allow for some responsiveness
    end    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %After focusing, set the power to whatever is selected by the user. - TO21604c
    for i = 1 : state.init.eom.numberOfBeams
        if ~isempty(state.init.eom.lut)
            putDaqSample(state.acq.dm, state.init.eom.pockelsCellNames{i}, state.init.eom.lut(i, state.init.eom.maxPower(i)));
        end
    end
else
	stop([state.init.ao2 state.init.ai]);
    
	while any(strcmpi({state.init.ai.Running  state.init.ao2.Running}, {'On' 'On'})) %VI102008A -- changed to cell arrays
        pause(.1); %VI102008A
	end	
end

%VI082108A: Handle tifStream closing, if needed
if state.internal.abortActionFunctions && state.acq.saveDuringAcquisition && ~isempty(state.files.tifStream)
    try        
        close(state.files.tifStream);
        state.files.tifStream = [];
    catch        
        delete(state.files.tifStream,'leaveFile');
        errordlg('Failed to close an open TIF stream. A file may be corrupted.');
        state.files.tifStream = [];
    end            
end

