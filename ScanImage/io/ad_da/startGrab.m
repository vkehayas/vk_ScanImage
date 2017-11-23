function startGrab
%% function startGrab
% Function that will start the DAQ devices running for Grab (ao1, ao2, ai).
%
% Written by: Thomas Pologruto
% Cold Spring Harbor Labs
% February 7, 2001
%
%% MODIFICATIONS
% 11/24/03 Tim O'Connor - Start using the daqmanager object.
% 4/22/04 Tim O'Connor (TO042204a): Store lists of which beams to enable at which times.
% 9/20/04 Tim O'Connor (TO092004a): Look out for the total disabling of lasers for a given function.
% 3/07/08 Vijay Iyer (VI030708A): Handle case where saving during acquisition is enabled
% 4/13/08 Vijay Iyer (VI041308A): Handle trigger properties based on External trigger toggle-button
% 4/18/08 Vijay Iyer (VI041808A): Use LUT value to determine minimum value
% 4/30/08 Vijay Iyer (VI043008A): Setup increased buffering for Pockels output chans
% 6/23/08 Vijay Iyer (VI062308A): Update header info to correctly reflect the framesPerFile value
% 6/23/08 Vijay Iyer (VI062308B): Set framesPerFile to inf when all frames will be saved to one file
% 8/12/08 Vijay Iyer (VI081208A): Don't use manual BufferingConfig
% 8/13/08 Vijay Iyer (VI081308A): Special Pockels features only apply if Pockels is on 
% 8/21/08 Vijay Iyer (VI082108A): Set up @tifstream object if using saveDuringAcquisition
% 8/21/08 Vijay Iyer (VI082108B): Don't chunk files if frames/file equal # of frames
% 12/02/08 Vijay Iyer (VI120208A): Handle more gracefully the case where next file to create already existed
% 7/01/09 Vijay Iyer (VI070109A): Don't construct the @tifstream object prior to acquisition anymore. This is now done in acquisitionTriggeredFcn() callback, after header data is finalized.
% 
%% ***********************************************************************
global gh state

%VI030708A
if state.acq.saveDuringAcquisition
    standardModeGUI('cbSaveDuringAcq_Callback',gh.standardModeGUI.cbSaveDuringAcq,[],guidata(gh.standardModeGUI.cbSaveDuringAcq)); %Probably not necessary--but force through that logic anyway
    if state.acq.saveDuringAcquisition  %verifies that state hasn't changed
        if state.acq.numberOfFrames <= state.standardMode.framesPerFileGUI %VI082108B
            %state.acq.framesPerFile = state.acq.numberOfFrames;
            state.acq.framesPerFile = inf;
        else
            state.acq.framesPerFile = state.standardMode.framesPerFileGUI;
        end           
        updateHeaderString('state.acq.framesPerFile'); %VI062308A
        
        if ~isempty(state.files.tifStream)
            fileName = get(state.files.tifStream,'filename');
            if exist(fileName,'file')
                errordlg(['A TIF stream associated with the file ''' fileName ''' is still open. That file may be corrupt. The stream is now being forcibly closed to allow future GRABs']);
            else
                fprintf(2,'WARNING: A TIF stream was found already open. This is strange, but shouldn''t happen if trying the GRAB again.');
            end
            delete(state.files.tifStream,'leaveFile');
            state.files.tifStream = [];
            abortCurrent;       
        else
            if ~isinf(state.acq.framesPerFile) 
                state.files.tifStreamFileName  = [state.files.fullFileName '_001.tif']; %VI070109A 
            else
                state.files.tifStreamFileName = [state.files.fullFileName '.tif']; %VI070109A
            end             
            %%%VI070109A: Removed%%%%%%%%%
            %             try %VI120208A
            %                 state.files.tifStream = scim_tifStream(fileName,state.acq.pixelsPerLine, state.acq.linesPerFrame, state.headerString);
            %             catch %VI120208A
            %                 abortCurrent;
            %                 msgbox('Unable to initialize file for next acquisition. Most likely, the file already existed. Acquisition aborted.','Failed to Create File','error','modal');
            %                 disp(lasterr);
            %                 return;
            %             end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        end                     
    else
        state.acq.framesPerFile=inf; %VI062308A (this was set to 1; inf signals that all teh frames will be saved to a single file)
        updateHeaderString('state.acq.framesPerFile'); %VI062308A
    end    

end

if state.init.eom.pockelsOn == 1
%     startChannel(state.acq.dm, state.init.eom.pockelsCellNames);
    offBeams = find(~ismember(state.init.eom.pockelsCellNames, delimitedList(state.init.eom.grabLaserList, ',')));

    %Tim O'Connor TO092004a - Look out for the total disabling of lasers for a given function. - 9/20/04
    if length(offBeams) == state.init.eom.numberOfBeams
        errordlg('A beam must be enabled in the LaserFunctionPanel for this feature to work properly.');
    end
    
    %Tim O'Connor 7/20/04 TO072004a: Set all unchecked beams to their minima.
    for i = 1 : length(offBeams)
        putDaqSample(state.acq.dm, state.init.eom.pockelsCellNames{i}, state.init.eom.lut(i,state.init.eom.min(i))); %VI041808A 
    end
    
    list = delimitedList(state.init.eom.grabLaserList, ',');
    
    %Tim O'Connor 7/22/04 TO072204b: Make sure the RepeatOutput property is correct.
    %VI030708A: Handle the RepeatOutput differently for cases where there is or isn't power modulation besides flyback blanking
    for i = 1 : length(list)
        if state.init.eom.pockelsOn && (state.init.eom.usePowerArray || any(state.init.eom.showBoxArray) || any(state.init.eom.uncagingMapper.enabled)) %VI030708A
            repeatOutput=0;
        else
            repeatOutput=state.acq.numberOfFrames-1;
        end
        setAOProperty(state.acq.dm,list{i},'RepeatOutput',repeatOutput);
        %setAOProperty(state.acq.dm,list{i},'BufferingConfig',[2^18 round(2*state.init.outputChanBufferTime*state.acq.outputRate/2^18)]); %VI043008A, VI081208A
        setTriggerSource(list{i},false); %VI041308A
    end

    %Tim O'Connor 4/22/04 TO042204a: Store lists of which beams to enable at which times.
    startChannel(state.acq.dm, list);
end
setTriggerSource([state.init.ao2 state.init.ai],false); %VI041308A
start([state.init.ao2 state.init.ai]);