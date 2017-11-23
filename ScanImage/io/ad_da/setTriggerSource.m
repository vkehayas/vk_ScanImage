function setTriggerSource(target,forceInternal)
%%function setTriggerSource(target,forceInternal)
%SETTRIGGERSOURCE Updates the trigger source property of the specified @daqdevice or @daqmanager channel. 
%   Function serves to handle the differential triggering behavior between NI driver versions
%
%% USAGE
%   target: Either an array of DAQ Toolbox @daqdevices (i.e. @analogoutput or @analoginput object) or a single @daqmanager named channel
%   forceInternal: Logical indicating whether to force internal triggering. If false, 'state.acq.externallyTriggered' determines internal vs. external triggering
%
%% NOTES
%   The @daqmanager named-channel case is to support Pockels cell AO channels /only/ -- these are the only ones which are @daqmanager-managed
%
%%%%%%%%%%%%%%%%%
%%

global state

if isempty(strfind(daqhwinfo('nidaq','AdaptorDllName'),'mwnidaqmx.dll')) %TRAD NI-DAQ
    %DO NOTHING: always use the default trigger inputs for the AI/AO objects as per ScanImage 3.0 functionality. 
    % The state variables 'state.init.triggerInputTerminal' and 'state.init.externalTriggerInputTerminal' are ignored
else
    if isa(target,'daqdevice') 
        if state.acq.externallyTriggered && ~forceInternal
            set(target,'HwDigitalTriggerSource',state.init.externalTriggerInputTerminal);
        else
            set(target,'HwDigitalTriggerSource',state.init.triggerInputTerminal);
        end
    else
        if state.acq.externallyTriggered && ~forceInternal
            setAOProperty(state.acq.dm,target,'HwDigitalTriggerSource',state.init.externalTriggerInputTerminal);
        else
            setAOProperty(state.acq.dm,target,'HwDigitalTriggerSource',state.init.triggerInputTerminal);
        end
    end
end
