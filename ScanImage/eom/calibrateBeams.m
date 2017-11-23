%% function calibrateBeams(startup)
%  A 'macro' that calibrates the Pockels Cells for all the beams which require it
%
%% SYNTAX
%   calibrateBeams()
%   calibrateBeams(startup)
%       startup: Optional boolean flag indicating TRUE when called during startup (i.e. open USR file for first time), FALSE otherwise. FALSE is assumed.
%
%% CHANGES
%
%% CREDITS
%   Created 10/31/08 by Vijay Iyer
%% **************************************************************

function calibrateBeams(startup)
global state;

if ~nargin
    startup = false;
end

if state.init.eom.pockelsOn
    disp('*** Calibrating Pockels Cells ************');
    for i = 1:state.init.eom.numberOfBeams
        %Only do calibration if it's not been done already
        if isempty(state.init.eom.lut) || size(state.init.eom.lut,1) < i || all(state.init.eom.lut(i) == 0)
            if ~startup || state.internal.eom.calibrateOnStartup
                [eom_min, eom_max, avgDev] = calibrateEom(i); %will defer to non/naive dummy calibrations, as needed
                if avgDev %a non-elegant way to test that an actual calibration was done
                    fprintf(1,['Beam #' num2str(i) ' calibrated.\n']);
                end                    
            else
                dummyEomCalibrate(i,true); %Force non-calibration
            end
        end
    end
    disp('******************************************');
end

