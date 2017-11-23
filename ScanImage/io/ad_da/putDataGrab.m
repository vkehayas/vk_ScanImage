function putDataGrab
global state
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%%  Function that places the sawtooth and pockels cell data to the DAQ
%%  Engine.
%%
%%  Created - August 11, 2003
%%
%%  Changed:
%%      Modified 11/24/03 - Tim O'Connor: Work with multiple Pockels cells, using the daqmanager object.
%%
%%      TPMOD_1: 1/8/04 Tom Pologruto: Remove repmat from from wrappign
%%      around the makePockelsCellDataOutput call.
%%
%%  Copyright - Howard Hughes Medical Institute/Cold Spring Harbor Laboratories 2003
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

putdata(state.init.ao2, state.acq.mirrorDataOutput);			% Queues Data to engine for Board 2 (Mirrors)
% Supply the pockels cells with the correct data....
if state.init.eom.pockelsOn == 1
    for beamCounter = 1 : state.init.eom.numberOfBeams
        if state.init.eom.changed(beamCounter)
            % start TPMOD_1 1/8/04
            putDaqData(state.acq.dm, state.init.eom.pockelsCellNames{beamCounter}, ...
                makePockelsCellDataOutput(beamCounter));
            % end TPMOD_1 1/8/04
        end
    end
end