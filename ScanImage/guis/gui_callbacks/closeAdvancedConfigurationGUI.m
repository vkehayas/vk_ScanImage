function closeAdvancedConfigurationGUI
%% function closeAdvancedConfigurationGUI
% closes the advanced configuration GUI 
%% MODIFICATIONS
%   VI052308A Vijay Iyer 5/23/08 -- Apply workaround (MW Service Request  1-6D7KRV) to ensure that uicontrol callbacks are executed--different behavior starting with v7
%
%% *******************************************************
try
    hideGUI('gh.advancedConfigurationGUI.figure1');
    drawnow; %VI052308A
    seeGUI('gh.advancedConfigurationGUI.figure1'); %VI052308A
    hideGUI('gh.advancedConfigurationGUI.figure1'); %VI052308A
end

verifyEomConfig;