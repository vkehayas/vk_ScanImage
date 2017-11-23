function pockelsOn = makePockelsCellDataOutput(beam, flybackOnly)
%% function pockelsOn = makePockelsCellDataOutput(beam, flybackOnly)
%  Function that constructs the Pockels Cell Data Output
%
%  This constructs a square wave in phase with the mirror ssawtoothX(Y) functions.
%  The square wave is set to the offset when the data is collected and is set to PockelsIntensity when
%  the data is not being collected (during flyback).
%
%%  Copyright - Howard Hughes Medical Institute/Cold Spring Harbor Laboratories 2000
%

%% MODIFICATIONS
%   TPMOD 2/6/02
%   TOMOD 6/23/03
%   Modified for new software by T. O'Connor 7/23/03
%   Modified to accept 'beam' as an argument. - T. O'Connor 11/24/03
%   Modified to allow generation of only 1 frame of flyback blanking, if requested. - T. O'Connor 12/23/03
%   VI030508A Vijay Iyer 3/5/08 -- Added handling for bidirectional scanning case
%   VI030508B Vijay Iyer 3/5/08 -- Handled case of high pockels cell fill fraction for bidirectional scans
%   VI030708A Vijay Iyer 3/7/08 -- Generate only 1 frame for cases where the output is strictly repetitive
%   VI041808A Vijay Iyer 4/18/08 -- Handle multi-beam case correctly with respect to testing for 'special' modes requiring monolithic (rather than repeated) Pockels cell buffer
%   VI041808B Vijay Iyer 4/18/08 -- Deal with either scalar or vector versions of state.init.eom.showBoxArray, which mysteriously goes back and forth
%
%% ************************************************************************
global state
% warning(state.init.eom.pockelsCellNames{beam});
if ~state.init.eom.pockelsOn
    error('Pockels cell disabled.');
end

if nargin < 2
    flybackOnly = 0;
end

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

state.init.eom.min = round(state.init.eom.min);

if state.init.eom.min(beam) > 100
    fprintf(2, 'WARNING: Minimum power for beam %s is over 100%%. Forcing it to 99%%...\n', num2str(beam));
    state.init.eom.min(beam) = 99;
elseif state.init.eom.min(beam) < 1
    fprintf(2, 'WARNING: Minimum power for beam %s is below 1%%. Forcing it to 1%%...\n', num2str(beam));
    state.init.eom.min(beam) = 1;
end

pockelsOn = state.init.eom.lut(beam, state.init.eom.min(beam)) * ones(state.internal.lengthOfXData, 1);

if ~state.acq.bidirectionalScan %VI030508A
    %Start from the phase shift value.
    startGoodPockelsData = floor(state.internal.lengthOfXData * .001 * state.acq.pockelsCellLineDelay / state.acq.msPerLine) + 1;

    %End at X% of the total waveform.
    endGoodPockelsData = startGoodPockelsData + ceil(state.internal.lengthOfXData * state.acq.pockelsCellFillFraction);
else %VI030508A
    startGoodPockelsData = floor(state.internal.lengthOfXData * state.acq.cuspDelay)+ floor(state.internal.lengthOfXData*(1-state.acq.pockelsCellFillFraction)/2)+1;
    endGoodPockelsData = startGoodPockelsData + ceil(state.internal.lengthOfXData*state.acq.pockelsCellFillFraction);
    if state.acq.pockelsCellFillFraction == 1 %VI030508B -- handle case of fill frac=1 specially
        startGoodPockelsData = 1;
        endGoodPockelsData = state.internal.lengthOfXData;
    elseif state.acq.pockelsCellFillFraction >= (1-state.acq.cuspDelay) %VI030508B -- handle case of very high fill fraction (including 1)
        overage = ceil((state.acq.pockelsCellFillFraction+state.acq.cuspDelay-1)*state.internal.lengthOfXData);
        startGoodPockelsData = max(startGoodPockelsData-ceil(overage/2),1);
        endGoodPockelsData = min(endGoodPockelsData+ceil(overage/2),state.internal.lengthOfXData);
    end               
end

%Watch out for rounding errors causing overruns.
if ~state.acq.bidirectionalScan %VI030508A
    if endGoodPockelsData > state.internal.lengthOfXData
        if startGoodPockelsData <= state.internal.lengthOfXData
            pockelsOn(startGoodPockelsData:state.internal.lengthOfXData) = state.init.eom.lut(beam, state.init.eom.maxPower(beam));
        end
    else
        pockelsOn(startGoodPockelsData:endGoodPockelsData) = state.init.eom.lut(beam, state.init.eom.maxPower(beam));
    end
else  %VI030508A
    if endGoodPockelsData > state.internal.lengthOfXData
        if startGoodPockelsData <= state.internal.lengthOfXData
            pockelsOn(startGoodPockelsData:state.internal.lengthOfXData) = state.init.eom.lut(beam,state.init.eom.maxPower(beam));
        end
    else
        pockelsOn(startGoodPockelsData:endGoodPockelsData) = state.init.eom.lut(beam, state.init.eom.maxPower(beam));
    end
end      

%Final Pockels Data for one frame
pockelsOn = repmat(pockelsOn, [state.acq.linesPerFrame 1]);

%Repeat the data, for multiple frames, if necessary.
%if ~flybackOnly & size(pockelsOn, 1) * state.acq.numberOfFrames == state.internal.lengthOfXData * state.acq.linesPerFrame * state.acq.numberOfFrames
%if ~flybackOnly && (state.init.eom.usePowerArray || state.init.eom.showBoxArray(beam) || any(state.init.eom.uncagingMapper.enabled)) %VI030708A
if ~flybackOnly && (state.init.eom.usePowerArray || any(state.init.eom.showBoxArray) || any(state.init.eom.uncagingMapper.enabled)) %VI030708A %VI041808A %VI041808B
    pockelsOn = repmat(pockelsOn, state.acq.numberOfFrames, 1);
end

%if ~flybackOnly %& (state.init.eom.usePowerArray | state.init.eom.showBoxArray(beam) | any(state.init.eom.uncagingMapper.enabled))
%if ~flybackOnly && (state.init.eom.usePowerArray || state.init.eom.showBoxArray(beam) || any(state.init.eom.uncagingMapper.enabled)) %VI030708A
if ~flybackOnly && (state.init.eom.usePowerArray || any(state.init.eom.showBoxArray) || any(state.init.eom.uncagingMapper.enabled)) %VI030708A %VI041808A %VI041808B
    pockelsOn = implementPockelsCellTiming(beam, pockelsOn);
end
