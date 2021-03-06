%% function [eom_max, eom_min, avg_dev] = calibrateEom(varargin);
%  Construct an array of output voltages
%  that correspond to attenuations in laser intensity
%  via a Pockels cell.
%
%% SYNTAX
%  The return values are:
%    eom_max - the maximum voltage input measured.
%    eom_min - the minimum voltage input measured.
%    avg_dev - the average standard deviation over all measurements.
%
%% NOTES
%  The array is stored in state.eom.lut, the index into the
%  array reflects the percentage of the maximum possible intensity.
%  The resolution is 1%.
%
%  A simple call to 'downsample' wasn't made, because the entire sampling
%  domain may not be needed. Only the linear region is interesting, and
%  the highest resolution in that region is desired.
%
%%  MODIFICATIONS
%            6/17/03 Experimented with adding some filtering. - Tim O'Connor
%            11/24/03 Use daqmanager object. - Tim O'Connor
%            1/6/04 Extra error checking/handling - Tim O'Connor :: TO1604
%            1/24/04 Make sure the min is cardinal. - Tim O'Connor :: TO12204a
%            1/26/04 Add a cancel button to the waitbar. - Tim O'Connor :: TO12404a
%            2/26/04 Flag completed calibration. - Tim O'Connor :: TO22604e
%            7/22/04 RepeatOutput should be 0. - Tim O'Connor :: TO072204a
%            2/07/08 Defer to setAITriggerType utility func, which is NI driver-type agnostic - Vijay Iyer :: VI020708A
%            2/16/08 Support DAQmx feature of allowing trigger input terminal to be set via standard.ini setting - Vijay Iyer :: VI021608A
%            2/18/08 Add 'ClockSource' to the list of AO properties temporarily modified by the calibration (and restored upon completion)- Vijay Iyer :: VI021808A
%            2/18/08 Get maximum voltage level for Pockels Cell control from setting in standard.ini (state.init.eom.pockelsVoltageRange) - Vijay Iyer :: VI021808B
%            4/10/08 Handle flat photodiode data case by routing to naive calibration - Vijay Iyer :: VI041008A
%            4/10/08 Handle calibration 'marking' in a general way for measured and 'naive' calibrations - Vijay Iyer :: VI041008B
%            4/16/08 Actually set maximum voltage level to that set in standard.ini file - Vijay Iyer :: VI041608A
%            4/18/08 Allow separate maximum voltage level to be set for each Pockels Cell in standard.ini file - Vijay Iyer :: VI041808A
%            4/19/08 Ensure that cached Pockels Cell AO settings are restored regardless of outcome :: VI041908A
%            5/05/08 Actually affet the global state variable in the markCalibration function :: VI050508A
%            5/21/08 Add buffering config to the list of AO properties temporarily modified by the calibration :: VI052108A
%            5/21/08 Remove apparently redundant block of code :: VI052108B
%            8/05/08 Slow down the hard-coded loop in order to speed up the Pockels cell calibration :: VI080508A
%            8/12/08 Don't need to cache/restore BufferingConfig anymore, as it's no longer ever changed :: VI081208A
%            8/16/08 Handle case where one of the Pockels Cells is truly calibrated, and the other is 'naively' calibrated ::  VI101608A
%            10/31/08 Handle case where beam is not in use - Vijay Iyer :: VI103108A
%            10/31/08 state.init.eom.ai is now a cell array - Vijay Iyer :: VI103108B
%            11/02/08 Corrected error message for case where LUT values exceed max pockels cell voltage :: VI110208A
%            11/02/08 Return min/max/dev values in dummy case :: VI110208B
%            11/07/08 Cache Pockels calibration figure handles, so they can be deleted programmatically if needed :: VI110708A
%            
%%
%  Created - Tim O'Connor 5/13/03
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 
function [eom_max, eom_min, avg_dev] = calibrateEom(varargin)
global state;

if length(varargin) > 1
    for i = 1:length(varargin)
        calibrateEom(varargin{i});
        
        %TO12404a - Don't calibrate others when calibration is cancelled.
        if state.init.eom.cancel
            return;
        end
    end
    return;
elseif length(varargin) < 1
    
    for i = 1:state.init.eom.numberOfBeams
        calibrateEom(i);
        
        %TO12404a - Don't calibrate others when calibration is cancelled.
        if state.init.eom.cancel
            return;
        end
    end
    return;
else
    beam = varargin{1};
end

%Get pockels voltage range for this beam (VI041808A)
pockelsVoltageRange =getfield(state.init.eom, ['pockelsVoltageRange' num2str(beam)]); %VI101608A: Do this always, rather than only if there's a photodiode board specified

%VI103108A: Handle cases where naive/non calibration is required
if dummyEOMCalibrate(beam)
    markCalibration(beam); %mark it as calibrated, though it's not really
    
    %%%VI1110208B
    eom_min = state.init.eom.min(beam);
    eom_max = state.init.eom.maxPhotodiodeVoltage(beam);
    avg_dev = 0;
    %%%%%%%%    
else %Proceed with actual calibration
  
% %Calibrate Pockels Cell for beam /only if/ there is a photodiode board specified for this beam %VI021808B
% elseif ~isempty(getfield(state.init.eom,['photodiodeInputBoardId' num2str(beam)])) 
    %TO12404a - Added the 'cancel' flag and a callback for the waitbar.
    wb = waitbar(0, sprintf('Calibrating Pockels Cell #%s...', num2str(beam)), 'Name', 'Calibrating...', ...
        'createCancelBtn', 'global state; state.init.eom.cancel = 1; delete(gcf);');
    state.init.eom.cancel = 0;
    
    %Speed things up a bit... I hope.
    modulation_voltage = (0:state.internal.eom.calibration_interval:pockelsVoltageRange)'; %VI041608A  %VI041808A
    % modulation_voltage = sin(0 : 2*pi/3000 : 2*pi/3)'; modulation_voltage(1:31) = modulation_voltage(31);%FAKE DATA INSERTION, for testing purposes only!
    photodiode_voltage = zeros(length(modulation_voltage), 1);
    state.init.eom.lut(beam, :) = zeros(100, 1);

    ao_s_rate = getAOProperty(state.acq.dm, state.init.eom.pockelsCellNames{beam}, 'SampleRate');
    ao_repeat_output = getAOProperty(state.acq.dm, state.init.eom.pockelsCellNames{beam}, 'RepeatOutput');
    ao_clock_source = getAOProperty(state.acq.dm, state.init.eom.pockelsCellNames{beam}, 'ClockSource'); %VI021808A
    ao_trig_source = getAOProperty(state.acq.dm,state.init.eom.pockelsCellNames{beam},'HwDigitalTriggerSource'); %VI041708A
    %ao_buffering_config = getAOProperty(state.acq.dm,state.init.eom.pockelsCellNames{beam},'BufferingConfig'); %VI052108A, VI081208A
    ao_buffering_mode = getAOProperty(state.acq.dm,state.init.eom.pockelsCellNames{beam},'BufferingMode'); %VI052108A

    eval(sprintf('ai = state.init.eom.ai{%s};', num2str(beam))); %VI103108B

    set(ai, 'SampleRate', state.internal.eom.calibrationSampleRate);%20kHz sounds good... it's rather arbitrary.
    set(ai, 'SamplesPerTrigger', length(modulation_voltage));
    %set(ai, 'TriggerType', 'HwDigital');%This is the important one.
    setAITriggerType(ai,'HWDigital'); %VI020708A
    if strcmpi(whichNIDriver,'DAQmx') %VI021608A
        set(ai,'HWDigitalTriggerSource',state.init.triggerInputTerminal);
    end

    setAOProperty(state.acq.dm, state.init.eom.pockelsCellNames{beam}, 'SampleRate', state.internal.eom.calibrationSampleRate);
    %TO072204a
    setAOProperty(state.acq.dm, state.init.eom.pockelsCellNames{beam}, 'RepeatOutput', 0);
    setAOProperty(state.acq.dm, state.init.eom.pockelsCellNames{beam}, 'ClockSource', 'Internal'); %VI021808A
    setAOProperty(state.acq.dm, state.init.eom.pockelsCellNames{beam}, 'HwDigitalTriggerSource', state.init.triggerInputTerminal); %VI041708A
    %setAOProperty(state.acq.dm, state.init.eom.pockelsCellNames{beam}, 'BufferingMode', 'auto'); %VI052108A, VI081208A

    putDaqSample(state.acq.dm, state.init.eom.pockelsCellNames{beam}, 0);

    data = zeros(state.internal.eom.calibrationPasses,length(modulation_voltage),1);
    for i=1:state.internal.eom.calibrationPasses
        %TO12404a - It should be safe to just return from here. Check at the end of the loop too.
        if state.init.eom.cancel
            restoreAOSettings(beam,ao_s_rate,ao_repeat_output,ao_clock_source,ao_trig_source,ao_buffering_config,ao_buffering_mode); %VI041908A %VI052108A
            return;
        end

        %Start the acquisition.
        start(ai);

        %Buffer the modulation signal.
        putDaqData(state.acq.dm, state.init.eom.pockelsCellNames{beam}, modulation_voltage);

        %Output the modulation signal.
        startChannel(state.acq.dm, state.init.eom.pockelsCellNames{beam});

        %Trigger the I/O.
        dioTrigger;

        k = 0;
        while strcmpi(getAOField(state.acq.dm, state.init.eom.pockelsCellNames{beam}, 'Running'), 'On')
            k = k + 1;
            if k > 10000
                fprintf(2, 'Warning: Calibrate forced a break, while waiting for data output to finish.\n%s', ...
                    '         The calibration should still be valid.\n');
                fprintf(1, 'Resuming...\n');
                break;
            end
            pause(0.1); %VI080508A
        end

        %This will automatically wait until all data in the buffer is flushed through the board.
        stopChannel(state.acq.dm, state.init.eom.pockelsCellNames{beam});

        data(i, :, :) = getdata(ai);

        %Stop the acquistion.
        stop(ai);

        waitbar(i / state.internal.eom.calibrationPasses, wb);
    end

    %TO12404a - It should be safe to just return from here...
    if state.init.eom.cancel
        restoreAOSettings(beam,ao_s_rate,ao_repeat_output,ao_clock_source,ao_trig_source,ao_buffering_config,ao_buffering_mode); %VI041908A VI052108A
    end

    photodiode_voltage = mean(data, 1);
    photodiode_voltage_stdDev = std(data, 1);
    % figure;plot(modulation_voltage, photodiode_voltage);title('Photodiode Voltage vs. Modulation Voltage');xlabel('Modulation Voltage [V]');ylabel('PhotodiodeVoltage [V]');
    %Test/debugging purposes.
    % figure;plot(modulation_voltage, photodiode_voltage);title('Photodiode Voltage vs. Modulation Voltage');xlabel('Modulation Voltage [V]');ylabel('PhotodiodeVoltage [V]');

    %Subtract off any offset in the detector electronics.
    photodiode_voltage = photodiode_voltage - getfield(state.init.eom, ['photodiodeOffset' num2str(beam)]);

    %Throw away the first few, as there seems to be error at very low voltages (disregard anything below state.internal.eom.low_lim% of max).
    %Still take the data anyway, just for consistency (array sizes, etc).
    for i = 1 : round(100 * state.internal.eom.low_lim / length(photodiode_voltage))
        photodiode_voltage(i) = photodiode_voltage(round(100 * state.internal.eom.low_lim / length(photodiode_voltage)));
    end

    %Gather up the return variables.
    [eom_min min_p] = min(photodiode_voltage);
    eom_max = max(photodiode_voltage);
    avg_dev = mean(photodiode_voltage_stdDev ./ eom_max);
    state.init.eom.maxPhotodiodeVoltage(beam) = eom_max;

    if (avg_dev > .35) | ((eom_min / eom_max) > .15)%Bad data? -- Too noisy or not enough attenuation.
        fprintf(2, '\nWARNING: Pockels cell calibration data seems bad.\n');
        beep;
        if (eom_min / eom_max) > .15
            fprintf(2, '  Pockels cell minimum power not less than 15%% of maximum power. Min: %s%%\n', num2str( 100 * eom_min / eom_max));
        else
            fprintf(2, '  Pockels cell calibration seems excessively noisy.\n  Typical standard deviation per sample: %s%%\n', num2str(100 * avg_dev));
        end

        f = figure('NumberTitle', 'off', 'DoubleBuffer', 'On','Name', 'Pockels Cell Calibration Curve', 'Color', 'White');
        a = axes('Parent', f, 'FontSize', 12, 'FontWeight', 'Bold');
        plot(modulation_voltage, photodiode_voltage, 'Parent', a, 'Color', [0 0 0], 'LineWidth', 2);
        %TO1604 - Added the beam number to the plot.
        t = sprintf('Pockels Cell Calibration Curve (beam: %s)', num2str(beam));
        title(t, 'Parent', a, 'FontWeight', 'bold');
        xlabel('Modulation Voltage (From DAQ Board) [V]', 'Parent', a, 'FontWeight', 'bold');
        ylabel('Photodiode Voltage [V]','Parent', a, 'FontWeight', 'bold');
        state.internal.figHandles = [f state.internal.figHandles]; %VI110708A
    end

    % Normalize.
    photodiode_voltage = photodiode_voltage / eom_max;

    %Take measurement from rejected light, if necessary.
    %Note: The return values are still in absolute form.
    eval(sprintf('rejected = state.init.eom.rejected_light%s;', num2str(beam)));
    if rejected
        photodiode_voltage = 1 - photodiode_voltage;
    end

    %Round off to the nearest %.
    photodiode_voltage = round(100 * photodiode_voltage);
    photodiode_voltage(photodiode_voltage < 0) = 0;

    %%%%%%COMMENTED OUT (VI052108B)%%%%%%%%%%%%%%%%%%
%     state.init.eom.min(beam) = ceil(100 * (eom_min / eom_max));
%     if state.init.eom.min(beam) > 100
%         fprintf(2, 'WARNING: Minimum power for beam %s is over 100%% (%s). Forcing it to 99%%...\n', num2str(beam), num2str(state.init.eom.min(beam)));
%         state.init.eom.min(beam) = 99;
%     elseif state.init.eom.min(beam) < 0
%         fprintf(2, 'WARNING: Minimum power for beam %s is below 0%% (%s). Forcing it to 1%%...\n', num2str(beam), num2str(state.init.eom.min(beam)));
%         state.init.eom.min(beam) = 1;
%     end
%     if state.init.eom.min(beam) < 1
%         state.init.eom.min(beam) = 1;
%     end
    %%%%%%END COMMENT%%%%%%%%%%%%%%%%%%

    %Start from the 'effective 0', and work up to 100%.
    p = ceil(100 * eom_min / eom_max);

    if isnan(p) %dud data (VI041008A)
        fprintf(2,'WARNING: Photodiode data is flat--possibly disconnected. Using naive linear calibration instead\n');
        naiveEOMCalibrate(beam);
        p=1;
    else
        if p < 1
            p = 1;%This must never be less than 2.
        elseif p > 100
            %TO1604 - This seemed to happen when the laser was acting funny (not
            %mode-locked?). Anyway, 'p' getting over 100 results in the lookup
            %table being borked.
            p = 100;
            fprintf(2, 'WARNING: Pockels cell calibration appears saturated or noisy, laser may be out of mode-lock.');
        end
        state.init.eom.lut(beam, 1:p) = modulation_voltage(min_p);
    end
    %TO1604 - Look into this some more...
    state.init.eom.min(beam) = p;

    %Set the real values.
    for i = p + 1:100 %why not from p:100? (VI052108) 

        pos = find(photodiode_voltage == i); %Locate a modulation voltage that gives the desired transmittance.
        if length(pos) > 0
            %Take the one closest to the last voltage.
            if i == 1
                state.init.eom.lut(beam, i) = pos(1);
            else
                pos_diff = abs(modulation_voltage(pos) - state.init.eom.lut(beam, i - 1));
                [val loc] = min(pos_diff);
                state.init.eom.lut(beam, i) = modulation_voltage(pos(loc));
            end
        else %if length(pos) > 0
            if i == 100 %Just keep the last one.
                state.init.eom.lut(beam, i) = state.init.eom.lut(beam, i - 1);
            elseif i == state.init.eom.min(beam)
                state.init.eom.lut(beam, i) = state.init.eom.min(beam);
            elseif i > state.init.eom.min(beam)
                %Assume local linearity.
            else
                %This can result in something very ugly...  but, it's still a reasonable method.
                if i > 2
                    step = state.init.eom.lut(beam, i - 1) - state.init.eom.lut(beam, i - 2);
                    if abs(step) < .2
                        state.init.eom.lut(beam, i) = state.init.eom.lut(beam, i - 1) + step;%Project outwards.
                    else
                        state.init.eom.lut(beam, i) = state.init.eom.lut(beam, i - 1);%Give up, and just use the last value.
                    end
                else %if i > 2
                    state.init.eom.lut(beam, i) = state.init.eom.lut(beam, i - 1);
                end %if i > 2
            end %if i == 100
        end %if length(pos) > 0
    end  %for i = p + 1:100

    restoreAOSettings(beam,ao_s_rate,ao_repeat_output,ao_clock_source,ao_trig_source); %VI041908A  VI052108A   VI081208A
    
    if state.init.eom.started
        flushAOData;
    end

    close(wb);

    %Only print a warning if the values are more than 5 millivolts outside of tolerances.

    over = find(state.init.eom.lut > pockelsVoltageRange); %VI021808B %VI041808A
    if over
        if find((state.init.eom.lut(over) - pockelsVoltageRange) >= .005) %VI021808B
            fprintf(2, ['Warning: Illegal entries found in the Pockels cell voltage lookup table (exceeded maximum value of ' num2str(pockelsVoltageRange) 'V specified. in INI file). Resetting them into legal range.' sprintf('\n')]); %VI101608A, VI110208A
        end
        state.init.eom.lut(over) = pockelsVoltageRange;  %VI021808B %VI041808A
    end
    under0 = find(state.init.eom.lut < 0);
    if under0
        if find(state.init.eom.lut(under0) <= -.005)
            fprintf(2, 'Warning: Illegal entries found in the Pockels cell voltage lookup table (under 0V), resetting them into legal range.\n');
        end
        state.init.eom.lut(under0) = 0;
    end

    %Test purposes.
    %figure;plot(photodiode_voltage);
    %figure;plot(eom.lut, '.');
    if size(state.init.eom.lut(beam, :), 2) ~= 100
        error(sprintf('Pockels cell %s lookup table size out of bounds: %s', num2str(beam), num2str(size(state.init.eom.lut(beam, :), 2))));
    end

    %TO12204a - Tim O'Connor 1/24/04: Somehow the min wasn't a cardinal value when one laser was configured but turned off.
    state.init.eom.min(beam) = ceil(state.init.eom.min(beam));

    markCalibration(beam); %VI041008B
%     state.init.eom.changed(beam) = 1;
%     ensureEomGuiStates(beam);%TO22604g
% 
%     %Flag that it's been calibrated (at least once). TO22604e
%     state.init.eom.calibrated(beam) = 1;

%%VI103108A: This is now done first, and pooled with 'non'-calibration case
% else %Handle naive calibration case
%     fprintf(2,['WARNING: Beam #' num2str(beam) ' does not have a photodiode for calibration. Linear calibration presumed. ' sprintf('\n')]);
%     naiveEOMCalibrate(beam); 
%     markCalibration(beam);
%%%%%%%%%%
end
    
    
return;

%Handle end of calibration (VI041008B)
function markCalibration(beam)
global state  %VI050508A

state.init.eom.changed(beam) = 1;
ensureEomGuiStates(beam);%TO22604g

%Flag that it's been calibrated (at least once). TO22604e
state.init.eom.calibrated(beam) = 1;
return;

%Ensure that AO settings are restored, regardless of calibration outcome (VI041908A)
function restoreAOSettings(beam,ao_s_rate,ao_repeat_output,ao_clock_source,ao_trig_source,ao_buffering_config,ao_buffering_mode)
global state

setAOProperty(state.acq.dm, state.init.eom.pockelsCellNames{beam}, 'SampleRate', ao_s_rate);
setAOProperty(state.acq.dm, state.init.eom.pockelsCellNames{beam}, 'RepeatOutput', ao_repeat_output);
setAOProperty(state.acq.dm, state.init.eom.pockelsCellNames{beam}, 'ClockSource', ao_clock_source);
setAOProperty(state.acq.dm,state.init.eom.pockelsCellNames{beam},'HwDigitalTriggerSource',ao_trig_source);
%setAOProperty(state.acq.dm,state.init.eom.pockelsCellNames{beam},'BufferingConfig',ao_buffering_config); %VI052108A, VI081208A
%setAOProperty(state.acq.dm,state.init.eom.pockelsCellNames{beam},'BufferingMode',ao_buffering_mode); %VI052108A, VI081208A


return;


