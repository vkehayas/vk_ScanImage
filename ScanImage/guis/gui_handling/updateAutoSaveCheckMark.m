%% CHANGES
%   VI091608A: Handle case where saveDuringAcquisition is enabled, but autoSave is disabled -- Vijay Iyer 9/16/08
%   VI091608B: Update mainControls GUI based on autoSave state var -- Vijay Iyer 9/16/08
%   VI091608C: Accept optional input argument to allow this to be a 'direct' callback -- Vijay Iyer 9/16/08
%   VI091708A: Handle /all/ the control state updates here, based on autoSave state var. This is sometimes redundant with he INI-file callback, but that won't always be called -- Vijay Iyer 9/17/08
%   VI120408A: Handle improve mainControls GUI controls reflecting state of autoSave state var -- Vijay Iyer 12/04/08
%   VI121008A: Ensure that save/logging status is green-colored when either Logging is active or auto-save is enabled -- Vijay Iyer 12/10/08
%
%% **********************************************
function updateAutoSaveCheckMark(varargin) %VI091608C
% BSMOD - 1/1/2 - sets check mark next to autoSave selection in settings menu

    global gh state
	% get the index of the standard mode selection of the settings menu
	children=get(gh.mainControls.Settings, 'Children');			
	index=getPullDownMenuIndex(gh.mainControls.Settings, 'Auto save');
	
    if state.files.autoSave==0 && ~state.acq.saveDuringAcquisition %VI091608A
        set(children(index), 'Checked', 'off');
		hideGUI('gh.mainControls.baseName');
		hideGUI('gh.mainControls.fileCounter');
		hideGUI('gh.mainControls.baseNameLabel');
		hideGUI('gh.mainControls.fileCounterLabel');
		if ~state.internal.keepAllSlicesInMemory
			beep;
			errordlg({ ...
				'''Keep All Slices In Memory'' is OFF and ''Auto Save'' is OFF.' , ...
				'Data will be lost for all acquisitions of more than 1 slice.', ...
				'Recommend turning ''Auto Save'' on.'}, ...
				'Warning', 0);
        end
        set(gh.mainControls.stLogging,'BackgroundColor',[1 0 0]); %VI120408A, VI121008A
	else
        set(children(index), 'Checked', 'on');
		seeGUI('gh.mainControls.baseName');
		seeGUI('gh.mainControls.fileCounter');
		seeGUI('gh.mainControls.baseNameLabel');
		seeGUI('gh.mainControls.fileCounterLabel');
        set(gh.mainControls.stLogging,'BackgroundColor',[0 .8 0]); %VI121008A
    end
    
    %%%%VI091608B%%%%%%%%
    if state.files.autoSave
        %set(gh.mainControls.cbAutoSave,'BackgroundColor',[0 .8 0]); %VI120408A
        %set(gh.mainControls.stLogging,'BackgroundColor',[0 .8 0]); %VI120408A
    else
        %set(gh.mainControls.cbAutoSave,'BackgroundColor',[1 0 0]); %VI120408A
        %set(gh.mainControls.stLogging,'BackgroundColor',[1 0 0]); %VI120408A, VI121008A             
    end    
    %%%%%%%%%%%%%%%%%%%%%%%%%
        
