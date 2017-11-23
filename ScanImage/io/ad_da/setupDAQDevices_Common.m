%% function setupDAQDevices_Common
% Sets up the portions of AO and AI objects that are configuration independent
%
%% NOTES
% It does make the handles to the DAQ devices global, and it does access the globals for the boards for 
% identification purposes.
% No channels are added to the AI devices, but they rather are added by the selectAIChannels function.
%
% Action functions are defined for the input objects and do not change during any acquisition.
% Defines the I/O paraemters like the function updateGrabAndFocusVariables.m.
%
% This will select from the .ini file the Boards to use tand the correct index for this machine.
%
%% CHANGES
%   VI021608A Vijay Iyer 2/16/08 - Add DAQmx-specific handling and enhancements
%   VI110708A Vijay Iyer 11/07/08 - Use 'prototype m file' to load only functions needed, avoiding warning messages associated with (unused) functions that have variable numbers of arguments
%   VI071509A Vijay Iyer 7/15/09 - Suppress warning regarding incompatibility with future Matlab versions. We only need this to work through 2008B -- Vijay Iyer 7/15/09
%
%% 
% Written by: Thomas Pologruto and Bernardo Sabatini
% Cold Spring Harbor Labs
% February 8, 2001
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
function setupDAQDevices_Common
global gh state

% setupDAQDevices.m*****
% Function that sets up the I/O for the system.

%Create/bind @daqmanager for Pockels cell channel(s) (very lame that only Pock Cell channels use @daqmanager)
state.acq.dm = daqmanager('nidaq');

setupAOObjects_Common;
setupAIObjects_Common;

%Handle DAQmx-specific functionality %VI021608A
if strcmpi(whichNIDriver,'DAQmx')
    try 
        %loadlibrary('nicaiu.dll','C:\Program Files\National Instruments\NI-DAQ\DAQmx ANSI C Dev\include\nidaqmx.h'); %VI021608A
        warning('off','MATLAB:loadlibrary:OldStyleMfile'); %VI071509A
        loadlibrary('nicaiu.dll',@nidaqmx); %VI110708A
        warning('on','MATLAB:loadlibrary:OldStyleMfile'); %VI071509A
        

%         %Export acquisition board's master timebase onto the RTSI terminal to which it can be directly routed 
%         errorVal = calllib('nicaiu','DAQmxConnectTerms',['/' state.init.acquisitionBoardIndex '/20MHzTimebase'],...
%             ['/' state.init.acquisitionBoardIndex '/' 'RTSI7'],0);
%         if errorVal
%             error(['DAQmx returned error code ' num2str(errorVal) ' upon call to DAQmxConnectTerms()']);
%         end

        %Export mirror board's master timebase onto a RTSI terminal to which it can be directly routed
        errorVal = calllib('nicaiu','DAQmxConnectTerms',['/' state.init.mirrorOutputBoardIndex '/ao/SampleClock'],...
            ['/' state.init.mirrorOutputBoardIndex '/' state.init.outputBoardClockTerminal],0);
        if errorVal
            error(['DAQmx returned error code ' num2str(errorVal) ' upon call to DAQmxConnectTerms()']);
        end
        
%         %Synchronize the mirror board to the acquisition board -- if they are not on the same here, to the master acquisition clock...if we decide to make the acq clock the master. Only problem is that integer ratio should be enforced.
%         if ~strcmpi(state.init.acquisitionBoardIndex,state.init.mirrorOutputBoardIndex)
%             syncNIDAQBoards(state.init.acquisitionBoardIndex,state.init.mirrorOutputBoardIndex);
%         end

        unloadlibrary('nicaiu');
        
    catch
        disp('******************************************************');
        disp(['Attempted to export master sample clock from ' state.init.mirrorOutputBoardIndex ', but an error was encountered:' sprintf('\n')]);
        rethrow(lasterror);
        disp('Channels which receive their clock input from the master clock will not operate.');
        disp('******************************************************');
    end
    
%     %Adjust all the triggers on all the boards to be on the specified trigger input terminal
%     calllib('nicaiu','DAQmxConnectTerms',['/' state.init.mirrorOutputBoardIndex '/ao/StartTrigger'],...
%         ['/' state.init.mirrorOutputBoardIndex '/' state.init.triggerInputTerminal],0);
%     
%     calllib('nicaiu','DAQmxConnectTerms',['/' state.init.acquisitionBoardIndex '/ai/StartTrigger'],...
%         ['/' state.init.acquisitionBoardIndex '/' state.init.triggerInputTerminal],0); 
%     
%     if state.init.pockelsOn 
%         for i=1:length(state.init.eom.numberOfBeams)            
%             boardNum = eval(['state.init.eom.pockelsBoardIndex' num2str(i)]);
%             calllib('nicaiu','DAQmxConnectTerms',['/Dev' num2str(boardNum) '/ao/StartTrigger'],...
%                 ['/Dev' num2str(boardNum) '/' state.init.triggerInputTerminal],0);
%             
%             boardNum = eval(['state.init.eom.photodiodeInputBoardId' num2str(i)]);
%             if ~isempty(boardNum)
%                 calllib('nicaiu','DAQmxConnectTerms',['/Dev' num2str(boardNum) '/ai/StartTrigger'],...
%                     ['/Dev' num2str(boardNum) '/' state.init.triggerInputTerminal],0);
%             end
%         end
%     end
    

    
end