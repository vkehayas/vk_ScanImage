function out=openAndLoadConfiguration
% Allows user to select a configuration from disk and loads it
% Author: Bernardo Sabatini
%Modified: Tim O'Connor 2/19/04 TO21904a - Make messages more understandable.
%TO3204b - Pick up path from standard.ini, for convenience.
	out=0;

	global state

	status=state.internal.statusString;
	setStatusString('Loading Configuration...');
	if state.internal.configurationNeedsSaving==1
        
        if ~isempty(state.configName)
    		button = questdlg(['Do you want to save changes to ''' state.configName '''?'],'Save changes?','Yes','No','Cancel','Yes');
        else
            %TO21904 - Don't just print a set of empty quotes.
    		button = questdlg(['Do you want to save changes to the current configuration?'],'Save changes?','Yes','No','Cancel','Yes');
        end
        
		if strcmp(button, 'Cancel')
			disp(['*** LOAD CYCLE CANCELLED ***']);
			setStatusString('Cancelled');
			return
        elseif strcmp(button, 'Yes')
            if ~isempty(state.configName)
                disp(['*** SAVING CURRENT CONFIGURATION = ' state.configPath '\' state.configName ' ***']);
                flag=saveCurrentConfig;
                if ~flag
                    disp(['openAndLoadConfiguration: Error returned by saveCurrentCycle.  Cycle may not have been saved.']);
                    setStatusString('Error saving file');
                    return
                end
            else
                %TO21904a - Need to choose a name.
                saveCurrentConfigAs;
            end
			state.internal.configurationNeedsSaving=0;
		end
	end
	
	if ~isempty(state.configPath) & isdir(state.configPath)
        try
		    cd(state.configPath)
        end
	end
    %TO3204b - Use a prespecified path from standard.ini, if possible.
    if ~isempty(state.standardMode.configPath)
        %Make sure it's terminated with a '\' character.
        if state.standardMode.configPath(end) ~= '\'
            state.standardMode.configPath = [state.standardMode.configPath '\'];
        end
        [fname, pname] = uigetfile([state.standardMode.configPath '*.cfg'], 'Choose configuration to load');
    else
        [fname, pname] = uigetfile('*.cfg', 'Choose configuration to load');
    end
    
	if ~isnumeric(fname)
		periods=findstr(fname, '.');
		if any(periods)								
			fname=fname(1:periods(1)-1);
		else
			disp('openAndLoadConfiguration: Error: found file name without extension');
			setStatusString('Can''t open file');
			return
		end	
		state.standardMode.configName=fname;
		state.standardMode.configPath=pname;
		turnOffMenus;
		turnOffExecuteButtons;
        try
            if state.init.eom.pockelsOn
                for j = 1 : state.init.eom.numberOfBeams
                    h=findobj('Type','Rectangle','Tag', sprintf('PowerBox%s', num2str(j))); 
                    if ~isempty(h)
                        delete(h);
                    end
                end
            end
        catch
            warning(lasterr)
        end
		loadStandardModeConfig;
		turnOnMenus;
		turnOnExecuteButtons;
	end
	setStatusString(status);
    
    closeConfigurationGUI;