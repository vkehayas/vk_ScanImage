%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%%  Starts the DAQ objects for focusing.
%%
%%  Written by: Thomas Pologruto
%%  Cold Spring Harbor Labs
%%  February 7, 2000
%%
%%  MODIFICATIONS
%    11/24/03 Tim O'Connor - Use the daqmanager object.
%    1/7/04 Tim O'Connor (TO1704b) - Only generate the flyback blanking for the scan laser's Pockels cell.
%    3/31/04 Tim O'Connor (TO033104a): Enable all beams during focus.
%    4/22/04 Tim O'Connor (TO042204a): Store lists of which beams to enable at which times.
%    2/21/08 Vijay Iyer (VI022108A): Implement infinite focus possibility vi AO 'RepeatOutput' property
%    4/13/08 Vijay Iyer (VI041308A): Set the trigger source to internal before starting channels
%    4/18/08 Vijay Iyer (VI041808A): Use LUT value to determine minimum value
%    4/30/08 Vijay Iyer (VI043008A): Use automatic buffering config for Pockels channels during Focus mode 
%    5/15/08 Vijay Iyer (VI051508A): Move Pockels cell channel config into the Pockels-handling IF cause...otherwise get errors when no PC
%
%%  Copyright - Howard Hughes Medical Institute/Cold Spring Harbor Laboratories 2002
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
global gh state

% Function that will start the DAQ devices running for Focus (ao1F, ao2F, aiF).
%
% Written by: Thomas Pologruto
% Cold Spring Harbor Labs
% February 7, 2001
%
% Modified 11/24/03 Tim O'Connor - Use the daqmanager object.
%           9/20/04 Tim O'Connor - TO092004a - Look out for the total disabling of lasers for a given function.


if state.init.eom.pockelsOn == 1
%     putDaqData(state.acq.dm, state.init.eom.scanLaserName, ...
%         makePockelsCellDataOutput(state.init.eom.scanLaserBeam, 1));%TO1704b
    for i = 1 : state.init.eom.numberOfBeams
        putDaqData(state.acq.dm, state.init.eom.pockelsCellNames{i}, ...
            makePockelsCellDataOutput(i, 1));%TO1704b
        setAOProperty(state.acq.dm, state.init.eom.pockelsCellNames{i}, 'RepeatOutput', (state.internal.numberOfFocusFrames -1));
    end
    
    %setAOProperty(state.acq.dm, state.init.eom.scanLaserName, 'RepeatOutput', (state.internal.numberOfFocusFrames -1));%TO072204b
    
%     startChannel(state.acq.dm, state.init.eom.scanLaserName);
    %Changed under protest, to enable all beams during focus. Tim O'Connor 3/31/04 - TO033104a
%     startChannel(state.acq.dm, state.init.eom.pockelsCellNames);
    %Tim O'Connor 7/20/04 TO072004a: Set all unchecked beams to their minima.
    list = delimitedList(state.init.eom.focusLaserList, ',');
    offBeams = find(~ismember(state.init.eom.pockelsCellNames, list));
    
    %Tim O'Connor TO092004a - Look out for the total disabling of lasers for a given function. - 9/20/04
    if length(offBeams) == state.init.eom.numberOfBeams
        errordlg('A beam must be enabled in the LaserFunctionPanel for this feature to work properly.');
    end
    for i = 1 : length(offBeams)
        putDaqSample(state.acq.dm, state.init.eom.pockelsCellNames{i}, state.init.eom.lut(i,state.init.eom.min(i))); %VI041808A 
    end
    
    %Tim O'Connor 7/22/04 TO072204b: Make sure the RepeatOutput property is correct.
    for i = 1 : length(list)
        if state.acq.infiniteFocus %VI022108A
            setAOProperty(state.acq.dm,list{i},'RepeatOutput',inf);
        else
            setAOProperty(state.acq.dm, list{i}, 'RepeatOutput', state.internal.numberOfFocusFrames -1);
        end
        %setAOProperty(state.acq.dm,list{i},'BufferingConfig',[2^18 round(2*state.init.outputChanBufferTime*state.acq.outputRate/2^18)]); %VI043008A
        %setAOProperty(state.acq.dm,list{i},'BufferingMode','auto'); %VI043008A VI051508A
        setTriggerSource(list{i},true); %VI041308A
    end
    
    %Tim O'Connor 4/22/04 TO042204a: Store lists of which beams to enable at which times.
    startChannel(state.acq.dm, delimitedList(state.init.eom.focusLaserList, ','));
end

if state.acq.infiniteFocus %VI022108A
    set(state.init.ao2F,'RepeatOutput',inf);
else
    set(state.init.ao2F,'RepeatOutput', state.internal.numberOfFocusFrames -1);
end
setTriggerSource([state.init.ao2F state.init.aiF],true); %VI041308A

start([state.init.ao2F state.init.aiF]);