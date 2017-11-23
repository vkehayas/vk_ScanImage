function checkConfigSettings
%% function checkConfigSettings
% 

%% MODIFICATIONS
%   VI030108A Vijay Iyer 3/1/08 -- Handle bidirectional scanning case differently
%   VI030508A Vijay Iyer 3/5/08 -- Add in basic error checking for bidirectional scanning case
%   VI031808A Vijay Iyer 3/18/08 -- Update Pockels cell config info upon changes to cusp or line delay...
%   VI061908A Vijay Iyer 6/19/08 -- Handle rotation disabling here for case of bidirectional scan
%% *********************************************************
global gh state
if (state.internal.lineDelay + state.acq.fillFraction + state.acq.cuspDelay) >= .99999 && ~state.acq.bidirectionalScan %VI030108A
    beep;
    warning('state.internal.lineDelay + state.acq.fillFraction + state.acq.cuspDelay must be less than 1');
    state.acq.cuspDelay=(1-state.internal.lineDelay-state.acq.fillFraction);
    %Tim O'Connor 7/23/04 TO072304b: Someone mixed up the words 'big' and 'small'.
    %                                The whole thing was a big mess.
    if state.acq.cuspDelay<0
        state.acq.cuspDelay = 0;
        state.acq.lineDelay = 1 - state.acq.fillFraction;
        state.internal.lineDelay = state.acq.lineDelay;
        fprintf(2, 'Cusp Delay too big. Setting to 0.\n');
        fprintf(2, 'Line Delay too big. Setting to %s.\n', num2str(state.acq.lineDelay));
%         state.acq.cuspDelay=0;
%         disp(['Cusp Delay too small. Setting to ' num2str(state.acq.cuspDelay) '.']);
%         state.internal.lineDelay=1-state.acq.fillFraction;
        updateGUIByGlobal('state.internal.lineDelay');
%         state.acq.lineDelay=1000*state.internal.lineDelay*state.acq.msPerLine;
        updateGUIByGlobal('state.acq.lineDelay');
        updateGUIByGlobal('state.acq.cuspDelay');
%         disp(['Line Delay too small. Setting to ' num2str(state.acq.lineDelay) '.']);
    elseif state.acq.cuspDelay + state.acq.lineDelay > state.acq.fillFraction * state.acq.msPerLine
        disp(['Cusp Delay too big. Setting to ' num2str(state.acq.cuspDelay) '.']);
    end
    updateGUIByGlobal('state.acq.cuspDelay');
    advancedConfigurationGUI('pockelsClosedOnFlyback_Callback',gh.advancedConfigurationGUI.pockelsClosedOnFlyback); %VI031808A
elseif (state.acq.fillFraction + 2* state.acq.cuspDelay) > 1 && state.acq.bidirectionalScan %VI030508A
    setStatusString('Cusp Delay reset'); %VI031208A
    fprintf(2,'Servo (Cusp) Delay too large for given Fill Fraction. Set cusp delay to maximum permissible value.\n');
    state.acq.cuspDelay=(1-state.acq.fillFraction)/2;
    updateGUIByGlobal('state.acq.cuspDelay');    
    advancedConfigurationGUI('pockelsClosedOnFlyback_Callback',gh.advancedConfigurationGUI.pockelsClosedOnFlyback); %VI031808A
end

%Disable scan rotation during bidi scans (VI061908A)
if state.acq.bidirectionalScan
    state.acq.scanRotation = 0;
    updateGUIByGlobal('state.acq.scanRotation');    
    set(gh.mainControls.scanRotation,'Enable','off');
    set(gh.basicConfigurationGUI.scanRotation,'Enable','off');
    set(gh.mainControls.scanRotationSlider,'Enable','off');
else
    set(gh.mainControls.scanRotation,'Enable','on');
    set(gh.basicConfigurationGUI.scanRotation,'Enable','on');
    set(gh.mainControls.scanRotationSlider,'Enable','on');
end
    
