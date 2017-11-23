function [varargout] = startPMTOffsets
global state gh

% Function that will start the aiPMTOffsets DAQ device.
out=0;
global state
status=state.internal.statusString;
setStatusString('Reading PMT offsets...');

start(state.init.aiPMTOffsets);

while strcmp(state.init.aiPMTOffsets.Running, 'On')
end
setStatusString(status);
out=1;

if nargout == 1
	varargout{1} = out;
end
