%%  function snapShot(nof)
%  This function takes nof frames and averages them but does not autosave the image or
%  move the Z focus.  The user can then save the image by 
%  Selecting Ctrl+S or Save last Acquisition from the File Menu.
%
%%  CHANGES
%    Modified to work with multiple lasers - T. O'Connor 12/23/03
%    Modified to blank properly for non scan beams. - T. O'Connor 2/16/04 TO21604
%    Store lists of which beams to enable at which times. - Tim O'Connor 4/23/04 TO042304a
%% CREDITS
%  Written by: Thomas Pologruto
%  Copyright - Howard Hughes Medical Institute/Cold Spring Harbor Laboratories 2003
%% **********************************************************
function snapShot(nof)
%THis function takes nof frames and averages them but does not autosave the image or
% move the Z focuis.  Thje user can then save the image by 
% Selecting Ctrl+S or Save last Acquisition from the File Menu.
global state gh
if state.acq.acquireImageOnChange
    if nargin < 1
        nof=1;
    end
    %TPMODPockels
    old=state.init.eom.usePowerArray;
    state.init.eom.usePowerArray=0;
    if state.internal.updatedZoomOrRot | any(state.init.eom.changed) % need to reput the data with the approprite rotation and zoom.
		state.acq.mirrorDataOutput = rotateAndShiftMirrorData(1/state.acq.zoomFactor*state.acq.mirrorDataOutputOrg);
		flushAOData;
		state.internal.updatedZoomOrRot=0;
	end
%     if state.internal.updatedZoomOrRot | state.init.eom.changed(state.init.eom.scanLaserBeam) % need to reput the data with the approprite rotation and zoom.
%         state.acq.mirrorDataOutput = rotateMirrorData(1/state.acq.zoomFactor*state.acq.mirrorDataOutputOrg);
%         flushAOData;
%         state.internal.updatedZoomOrRot=0;
%     end
   
    figure(gh.mainControls.figure1);
    state.internal.whatToDo=4;
    h=gh.mainControls.grabOneButton;
    state.files.autoSaveBSnap=state.files.autoSave;	
    state.acq.numberOfZSlicesBSnap=state.acq.numberOfZSlices;
    state.acq.numberOfFramesBSnap=state.acq.numberOfFrames;
    state.acq.averagingBSnap=state.acq.averaging;
    val=get(h, 'String');
    if strcmp(val, 'GRAB')
        if strcmp(get(gh.basicConfigurationGUI.figure1, 'Visible'), 'on') == 1
            beep;
            setStatusString('Close Configuration GUI');
            return
        end
        state.internal.snapping=1;
        state.files.autoSave=0;
        state.acq.numberOfZSlices=1;
        state.acq.averaging=1;
        state.acq.numberOfFrames=nof;
        flushAOData;
        preallocateMemory;
        alterDAQ_NewNumberOfFrames;
        MP285Clear; %VI100608A
        
        setStatusString('Acquiring SnapShot...');
        set(h, 'String', 'ABORT');
        set([gh.mainControls.focusButton gh.mainControls.startLoopButton], 'Visible', 'Off');
        turnOffMenus;
        
        resetCounters;
        state.internal.abortActionFunctions=0;
        
        updateGUIByGlobal('state.internal.frameCounter');
        updateGUIByGlobal('state.internal.zSliceCounter');

        %12/23/03 - Tim O'Connor
        if state.init.eom.pockelsOn
            %Blank all beams except the scan laser. Also, the scan laser will
            %not do anything fancy, just blank on flyback.
            for beamCounter = 1 : state.init.eom.numberOfBeams
                %Don't check to see if anything's changed, since cached data
                %from Focus/Grab won't work here.
%                 if beamCounter ~= state.init.eom.scanLaserBeam
                    %TO21604 - Index into eom.lut, instead of just referencing
                    %min. That is to say, fixed a typo.
%                     putDaqData(state.acq.dm, state.init.eom.pockelsCellNames{beamCounter}, ...
%                         ones(state.internal.lengthOfXData * state.acq.linesPerFrame * nof, 1) * ...
%                         state.init.eom.lut(beamCounter, state.init.eom.min(beamCounter)));
                    putDaqData(state.acq.dm, state.init.eom.pockelsCellNames{beamCounter}, ...
                            makePockelsCellDataOutput(beamCounter));
%                 else
%                     data = makePockelsCellDataOutput(beamCounter, 1);%Flyback blanking only. Just 1 frame.
%                     putDaqData(state.acq.dm, state.init.eom.pockelsCellNames{beamCounter}, ...
%                         repmat(data, [nof 1]));
%                 end
                
                %Force Focus/Grab to recreate their data.
                state.init.eom.changed(beamCounter) = 1;
            end
        end
        
        %Tim O'Connor 4/23/04 TO042304a: Store lists of which beams to enable at which times.
        startSnapShot;
        updateCurrentROI;
        openShutter;
        state.init.eom.usePowerArray=old;
        dioTrigger;
    else
        state.internal.snapping=0;
        disp('executeGrabOneCallback: Grab One button is in unknown state'); 	% BSMOD - error checking
    end
end