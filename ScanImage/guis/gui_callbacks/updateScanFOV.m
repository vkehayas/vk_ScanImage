function updateScanFOV(handle)
%UPDATESCANFOV Validates vaules of  scanAmplitude, and scaleXShift parameters
%% NOTES
%   At this time, this function is DEPRECATED. Simplicity prevails. -- Vijay Iyer 12/19/08
%   
%   This function is the INI-file-specified callback for offset/amplitude variables
%   At present, amplitude and offset are separately clamped.
%% CHANGES
%   VI110608A: No longer handle scanOffsetX/Y validation here, since that can only be set indirectly -- Vijay Iyer 11/6/08
%   VI121908A: Clamp shift based on new maxShiftFraction variable -- Vijay Iyer 12/19/08
%
%% CREDITS
%    Created 6/25/08 by Vijay Iyer -- Janelia Farm Research Campus
%% ****************************************************************************

global state

%%%VI121908A%%%%%%%%
%clampVar('state.acq.scaleXShift',state.init.maxOffsetX);
%clampVar('state.acq.scaleYShift',state.init.maxOffsetY);
clampShift('X');
clampShift('Y');
%%%%%%%%%%%%%%%%%%%%

% clampVar('state.init.scanOffsetX',state.init.maxOffsetX); %VI110608A
% clampVar('state.init.scanOffsetY',state.init.maxOffsetY); %VI110608A

clampAmplitude('state.acq.scanAmplitudeX',state.init.maxAmplitudeX); %VI121908A: was clampVar 
clampAmplitude('state.acq.scanAmplitudeY',state.init.maxAmplitudeY); %VI121908A: was clampVar

    %%%VI121908A%%%%
    function clampShift(dimString)
        shift = eval(['state.acq.scale' dimString 'Shift']);
        offset = eval(['state.init.scanOffset' dimString]);
        amplitude = eval(['state.acq.scanAmplitude' dimString]);
        
        if ~isinf(state.init.maxShiftFraction)
            if abs((abs(amplitude)/state.acq.zoomFactor) + offset + shift) > abs(amplitude) * (1+state.init.maxShiftFraction)
                shiftDif  = abs((abs(amplitude)/state.acq.zoomFactor) + offset + shift) - (abs(amplitude) * (1+state.init.maxShiftFraction));
                shift = sign(shift) * (abs(shift) - shiftDif);
                eval(['state.acq.scale' dimString 'Shift = ' num2str(shift) ';']);
                updateGUIByGlobal(['state.acq.scale' dimString 'Shift']);
            end            
        end    
    end
    %%%%%%%%%%%%%%%%%

    function clampAmplitude(varName,clampVal) %VI121908A: was clampVar
        varVal = eval(varName);
        if abs(varVal) > clampVal
            varVal = sign(varVal)*clampVal;
            eval([varName '=' num2str(varVal) ';']);
            updateGUIByGlobal(varName);
        end
    end

end


