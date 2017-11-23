function applyConfigurationSettings
global state
% applies configuration settings to current AI AO objects
% does not take into account changes in number of channels
% acquired

    setImagesToWhole;
    checkConfigSettings;
    
	stopGrab;
	stopFocus;

	setupDAQDevices_ConfigSpecific;
    
	preallocateMemory;
    
	setupAOData;
    flushAOData;
	
    if state.internal.aspectRatioChanged==1;
	    resetImageProperties(1);
        state.internal.aspectRatioChanged=0;
    else
        resetImageProperties(0);
    end
	
	resetCounters;
	updateHeaderString('state.acq.pixelsPerLine');
	updateHeaderString('state.acq.fillFraction');

	state.internal.configurationChanged=0;

	startPMTOffsets;
    
    updateShutterDelay;
    
    %TPMODPockels
    updatePowerBox;
    
    if state.init.eom.pockelsOn
        state.init.eom.changed(:) = 1;
    end
   
    verifyEomConfig;
