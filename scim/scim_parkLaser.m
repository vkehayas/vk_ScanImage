function scim_parkLaser(varargin)       %VI05208B, VI05208C
%% function scim_parkLaser(varargin)
% Function to park the laser beam(s), at either standard or user-specified location
%% USAGE
%   scim_parkLaser(): parks laser at standard.ini defined park location (vars state.acq.parkAmplitudeX & state.acq.parkAmplitudeY); closes shutter and turns off beam with Pockels Cell
%   scim_parkLaser(xy): parks laser at user defined location xy, a 2 element vector of voltage values; opens shutter and passes beam with Pockels Cell
%   scim_parkLaser(...,'soft'): adding 'soft' flag causes function to park and blank the beam, but does not close the shutter
%% NOTES
%   When parking the laser at a user-specified location, the Pockels Cell is set to transmit the value currently specified by the Power Control slider.
%   When parking at the standard.ini location, the Pockels Cell is set to transmit the minimum possible vlaue.
%
%% MODIFICATIONS
%   VI052008A Vijay Iyer 5/20/08 -- Moved actual park laser functionality from makeAndPutDataPark() to this function
%   VI052008B Vijay Iyer 5/20/08 -- Renamed to scim_parkLaser(), making this available on the commaand line
%   VI052008C Vijay Iyer 5/20/08 -- Handle Pockels Cell voltage differently, for the two separate cases
%   VI052708A Vijay Iyer 5/27/08 -- Add shutter opening/closing, for the two cases
%   VI061908A Vijay Iyer 6/19/08 -- Added 'soft' park mode
%   VI061908B Vijay Iyer 6/19/08 -- Blank /all/ the laser beams
%   VI011609A Vijay Iyer 1/16/09 -- Changed state.init.pockelsOn to state.init.eom.pockelsOn
%
%% CREDITS
% Written By: Thomas Pologruto
% Cold Spring Harbor Labs
% February 8, 2001
%
%% ******************************************************************************************

if isempty(whos('global','state')) || isempty(whos('global','gh'))
    disp('ScanImage is not running or not properly running. Cannot park laser.');
    return;
end
global state

% start(state.init.aoPark);
% 
% while strcmp(state.init.aoPark.Running, 'On')
% end

% makeAndPutDataPark;

%Handle 'simple' flag option (VI061908A)
soft = false;
for i=1:length(varargin)
    if ischar(varargin{i}) && strcmpi('soft',varargin{i})
        soft=true;
        varargin(i) = [];
    end
end
%%%

%%%%%%%%(052008A) Added from makeAndPutDataPark() -- with minor mods %%%%%%%%%%%%%%%%%%%%%%%%%%
if length(varargin) == 0
    xy = [];
	state.internal.finalParkedLaserDataOutput= [state.init.parkAmplitudeX state.init.parkAmplitudeY];
elseif length(varargin)==1
    xy = varargin{1};
	if length(xy)~=2 || ~isnumeric(xy) 
        error('Optional argument must be a 2-element numeric vector containing X & Y park voltages');
    elseif min(xy(1)) < min(get(state.init.XMirrorChannelPark,'OutputRange')) || max(xy(1)) > max(get(state.init.XMirrorChannelPark,'OutputRange')) ... %VI052708A
            min(xy(2)) < min(get(state.init.YMirrorChannelPark,'OutputRange')) || max(xy(12)) > max(get(state.init.YMirrorChannelPark,'OutputRange'))
        error('Specified park voltages are outside of the allowed range.');
    else        
		state.internal.finalParkedLaserDataOutput= [xy(1) xy(2)];
    end		          
else
    error('Only one optional argument may be given');	
end

putsample(state.init.aoPark, state.internal.finalParkedLaserDataOutput);	% Queues Data to engine for Board 2 (Mirrors)
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%xy = [];
%TPMODPockels

if state.init.eom.pockelsOn == 1
    if ~isempty(state.init.eom.lut)
        for i=1:state.init.eom.numberOfBeams %VI061908B
            if isempty(xy) %VI052008C
                powerLevel = state.init.eom.min(i);
            else
                powerLevel = state.init.eom.maxPower(i);
            end

            setPockelsVoltage(i,state.init.eom.lut(i,powerLevel));
        end
    end
end

if ~soft %VI061908A
    %Open/close shutter %VI052708A
    if isempty(xy)
        closeShutter;
    else
        openShutter;
    end
end
