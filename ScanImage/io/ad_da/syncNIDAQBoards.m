%% function syncNIDAQBoards(master, slave)
% This function will tie the board clocks for many National Instruments boards together.

%% SYNTAX
% master: a daq object from the main board
% slave: a array of daq objects and/or @daqmanager channel names, one from each of the slave boards.

%% NOTES
% This function uses the internal RTSI Bus, so they need to be wired together inside the computer.
% This function is only used at present to synchronize AO sample clocks
% Use master as fast board, and slow boards as slaves.
%
% Notes for ScanImage:
% state.init.ao1F is the slow board PCI MIO 16E-4
% state.init.ao2F is the fast 6110E



%% MODIFICATIONS
%   VI021608A Vijay Iyer 2/16/08 - Added DAQmx case
%   VI021908A Vijay Iyer 2/19/08 - Handle case where slaves can be either a DAQ Toolbox object or a @daqmanager named-channel. Use cell array now.
%   VI022008A Vijay Iyer 2/20/08 - Make this work only for AO clocks.
%   VI022008B Vijay Iyer 2/20/08 - Check to ensure that master/slave boards aren't the same, before synchronizing
%   VI030608A Vijay Iyer 3/06/08 - Handled both @analogoutput and @daqmanager named-channel cases for the Trad NI-DAQ driver branch
%
%%
function syncNIDAQBoards(master, slave)
global state

if nargin ~= 2
	error('syncNIDAQBoards: must supply a master and slave objects to sync boards.');
end
  
        
if ~iscell(slave)
    slave = {slave};
end

switch whichNIDriver
    case 'NI-DAQ'
        InfoMaster=daqhwinfo(master);
        MasterID=InfoMaster.ID;
        daqmex(master,'call', 'select_signal', 32100, 12170,15900); % output clock from master on RTSI Pin 1

        for i = 1:length(slave)
            if isa(slave{i},'daqdevice') %VI030608A
                thisSlave = slave{i};
            elseif ischar(slave{i})
                thisSlave = getAO(state.acq.dm,slave{i});
            else
                error(['Slave device # ' num2str(i) ' not recognized--must be either a DAQ Toolbox object or @daqmanager named-channel']);
            end
            InfoSlave=daqhwinfo(thisSlave);
            SlaveID=InfoSlave.ID;
            if MasterID == SlaveID	% Check to make sure board IDs are different for master and slave
                error('syncNIDAQBoards: Master and slave cannot be from the same board. Check daqhwinfo(obj). ');
            else
                daqmex(thisSlave,'call', 'select_signal', 12170, 32100,15900);% slave slow board clock on RTSI Pin 1
                disp(['Tied Clocks for NIDAQ boards # ' num2str(MasterID) ' and # ' num2str(SlaveID) ' together.']);
            end
        end
    case 'DAQmx'  %VI021608A
        %Clock signal is exported from master (acquisition board sample clock) by fiat 
        %Only have to configure its slave(s) to obey     

        
        %Get master board ID (VI022008B)
        if isa(master,'daqdevice')
            masterBoardID = getfield(daqhwinfo(master),'ID');
        else %handle @daqmanager named-channel case
            masterBoardID = ['Dev' num2str(getBoardID(dm,master))];
        end
            
        for i=1:length(slave)
            
           if isa(slave{i},'daqdevice')  %VI021908A
               boardID = getfield(daqhwinfo(slave{i}),'ID');
               subsystemType = getfield(daqhwinfo(slave{i}),'SubsystemType');      
               if ~strcmpi(masterBoardID,boardID) %only synchronize master and particular slave are on different boards (VI022008B)
                   set(slave{i},'ClockSource','External');
                   set(slave{i},'ExternalClockSource',state.init.outputBoardClockTerminal); %VI022008A
               end
           elseif ischar(slave{i}) %handle @daqmanager named-channel case (VI021908A)
                dm = state.acq.dm;
                boardID = ['Dev' num2str(getBoardID(dm,slave{i}))];
                if ~strcmpi(masterBoardID,boardID) %only synchronize master and particular slave are on different boards (VI022008B)
                    setAOProperty(state.acq.dm,slave{i},'ClockSource','External');
                    setAOProperty(state.acq.dm,slave{i},'ExternalClockSource',state.init.outputBoardClockTerminal); %VI022008A
                end
           else
               error(['Slave device # ' num2str(i) ' not recognized--must be either a DAQ Toolbox object or @daqmanager named-channel']);
           end

        end
end
               
               
%%%%%%%%%%%%%%USING Timebase synchronization via DAQmxConnectTerms() did /not/ work -- it only exported timebase, but failed to import one.
%                errorVal = calllib('nicaiu','DAQmxConnectTerms', ['/' masterBoardID '/RTSI7'], ...
%                    ['/' boardID '/RTSI7'],0);
%                if errorVal
%                    error(['Error synchronizing DAQ board timebases. DAQmx returned error code ' num2str(errorVal) ' upon call to DAQmxConnectTerms()']);
%                end               
%                
%                errorVal = calllib('nicaiu','DAQmxConnectTerms',['/' boardID '/RTSI6'], ...
%                    ['/' boardID '/ao/SampleClock'],0);
%                if errorVal
%                    error(['Error synchronizing DAQ board timebases. DAQmx returned error code ' num2str(errorVal) ' upon call to DAQmxConnectTerms()']);
%                end
               
%                errorVal = calllib('nicaiu','DAQmxConnectTerms',['/' masterBoardID '/20MHzTimebase'], ...
%                    ['/' boardID '/MasterTimebase'],0);
%                if errorVal
%                    error(['Error synchronizing DAQ board timebases. DAQmx returned error code ' num2str(errorVal) ' upon call to DAQmxConnectTerms()']);
%                end               


