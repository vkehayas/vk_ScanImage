function startSnapShot
%% function startSnapShot
% Function that will start the DAQ devices running for SnapShot (ao1, ao2, ai).
%
% Created Tim O'Connor 4/23/04
% Copyright Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2004
%% MODIFICATIONS
% VI041308A - Set the trigger source to internal before starting channels -- Vijay Iyer 4/13/2008
% VI041308B - Pull out the cell array creation from the snapLaserList var -- Vijay Iyer 4/13/2008
% VI041808A - Use LUT value to determine minimum value
%
%% *******************************************************

global state;

if state.init.eom.pockelsOn == 1
    offBeams = find(~ismember(state.init.eom.pockelsCellNames, delimitedList(state.init.eom.snapLaserList, ',')));
    %Tim O'Connor 7/20/04 TO072004a: Set all unchecked beams to their minima.
    for i = 1 : length(offBeams)
        putDaqSample(state.acq.dm, state.init.eom.pockelsCellNames{i}, state.init.eom.lut(i,state.init.eom.min(i))); %VI041808A
    end
    
    chans = delimitedList(state.init.eom.snapLaserList,',');
    for i=1:length(chans)
        setTriggerSource(chans{i},true); %VI041308A -- Force internal triggering
    end
    startChannel(state.acq.dm, chans);
end
setTriggerSource([state.init.ao2 state.init.ai],true); %VI041308A -- Force internal triggering
start([state.init.ao2 state.init.ai]);