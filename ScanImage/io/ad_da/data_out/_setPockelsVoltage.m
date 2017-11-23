function setPockelsVoltage(beam, volt)
% This will set the pockels cell to the voltage specified in volt
%TPMOD 2/6/02

global state
if state.init.eom.pockelsOn
    if volt >= -10 & volt <= 10
        putDaqSample(state.acq.dm, state.init.eom.pockelsCellNames{beam}, volt);
    else
        display('setPockelsVoltage: Voltage out of range -10 to 10.');
        beep;
        return
    end
end

