%function driverType = whichNIDriver()
%Function returns which National Instruments driver ScanImage is using
%
%% SYNTAX
% driverType: one of 'none, 'DAQmx', or 'NI-DAQ', where the latter refers to the traditional (legacy) NI drivers.
%
%% NOTES
%   Originally the logic was to report 'NI-DAQ' if it's found, even if DAQmx is present. This matched the then-current @daqmanager logic (which in turn reflected the then-current DAQ Toolbox logic)
%
%   Now the logic is to report/use DAQmx if it's found. Am not sure when the DAQ toolbox stopped forced use of the traditional NI-DAQ driver -- Vijay Iyer 2/27/09
%
%% CHANGES
%   VI110708A: Return 'none' if no driver is found, rather than throwing an error -- Vijay Iyer 11/07/08
%   VI022709A: Make DAQmx the default now -- Vijay Iyer 2/27/09
%
%%
function driverType = whichNIDriver()

try
    info = daqhwinfo('nidaq');
catch
    driverType = 'none'; %VI110708A
    return;
    %error('Unable to find any valid National Instruments driver. ScanImage will not function.'); %VI110708A
end

nidaqIndices = [];
daqmxIndices = [];
for i = 1 : length(info.InstalledBoardIds)
    if ~isempty(regexp(info.InstalledBoardIds{i},'[dD][eE][vV].*'))
        daqmxIndices(length(daqmxIndices) + 1) = i;
    else
        nidaqIndices(length(nidaqIndices) + 1) = i;
    end
end

if ~isempty(daqmxIndices)  %Trad NI-DAQ is found
    driverType = 'DAQmx'; %VI022709A
elseif ~isempty(nidaqIndices) %DAQmx driver only one found
    driverType = 'NI-DAQ'; %VI022709A
else
    error('No recognized National Instruments devices found, as required by ScanImage.'); 
end
