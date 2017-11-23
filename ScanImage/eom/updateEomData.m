% Modified 11/24/03 Tim O'Connor - Use the daqmanager object.
function updateEomData(beam)
global state;

eval(sprintf('changed = state.init.eom.changed(%s);', num2str(beam)));

if changed
    putDaqData(state.acq.dm, state.init.eom.pockelsCellNames{beam}, makePockelsCellDataOutput(beam));
end