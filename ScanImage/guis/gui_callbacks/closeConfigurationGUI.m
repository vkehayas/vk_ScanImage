function closeConfigurationGUI
%% function closeConfigurationGUI
% Closes the configuration GUI and rebuilds DAQ devices if necesary
%
% Written By: Thomas Pologruto
% Cold Spring Harbor Labs
% January 26, 2001
% Modified: Bernardo Sabatini
% January 16, 2001
% Only resets devices if a change has been made to the configuration.
%% MODIFICATIONS
%   VI052308A Vijay Iyer 5/23/08 -- Apply workaround (MW Service Request  1-6D7KRV) to ensure that uicontrol callbacks are executed--different behavior starting with v7
%
%% *****************************************************

	global state

	try
		setStatusString('');
	catch
	end
    
    %Must come before checking for changes, so callbacks are sure to be executed.
    %Tim O'Connor 3/19/04
	hideGUI('gh.basicConfigurationGUI.figure1');
    drawnow; %VI052308A
    seeGUI('gh.basicConfigurationGUI.figure1'); %VI052308A    
    hideGUI('gh.basicConfigurationGUI.figure1'); %VI052308A
    
	if state.internal.configurationChanged==1
		applyConfigurationSettings;
	end