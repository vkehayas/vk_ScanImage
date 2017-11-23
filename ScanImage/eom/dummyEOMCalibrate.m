function  out = dummyEOMCalibrate(beamNum,forceNonCalibrate)
%% function  out = dummyEOMCalibrate(beamNum)
%DUMMYEOMCALIBRATE Handles special cases where Pockels Cell calibration is either a) not needed, or b) not possible because of absence of a photodiode
%
%% SYNTAX
%   out = dummyEOMCalibrate(beamNum)
%       beamNum: Integer value specifying number of beam to calibrate
%       forceNonCalibrate: Optional logical flag, TRUE if non-calibration should be forced. FALSE is assumed. 
%       out: Logical value, 1 if a dummy calibration was done, 0 if not
%% NOTES
%   Calling functions should use 'out' value to determine whether or not a true calibration should proceed
%
%   Could consider implementing a default sin^2 function for the naive calibration, which would be more likely to match. (Pitfall is that
%       the half-wave voltage is not knowable a priori)
%
%% MODIFICATIONS
%   VI041808A Vijay Iyer 4/18/08 -- Get beam-specific pockels voltage range
%   VI070808A Vijay Iyer 7/08/08 -- Fill in other beam-specific variables determined during calibration process
%   VI103108A Vijay Iyer 10/31/08 -- Handle special case where calibration is not required (incl. case where beam is not used). Also, add argument to allow such non-calibration to be forced.
%   VI032609A Vijay Iyer 3/26/09 -- Parse Pockels lists correctly as comma-delimited lists
%
%% **************************************************
global state

out = 0;

if nargin < 2
    forceNonCalibrate = false;
end

if forceNonCalibrate || ...
    (~ismember(['PockelsCell-' num2str(beamNum)],delimitedList(state.init.eom.focusLaserList,',')) && ... %VI032609A
        ~ismember(['PockelsCell-' num2str(beamNum)],delimitedList(state.init.eom.grabLaserList,',')) && ...
        ~ismember(['PockelsCell-' num2str(beamNum)],delimitedList(state.init.eom.snapLaserList,',')))
    out = 1;

    fprintf(1,['NOTE: Calibration for beam #' num2str(beamNum) ' not required at this time and, thus, skipped.\n']);
    state.init.eom.lut(beamNum,:) = zeros(1,100);
    state.init.eom.min(beamNum) = 1; %1 is as low as we can go
    state.init.eom.maxPhotodiodeVoltage(beamNum) = 0;
    
elseif isempty(state.init.eom.(['photodiodeInputBoardId' num2str(beamNum)]))
    out = 1;
    state.init.eom.lut(beamNum,:) = linspace(0,getfield(state.init.eom,['pockelsVoltageRange' num2str(beamNum)]),100);  %VI041808A
    %%%%% (VI070808A)
    state.init.eom.min(beamNum) = 1;
    calibFactor = state.init.eom.(['powerConversion' num2str(beamNum)]);
    state.init.eom.maxPhotodiodeVoltage(beamNum) = 100/calibFactor; %Max photodiode voltage forced to correspond to 100mW of light power, so mW is effectively a percentage as well
    %%%%%%%%%%%%%%%%
    fprintf(1,['WARNING: Pockels Cell #' num2str(beamNum) ' has no photodiode and is thus uncalibrated. A naive linear scale is employed instead.' sprintf('\n')]);
end

