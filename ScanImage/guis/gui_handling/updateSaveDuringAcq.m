%updateSaveDuringAcq: Handle changes to saveDuringAcq
%% NOTES
%   This was previously handled directly as cbSaveDuringAcq callback, but was moved to this separate callback. This allows function to be called during configuration loads.
%
%   At present, saveDuringAcq is only supported during standardMode acquisitions
%% CHANGES
%   VI120208A: Make call to preallocate memory non-verbose if this callback was invoked during configuration loading -- Vijay Iyer 12/02/08
%   VI120408A: Hanlde improved mainControls GUI controls for specifying autosave and logging status -- Vijay Iyer 12/04/08
%   VI102809A: Handle cycle mode case, forcing saveDuringAcquisition off -- Vijay Iyer 10/28/09
%% CREDITS
%   Created 9/16/08 by Vijay Iyer
%% ********************************

function updateSaveDuringAcq(varargin)

global state gh

if state.standardMode.standardModeOn %VI102809A
    reconcileStandardModeSettings; %VI091608A

    if state.standardMode.saveDuringAcquisition %turned on
        set(gh.standardModeGUI.etFramesPerFile,'Enable','on');
        % etFramesPerFile_Callback(gh.standardModeGUI.etFramesPerFile,[]); %ensures that the value of FramesPerFile makes sense...I don't think this is needed anymore (VI-3/8/08)
    else
        %     if state.acq.msPerLine*state.acq.linesPerFrame*state.acq.numberOfFrames > state.init.maxBufferedGrabTime
        %         display(['****(SCANIMAGE; ' datestr(now) ') WARNING: There may be insufficient memory for currently specified long Grab acquisition.********']);
        %     end
        set(gh.standardModeGUI.etFramesPerFile,'Enable','off');
    end

    if state.standardMode.standardModeOn
        state.acq.saveDuringAcquisition = state.standardMode.saveDuringAcquisition;
    else
        state.acq.saveDuringAcquisition = 0;
    end
    updateAutoSaveCheckMark; %VI091608A

    %%%VI120208A%%%%%%%%%%%%%%%%
    x = dbstack;
    if ismember('loadStandardModeConfig.m',{x.file})
        preallocateMemory(false);
    else
        preallocateMemory(true);
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%VI102809A%%%%%%%%%%%%%
else %Cycle mode is active
    state.acq.saveDuringAcquisition = 0;    
    %Do not call preallocateMemory() here. It's called during applyConfigurationSettings()
end
%%%%%%%%%%%%%%%%%%%%%%%%%%

%If disk-logging...autoSave status is irrelevant, so don't display on mainControls GUI
if state.acq.saveDuringAcquisition
    %%%VI120408A%%%%
    set(gh.mainControls.cbAutoSave,'Visible','off');
    %set(gh.mainControls.stLogging,'Visible','on');
    set(gh.mainControls.stLogging,'String','Logging','HorizontalAlignment','center','TooltipString','Data is logged to TIF file continuously during GRAB/LOOP acqusitions');
    %%%%%%%%%%%%%%%%%
else
    %%%VI120408A%%%%
    set(gh.mainControls.cbAutoSave,'Visible','on');
    %set(gh.mainControls.stLogging,'Visible','off');
    set(gh.mainControls.stLogging,'String','AutoSV','HorizontalAlignment','right','TooltipString','Specifies whether GRAB/LOOP acquisitions are automatically saved following acquisition');
    updateAutoSaveCheckMark;
    %%%%%%%%%%%%%%%%
end
