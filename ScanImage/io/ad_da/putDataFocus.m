function putDataFocus(data)
global state

% putData.m*****
% Function that places the sawtooth and pockels cell data to the DAQ Engine.
%
% Written by Thomas Pologruto  
% Cold Spring Harbor Labs
% January 22, 2001
%
% Modified 11/24/03 Tim O'Connor - Use the daqmanager object.

putdata(state.init.ao2F, state.acq.mirrorDataOutput);			% Queues Data to engine for Board 2 (Mirrors)
%TPMODPockels
if state.init.eom.pockelsOn == 1
%      if state.init.eom.changed(state.init.eom.scanLaserBeam)
%         state.acq.pockelsDataOutput = makePockelsCellDataOutput(state.init.eom.scanLaserBeam);
%         state.init.eom.changed(state.init.eom.scanLaserBeam) = 0;
%     end
    
    for i = 1 : state.init.eom.numberOfBeams    
%         putDaqData(state.acq.dm, state.init.eom.pockelsCellNames{state.init.eom.scanLaserBeam}, state.acq.pockelsDataOutput);
        %Changed (under protest) to make focus activate all lasers. -- Tim O'Connor 3/31/04: TO0333104a
        putDaqData(state.acq.dm, state.init.eom.pockelsCellNames{i}, ...
                            makePockelsCellDataOutput(i,1));
    end
end