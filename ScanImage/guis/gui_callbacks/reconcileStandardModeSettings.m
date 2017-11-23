function reconcileStandardModeSettings()
%% function reconcileStandardModeSettings()
%Verify that the Standard Mode GUI settings do not violate any restrictions and, if so, correct them
%
%% MODIFICATIONS
%   VI031308A -- Moved this function to its own file and made changes accordingly -- Vijay Iyer 3/13/08
%   VI031308B -- Avoid infinite recursion --not sure why this didn't occur before -- Vijay Iyer 3/13/08
%   VI081308A -- Special Pockels features only apply if Pockels is on -- Vijay Iyer 8/13/08
%   VI091608A -- Use new updateSaveDuringAcq callback function -- Vijay Iyer 9/16/08
%   VI120108A -- This is very ugly, but ensure that state.init.eom.uncagingMapper.enabled is numeric before applying test on it -- Vijay Iyer 12/01/08
%   VI121008A -- Ensure that updateSaveDuringAcq callback function is actually invoked -- Vijay Iyer 12/10/08
%
%% *****************************************************************

global state gh

if get(gh.standardModeGUI.cbSaveDuringAcq,'Value') %VI031308B
    allowSaveDuringAcq = true;

    %%%VI120108A%%%%%%%%%%%%%%%
    if state.init.eom.pockelsOn && ischar(state.init.eom.uncagingMapper.enabled)
        state.init.eom.uncagingMapper.enabled = ndArrayFromStr(state.init.eom.uncagingMapper.enabled);
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    if state.init.eom.pockelsOn && (state.init.eom.usePowerArray || any(state.init.eom.showBoxArray) || any(state.init.eom.uncagingMapper.enabled)) %VI081308A
        allowSaveDuringAcq = false;
        display(['****(SCANIMAGE; ' datestr(now) '): Cannot save during acquisition while using powerBox or uncagingMapper features.********']);
    elseif state.standardMode.averaging
        allowSaveDuringAcq = false;
        display(['****(SCANIMAGE; ' datestr(now) '): Cannot save during acquisition while frame averaging is enabled.********']);
    elseif state.standardMode.numberOfZSlices>1
        allowSaveDuringAcq = false;
        display(['****(SCANIMAGE; ' datestr(now) '): Cannot save during acquisition for multi-slice (stack) acquisitions.********']);
    end

    if ~allowSaveDuringAcq
        state.standardMode.saveDuringAcquisition = 0; %VI091608A
        updateGUIByGlobal('state.standardMode.saveDuringAcquisition','Callback',1); %VI091608A, VI121008A
        %set(gh.standardModeGUI.cbSaveDuringAcq,'Value',0);
        %standardModeGUI('cbSaveDuringAcq_Callback',gh.standardModeGUI.cbSaveDuringAcq,[],guidata(gh.standardModeGUI.cbSaveDuringAcq)); %VI031308A        
    end
end

