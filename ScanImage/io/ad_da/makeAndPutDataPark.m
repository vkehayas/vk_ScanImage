function makeAndPutDataPark(xy)
global state

% putDataPark.m*****
% Function that makes and places the parking laser data to the aoPark DAQ Output Engine.
%
% Written by Thomas Pologruto  
% Cold Spring Harbor Labs
% January 9, 2002

if nargin~=1
	state.internal.finalParkedLaserDataOutput= [state.init.parkAmplitudeX state.init.parkAmplitudeY];
else
	if length(xy)~=2
		% 		state.internal.finalParkedLaserDataOutput= repmat(xy,2000,1);
		state.internal.finalParkedLaserDataOutput= [state.init.parkAmplitudeX state.init.parkAmplitudeY];
	else
		
	end
end

putsample(state.init.aoPark, state.internal.finalParkedLaserDataOutput);	% Queues Data to engine for Board 2 (Mirrors)

