function pockelsOn = makePockelsCellDataOutput(beam)
global state

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% makePockelsCellDataOuput.m*****
% Function that constructs the Pockels Cell Data Output
%
% This constructs a square wave in phase with the mirror ssawtoothX(Y) functions.
% The square wave is set to the offset when the data is collected and is set to PockelsIntensity when
% the data is not being collected (during flyback).
%
% Written by: Thomas Pologruto
% Cold Spring Harbor Labs
% November 16, 2000
%
% TPMOD 2/6/02
% TOMOD 6/23/03
% Modified for new software by T. O'Connor 7/23/03
%
% Modified to accept 'beam' as an argument. - T. O'Connor 11/24/03

if isempty(state.init.eom.lut)
    return;
end

%Do some simple checking of the variables.
if state.acq.pockelsCellFillFraction > 1
    state.acq.pockelsCellFillFraction = 1;
elseif state.acq.pockelsCellFillFraction < 0
    state.acq.pockelsCellFillFraction = 0;
end

if state.acq.pockelsCellLineDelay > 1000 * state.acq.msPerLine
    %Allow it to rotate all the way around.
    state.acq.pockelsCellLineDelay = mod(.001 * state.acq.pockelsCellLineDelay, state.acq.msPerLine);
elseif state.acq.pockelsCellLineDelay < 0
    state.acq.pockelsCellLineDelay = 0;
end

pockelsOn = state.init.eom.lut(beam, state.init.eom.min(beam)) * ones(state.internal.lengthOfXData, 1);

%Start from the phase shift value.
startGoodPockelsData = floor(state.internal.lengthOfXData * .001 * state.acq.pockelsCellLineDelay / state.acq.msPerLine) + 1;
 
%End at X% of the total waveform.
endGoodPockelsData = startGoodPockelsData + ceil(state.internal.lengthOfXData * state.acq.pockelsCellFillFraction);

%Watch out for rounding errors causing overruns.
if endGoodPockelsData > state.internal.lengthOfXData
    if startGoodPockelsData <= state.internal.lengthOfXData
        pockelsOn(startGoodPockelsData:state.internal.lengthOfXData) = state.init.eom.lut(beam, state.init.eom.maxPower(beam));
    end
else
    pockelsOn(startGoodPockelsData:endGoodPockelsData) = state.init.eom.lut(beam, state.init.eom.maxPower(beam));    
end    

%Final Pockels Data for one frame
pockelsOn = repmat(pockelsOn, [state.acq.linesPerFrame 1]);