function putData
global state

% putData.m*****
% Function that places the sawtooth and pockels cell data to the DAQ Engine.
%
% Written by Thomas Pologruto  
% Cold Spring Harbor Labs
% January 25, 2001

putdata(state.init.ao2, state.acq.mirrorDataOutput);			% Queues Data to engine for Board 2 (Mirrors)
if state.init.eom.pockelsOn == 1
%     putDaqData(state.acq.dm, state.init.eom.scanLaserName, state.acq.pockellDataOutput);
    for i = 1 : state.init.eom.numberOfBeams
        %Changed (under protest) to make focus activate all lasers. -- Tim O'Connor 3/31/04: TO0333104a
        putDaqData(state.acq.dm, state.init.eom.pockelsCellNames{i}, ...
                            makePockelsCellDataOutput(i));
    end
% 	putdata(state.init.ao1, state.acq.pockellDataOutput);		% Queues Data to engine for board 1 (Pockell Cell)
end
dbstack