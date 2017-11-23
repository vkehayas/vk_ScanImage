function setScanProps(h,varargin)
global state gh

vis=get(gh.mainControls.focusButton, 'Visible');
if strcmp(vis, 'off')	% Not focusing...cant change these paraemters.
	return
end
updateCurrentROI;   
set(h,'Enable','off');
state.internal.updatedZoomOrRot=1;
val=get(gh.mainControls.focusButton, 'String');
if strcmp(val, 'ABORT') % focusing now....
    stopAndRestartFocus;
else
    state.internal.updatedZoomOrRot=1;
end
enable='on';

if nargin > 1
    while length(varargin) >= 2
        eval([varargin{1} '=varargin{2};'])
        varargin=varargin(2:end);
    end
end
set(h,'Enable',enable);
