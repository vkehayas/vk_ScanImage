function pockelsOut = getPockelsOutputObject(pockelsCellNumber)
global state;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%%  Find and return the correct analog output object,
%%  corresponding to the pockelsCellNumber.
%%
%%  pockelsCellNumber - This is the 'N' in the standard.ini
%%
%%  Created - Tim O'Connor 11/5/03
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

pockelsOut = getAO(state.acq.dm, state.init.eom.pockelsCellNames{pockelsCellNumber});